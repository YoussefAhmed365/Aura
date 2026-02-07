import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:on_audio_query/on_audio_query.dart';

part 'player_event.dart';

part 'player_state.dart';

@injectable
class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final AudioHandler _audioHandler;

  // اشتراكات لمراقبة التغيرات في المشغل
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _mediaItemSubscription;

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

    // --- الاستماع للتغيرات القادمة من AudioHandler ---
    _listenToAudioHandler();
  }

  // 1. منطق تشغيل قائمة أغاني
  Future<void> _onPlayAll(PlayAllEvent event, Emitter<PlayerState> emit) async {
    // تحويل SongModel الخاص بـ on_audio_query إلى MediaItem الخاص بـ audio_service
    final mediaItems = event.songs
        .map(
          (song) => MediaItem(
            id: song.uri ?? '',
            // مسار الملف
            album: song.album ?? "Unknown Album",
            title: song.title,
            artist: song.artist ?? "Unknown Artist",
            duration: Duration(milliseconds: song.duration ?? 0),
            artUri: Uri.parse("content://media/external/audio/media/${song.id}/albumart"),
            // لجلب الصورة
            extras: {'url': song.data}, // نحتفظ بالمسار الفعلي هنا أيضاً للأمان
          ),
        )
        .toList();

    // تحديث القائمة في المشغل
    await _audioHandler.updateQueue(mediaItems);

    // تشغيل الأغنية المختارة
    await _audioHandler.skipToQueueItem(event.index);
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
    emit(state.copyWith(currentSong: mediaItem, duration: mediaItem.duration ?? Duration.zero));
  }

  void _onPlaybackStateUpdated(_PlaybackStateUpdated event, Emitter<PlayerState> emit) {
    emit(state.copyWith(isPlaying: event.isPlaying, isBuffering: event.isBuffering));
  }

  void _onPositionUpdated(_PositionUpdated event, Emitter<PlayerState> emit) {
    emit(state.copyWith(position: event.position));
  }

  // --- المراقبة (The Bridge) ---
  void _listenToAudioHandler() {
    // 1. مراقبة الأغنية الحالية
    _mediaItemSubscription = _audioHandler.mediaItem.listen((mediaItem) {
      if (mediaItem != null) {
        add(_MediaItemUpdated(mediaItem));
      }
    });

    // 2. مراقبة حالة التشغيل (Play/Pause/Buffering)
    _playerStateSubscription = _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      
      final isBuffering = processingState == AudioProcessingState.buffering || processingState == AudioProcessingState.loading;
      
      add(_PlaybackStateUpdated(isPlaying: isPlaying, isBuffering: isBuffering));
    });

    // 3. مراقبة شريط التقدم (Position)
    // AudioService لا يوفر Stream مباشر للـ Position، سنستخدم حل بسيط لاحقاً
    // ولكن الآن سنعتمد على التحديث الدوري من just_audio داخل AudioHandler
    AudioService.position.listen((position) {
      add(_PositionUpdated(position));
    });
  }

  @override
  Future<void> close() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _mediaItemSubscription?.cancel();
    return super.close();
  }
}