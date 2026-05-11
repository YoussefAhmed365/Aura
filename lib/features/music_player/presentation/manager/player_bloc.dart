import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../domain/repositories/audio_repository.dart';

part 'player_event.dart';
part 'player_state.dart';

@injectable
class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final AudioHandler _audioHandler;
  final AudioRepository _audioRepository; // الاعتماد الوحيد للبيانات
  final Stream<Duration>? _positionStream;

  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _mediaItemSubscription;
  StreamSubscription? _queueSubscription;

  // تمت إزالة _prefs والثوابت النصية الخاصة به

  PlayerBloc(this._audioHandler, this._audioRepository, {@factoryParam Stream<Duration>? positionStream}) : _positionStream = positionStream, super(const PlayerState()) {
    on<PlayAllEvent>(_onPlayAll);
    on<PlaySongsByIdsEvent>(_onPlaySongsByIds);
    on<PlayPauseEvent>(_onPlayPause);
    on<SeekEvent>(_onSeek);
    on<SkipNextEvent>(_onSkipNext);
    on<SkipPreviousEvent>(_onSkipPrevious);
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<CheckFavoriteStatusEvent>(_onCheckFavoriteStatus);

    on<LoadSavedQueuesEvent>(_onLoadSavedQueues);
    on<PlaySpecificQueueItemEvent>(_onPlaySpecificQueueItem);
    on<ReorderQueueEvent>(_onReorderQueue);
    on<PlaySavedQueueEvent>(_onPlaySavedQueue);
    on<DeleteQueueEvent>(_onDeleteQueue);
    on<RenameQueueEvent>(_onRenameQueue);

    on<_MediaItemUpdated>(_onMediaItemUpdated);
    on<_PlaybackStateUpdated>(_onPlaybackStateUpdated);
    on<_PositionUpdated>(_onPositionUpdated);
    on<_QueueUpdated>(_onQueueUpdated);

    _listenToAudioHandler();

    add(LoadSavedQueuesEvent());
    add(LoadFavoritesEvent());
  }

  // --- دوال الجلسة والقوائم (نظيفة وتعتمد على المستودع) ---

  Future<void> _saveCurrentSession() async {
    await _audioRepository.saveCurrentSession(activeQueueId: state.activeQueueId, currentIndex: state.currentIndex, positionMs: state.position.inMilliseconds);
  }

  void _onLoadSavedQueues(LoadSavedQueuesEvent event, Emitter<PlayerState> emit) async {
    // جلب القوائم من المستودع بدلاً من فك التشفير هنا
    final String? queuesJson = await _audioRepository.getSavedQueuesJson();
    List<CustomQueue> loadedQueues = [];

    if (queuesJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(queuesJson);
        loadedQueues = decoded.map((q) => CustomQueue.fromJson(q)).toList();
      } catch (e) {}
    }

    // جلب الجلسة السابقة
    final session = await _audioRepository.getLastSession();
    final String? lastQueueId = session['activeQueueId'];
    final int lastIndex = session['currentIndex'] ?? 0;
    final int lastPositionMs = session['positionMs'] ?? 0;

    if (loadedQueues.isNotEmpty && lastQueueId != null) {
      try {
        final queueToRestore = loadedQueues.firstWhere((q) => q.id == lastQueueId);

        emit(
          state.copyWith(
            savedQueues: loadedQueues,
            activeQueueId: queueToRestore.id,
            queue: queueToRestore.items,
            currentIndex: lastIndex,
            currentSong: lastIndex < queueToRestore.items.length ? queueToRestore.items[lastIndex] : null,
            position: Duration(milliseconds: lastPositionMs),
          ),
        );

        await _audioHandler.updateQueue(queueToRestore.items);
        await _audioHandler.customAction('action_restore_session', {'index': lastIndex, 'position': lastPositionMs});

        return;
      } catch (e) {}
    }

    emit(state.copyWith(savedQueues: loadedQueues));
  }

  Future<void> _saveQueuesToRepository(List<CustomQueue> queues) async {
    final String encoded = jsonEncode(queues.map((q) => q.toJson()).toList());
    await _audioRepository.saveQueuesJson(encoded);
  }

  // --- باقي أحداث الواجهة (UI Events) ---

  Future<void> _onPlayAll(PlayAllEvent event, Emitter<PlayerState> emit) async {
    final mediaItems = event.songs
        .map(
          (song) => MediaItem(
            id: song.id.toString(),
            album: song.album ?? "Unknown Album",
            title: song.title,
            artist: song.artist ?? "Unknown Artist",
            duration: Duration(milliseconds: song.duration ?? 0),
            artUri: Uri.parse("content://media/external/audio/media/${song.id}/albumart"),
            extras: {'url': song.data, 'uri': song.uri},
          ),
        )
        .toList();

    final newQueueId = DateTime.now().millisecondsSinceEpoch.toString();
    final newQueueName = 'Queue ${state.savedQueues.length + 1}';

    final newQueue = CustomQueue(id: newQueueId, name: newQueueName, items: mediaItems);
    final updatedQueues = List<CustomQueue>.from(state.savedQueues)..add(newQueue);

    _saveQueuesToRepository(updatedQueues);

    emit(state.copyWith(isPlaying: true, currentSong: mediaItems[event.index], queue: mediaItems, currentIndex: event.index, savedQueues: updatedQueues, activeQueueId: newQueueId));

    await _audioHandler.updateQueue(mediaItems);
    await _audioHandler.skipToQueueItem(event.index);
    _saveCurrentSession();
  }

  Future<void> _onPlaySongsByIds(PlaySongsByIdsEvent event, Emitter<PlayerState> emit) async {
    final songs = await _audioRepository.getSongsByIds(event.ids);
    if (songs.isNotEmpty) {
      add(PlayAllEvent(songs: songs, index: event.initialIndex));
    }
  }

  Future<void> _onPlaySpecificQueueItem(PlaySpecificQueueItemEvent event, Emitter<PlayerState> emit) async {
    await _audioHandler.skipToQueueItem(event.index);
    _saveCurrentSession();
  }

  void _onReorderQueue(ReorderQueueEvent event, Emitter<PlayerState> emit) {
    _audioHandler.customAction('action_move_queue_item', {'oldIndex': event.oldIndex, 'newIndex': event.newIndex});
  }

  Future<void> _onPlaySavedQueue(PlaySavedQueueEvent event, Emitter<PlayerState> emit) async {
    final queueToPlay = state.savedQueues.firstWhere((q) => q.id == event.queueId);

    emit(state.copyWith(activeQueueId: queueToPlay.id, queue: queueToPlay.items, currentIndex: 0));

    await _audioHandler.updateQueue(queueToPlay.items);
    await _audioHandler.skipToQueueItem(0);
    if (!state.isPlaying) _audioHandler.play();
    _saveCurrentSession();
  }

  void _onDeleteQueue(DeleteQueueEvent event, Emitter<PlayerState> emit) {
    final updatedQueues = state.savedQueues.where((q) => q.id != event.queueId).toList();
    _saveQueuesToRepository(updatedQueues);
    emit(state.copyWith(savedQueues: updatedQueues));
  }

  void _onRenameQueue(RenameQueueEvent event, Emitter<PlayerState> emit) {
    final updatedQueues = state.savedQueues.map((q) {
      if (q.id == event.queueId) return q.copyWith(name: event.newName);
      return q;
    }).toList();
    _saveQueuesToRepository(updatedQueues);
    emit(state.copyWith(savedQueues: updatedQueues));
  }

  void _onPlayPause(PlayPauseEvent event, Emitter<PlayerState> emit) {
    if (state.isPlaying) {
      _audioHandler.pause();
      emit(state.copyWith(isPlaying: false));
    } else {
      _audioHandler.play();
      emit(state.copyWith(isPlaying: true));
    }
    _saveCurrentSession();
  }

  void _onSeek(SeekEvent event, Emitter<PlayerState> emit) => _audioHandler.seek(event.position);

  void _onSkipNext(SkipNextEvent event, Emitter<PlayerState> emit) => _audioHandler.skipToNext();

  void _onSkipPrevious(SkipPreviousEvent event, Emitter<PlayerState> emit) => _audioHandler.skipToPrevious();

  // --- أحداث التحديث الداخلي ---

  void _onMediaItemUpdated(_MediaItemUpdated event, Emitter<PlayerState> emit) {
    final mediaItem = event.mediaItem;
    if (mediaItem == null) return;
    final index = state.queue.indexWhere((item) => item.id == mediaItem.id);
    final songId = int.tryParse(mediaItem.id) ?? 0;
    emit(state.copyWith(currentSong: mediaItem, duration: mediaItem.duration ?? Duration.zero, currentIndex: index != -1 ? index : state.currentIndex, isFavorite: state.favoritesSongIds.contains(songId)));
    _saveCurrentSession();
  }

  void _onPlaybackStateUpdated(_PlaybackStateUpdated event, Emitter<PlayerState> emit) {
    emit(state.copyWith(isPlaying: event.isPlaying, isBuffering: event.isBuffering));
  }

  void _onPositionUpdated(_PositionUpdated event, Emitter<PlayerState> emit) {
    emit(state.copyWith(position: event.position));
    if (event.position.inSeconds > 0 && event.position.inSeconds % 5 == 0) {
      _saveCurrentSession();
    }
  }

  void _onQueueUpdated(_QueueUpdated event, Emitter<PlayerState> emit) {
    final mediaItem = state.currentSong;
    int index = state.currentIndex;
    if (mediaItem != null) {
      index = event.queue.indexWhere((item) => item.id == mediaItem.id);
    }

    List<CustomQueue> updatedSavedQueues = state.savedQueues;
    if (state.activeQueueId != null) {
      updatedSavedQueues = state.savedQueues.map((q) {
        if (q.id == state.activeQueueId) {
          return q.copyWith(items: event.queue);
        }
        return q;
      }).toList();
      _saveQueuesToRepository(updatedSavedQueues);
    }

    emit(state.copyWith(queue: event.queue, currentIndex: index != -1 ? index : state.currentIndex, savedQueues: updatedSavedQueues));

    _saveCurrentSession();
  }

  // --- دوال المفضلة ---

  Future<void> _onLoadFavorites(LoadFavoritesEvent event, Emitter<PlayerState> emit) async {
    final favoriteIds = await _audioRepository.getAllFavoriteSongsIds();
    final favoriteSongs = await _audioRepository.getSongsByIds(favoriteIds);
    emit(state.copyWith(favoritesSongIds: favoriteIds, favoriteSongs: favoriteSongs));
  }

  void _onCheckFavoriteStatus(CheckFavoriteStatusEvent event, Emitter<PlayerState> emit) {
    final isFavorite = state.favoritesSongIds.contains(event.songId);
    emit(state.copyWith(isFavorite: isFavorite));
  }

  Future<void> _onToggleFavorite(ToggleFavoriteEvent event, Emitter<PlayerState> emit) async {
    final isFavorite = state.favoritesSongIds.contains(event.songId);
    bool success = false;

    if (isFavorite) {
      success = await _audioRepository.removeSongFromFavorites(event.songId);
    } else {
      success = await _audioRepository.addSongToFavorites(event.songId);
    }

    if (success) {
      final updatedFavorites = List<int>.from(state.favoritesSongIds);
      if (isFavorite) {
        updatedFavorites.remove(event.songId);
      } else {
        updatedFavorites.add(event.songId);
      }
      
      final favoriteSongs = await _audioRepository.getSongsByIds(updatedFavorites);
      emit(state.copyWith(favoritesSongIds: updatedFavorites, favoriteSongs: favoriteSongs, isFavorite: !isFavorite));
    }
  }

  void _listenToAudioHandler() {
    _mediaItemSubscription = _audioHandler.mediaItem.listen((mediaItem) => add(_MediaItemUpdated(mediaItem)));
    _playerStateSubscription = _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final isBuffering = playbackState.processingState == AudioProcessingState.buffering || playbackState.processingState == AudioProcessingState.loading;
      add(_PlaybackStateUpdated(isPlaying: isPlaying, isBuffering: isBuffering));
    });
    (_positionStream ?? AudioService.position).listen((position) => add(_PositionUpdated(position)));
    _queueSubscription = _audioHandler.queue.listen((queue) => add(_QueueUpdated(queue)));
  }

  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _mediaItemSubscription?.cancel();
    _queueSubscription?.cancel();
    return super.close();
  }
}
