import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:on_audio_query/on_audio_query.dart';

part 'player_event.dart';
part 'player_state.dart';

@injectable
class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final AudioHandler _audioHandler;

  // اشتراكات لمراقبة التغيرات في المشغل
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _mediaItemSubscription;
  StreamSubscription? _queueSubscription;

  PlayerBloc(this._audioHandler) : super(const PlayerState()) {
    // --- الاستماع للأحداث القادمة من UI ---
    on<PlayAllEvent>(_onPlayAll);
    on<PlayPauseEvent>(_onPlayPause);
    on<SeekEvent>(_onSeek);
    on<SkipNextEvent>(_onSkipNext);
    on<SkipPreviousEvent>(_onSkipPrevious);

    // --- الاستماع للتغيرات القادمة من AudioHandler (الأحداث الداخلية) ---
    on<_MediaItemUpdated>(_onMediaItemUpdated);
    on<_PlaybackStateUpdated>(_onPlaybackStateUpdated);
    on<_PositionUpdated>(_onPositionUpdated);
    on<_QueueUpdated>(_onQueueUpdated);

    // --- الاستماع للتغيرات القادمة من AudioHandler ---
    _listenToAudioHandler();
  }

  // 1. منطق تشغيل قائمة أغاني
  Future<void> _onPlayAll(PlayAllEvent event, Emitter<PlayerState> emit) async {
    // تحويل SongModel الخاص بـ on_audio_query إلى MediaItem الخاص بـ audio_service
    final mediaItems = event.songs
        .map(
          (song) => MediaItem(
            id: song.id.toString(), // استخدام المعرف الرقمي كـ ID لسهولة استرجاعه
            album: song.album ?? "Unknown Album",
            title: song.title,
            artist: song.artist ?? "Unknown Artist",
            duration: Duration(milliseconds: song.duration ?? 0),
            artUri: Uri.parse("content://media/external/audio/media/${song.id}/albumart"),
            extras: {
              'url': song.data,
              'uri': song.uri,
            }, 
          ),
        )
        .toList();

    // تحديث القائمة في المشغل
    await _audioHandler.updateQueue(mediaItems);

    // تشغيل الأغنية المختارة
    await _audioHandler.skipToQueueItem(event.index);
    
    // تأكد من بدء التشغيل
    _audioHandler.play();
  }

  void _onPlayPause(PlayPauseEvent event, Emitter<PlayerState> emit) {
    state.isPlaying ? _audioHandler.pause() : _audioHandler.play();
  }

  void _onSeek(SeekEvent event, Emitter<PlayerState> emit) {
    _audioHandler.seek(event.position);
  }

  void _onSkipNext(SkipNextEvent event, Emitter<PlayerState> emit) => _audioHandler.skipToNext();

  void _onSkipPrevious(SkipPreviousEvent event, Emitter<PlayerState> emit) => _audioHandler.skipToPrevious();

  // --- معالجات الأحداث الداخلية (Internal Event Handlers) ---
  void _onMediaItemUpdated(_MediaItemUpdated event, Emitter<PlayerState> emit) {
    final mediaItem = event.mediaItem;
    if (mediaItem == null) return;

    final index = state.queue.indexWhere((item) => item.id == mediaItem.id);
    
    emit(state.copyWith(
      currentSong: mediaItem, 
      duration: mediaItem.duration ?? Duration.zero,
      currentIndex: index != -1 ? index : state.currentIndex,
    ));
  }

  void _onPlaybackStateUpdated(_PlaybackStateUpdated event, Emitter<PlayerState> emit) {
    emit(state.copyWith(isPlaying: event.isPlaying, isBuffering: event.isBuffering));
  }

  void _onPositionUpdated(_PositionUpdated event, Emitter<PlayerState> emit) {
    emit(state.copyWith(position: event.position));
  }

  void _onQueueUpdated(_QueueUpdated event, Emitter<PlayerState> emit) {
    final mediaItem = state.currentSong;
    int index = state.currentIndex;
    if (mediaItem != null) {
      index = event.queue.indexWhere((item) => item.id == mediaItem.id);
    }
    emit(state.copyWith(
      queue: event.queue,
      currentIndex: index != -1 ? index : 0,
    ));
  }

  // --- المراقبة (The Bridge) ---
  void _listenToAudioHandler() {
    // 1. مراقبة الأغنية الحالية
    _mediaItemSubscription = _audioHandler.mediaItem.listen((mediaItem) {
      add(_MediaItemUpdated(mediaItem));
    });

    // 2. مراقبة حالة التشغيل (Play/Pause/Buffering)
    _playerStateSubscription = _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;

      final isBuffering = processingState == AudioProcessingState.buffering || processingState == AudioProcessingState.loading;

      add(_PlaybackStateUpdated(isPlaying: isPlaying, isBuffering: isBuffering));
    });

    // 3. مراقبة شريط التقدم (Position)
    AudioService.position.listen((position) {
      add(_PositionUpdated(position));
    });

    // 4. مراقبة قائمة التشغيل
    _queueSubscription = _audioHandler.queue.listen((queue) {
      add(_QueueUpdated(queue));
    });
  }

  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _mediaItemSubscription?.cancel();
    _queueSubscription?.cancel();
    return super.close();
  }
}
