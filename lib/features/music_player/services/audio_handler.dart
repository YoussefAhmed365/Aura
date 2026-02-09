import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.codev.aura.music_player.channel.audio',
      androidNotificationChannelName: 'Music Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  // هذا هو المشغل الفعلي من مكتبة just_audio
  final _player = AudioPlayer();

  // هذا هو الـ Queue (قائمة التشغيل) التي ستحتوي الأغاني
  final _playlist = <AudioSource>[];

  MyAudioHandler() {
    _loadEmptyPlaylist();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenToCurrentPosition();
    _listenToCurrentSong();
  }

  Future<void> _loadEmptyPlaylist() async {
    try {
      await _player.setAudioSources(_playlist);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  // --- 1. التحكم في القائمة (Queue) ---

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    // تحويل MediaItem (بيانات) إلى AudioSource (ملف قابل للتشغيل)
    final audioSource = mediaItems.map(_createAudioSource).toList();

    // إضافة الأغاني للقائمة الحالية
    _playlist.addAll(audioSource);
    await _player.setAudioSources(List.from(_playlist));

    // تحديث القائمة في النظام (ليراها الـ Notification)
    final newQueue = queue.value..addAll(mediaItems);
    queue.add(newQueue);
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    // هذه الدالة لتحديث القائمة بالكامل (عند تشغيل قائمة جديدة)
    _playlist.clear();
    this.queue.add([]); // تصفير القائمة القديمة
    await addQueueItems(queue);
  }

  // دالة مساعدة لتحويل البيانات لمصدر صوت
  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    return AudioSource.uri(
      Uri.parse(mediaItem.id), // مسار الملف
      tag: mediaItem, // نرفق البيانات مع الملف لنعرف اسمه لاحقاً
    );
  }

  // --- 2. التحكم في التشغيل ---

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  // هذه أهم دالة: تشغيل أغنية معينة من القائمة عند الضغط عليها
  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _playlist.length) return;
    // القفز للأغنية وتشغيلها
    await _player.seek(Duration.zero, index: index);
    play();
  }

  // --- 3. ربط الأحداث (The Bridge) ---

  // الاستماع لحالة المشغل (هل يعمل؟ هل توقف؟) وتحديث الإشعار
  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  // الاستماع للأغنية الحالية وتحديث بياناتها في النظام
  void _listenToCurrentSong() {
    _player.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices[index];
      }
      if (index < playlist.length) {
        mediaItem.add(playlist[index]); // تحديث الأغنية الحالية
      }
    });
  }

  void _listenToCurrentPosition() {
    // يمكنك هنا إضافة منطق لحفظ مكان الأغنية عند الإغلاق (Hive)
    // سنقوم بذلك في خطوة لاحقة
  }
}
