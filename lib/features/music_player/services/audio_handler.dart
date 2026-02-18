import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.codev.aura.music_player.channel.audio',
      androidNotificationChannelName: 'Music Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      // أيقونة الإشعار (تأكد من وجودها في android/app/src/main/res/drawable)
      androidNotificationIcon: 'drawable/ic_stat_music_note',
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  // 1. استخدام ConcatenatingAudioSource بدلاً من القائمة العادية
  // هذا يسمح بإدارة القائمة (Gapless Playback) والتنقل التلقائي
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);

  static const _favortieSolidControl = MediaControl(
    androidIcon: 'drawable/ic_favorite_solid',
    label: 'Favorite',
    action: MediaAction.custom,
    customAction: 'action_unfavorite',
  );

  static const _favortieOutlinedControl = MediaControl(
    androidIcon: 'drawable/ic_favorite_outlined',
    label: 'Unfavorite',
    action: MediaAction.custom,
    customAction: 'action_favorite',
  );

  static const _closeControl = MediaControl(
    androidIcon: 'drawable/ic_close',
    label: 'Close',
    action: MediaAction.stop,
  );

  static const _playControl = MediaControl(
    androidIcon: 'drawable/ic_play',
    label: 'Close',
    action: MediaAction.play,
  );

  static const _pauseControl = MediaControl(
    androidIcon: 'drawable/ic_pause',
    label: 'Close',
    action: MediaAction.pause,
  );

  static const _nextControl = MediaControl(
    androidIcon: 'drawable/ic_next',
    label: 'Close',
    action: MediaAction.skipToNext,
  );

  static const _previousControl = MediaControl(
    androidIcon: 'drawable/ic_previous',
    label: 'Close',
    action: MediaAction.skipToPrevious,
  );

  MyAudioHandler() {
    _loadEmptyPlaylist();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenToCurrentPosition();
    _listenToCurrentSong();
    _listenToSequenceState();
  }

  Future<void> _loadEmptyPlaylist() async {
    try {
      // ربط القائمة بالمشغل مرة واحدة فقط عند البدء
      await _player.setAudioSource(_playlist);
    } catch (e) {
      debugPrint("Error loading audio source: $e");
    }
  }

  // --- 1. التحكم في القائمة (Queue Management) ---

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    // تحويل MediaItems إلى مصادر صوتية
    final audioSource = mediaItems.map(_createAudioSource).toList();

    // إضافة العناصر لقائمة التشغيل الحية (دون إيقاف المشغل)
    await _playlist.addAll(audioSource);

    // تحديث القائمة في AudioService (لأغراض العرض في النظام)
    final newQueue = queue.value..addAll(mediaItems);
    queue.add(newQueue);
  }

  @override
  Future<void> updateQueue(List<MediaItem> queueItems) async {
    // عند استبدال القائمة بالكامل (مثلاً تشغيل ألبوم جديد)
    final audioSource = queueItems.map(_createAudioSource).toList();

    // مسح القائمة الحالية وإضافة الجديدة
    await _playlist.clear();
    await _playlist.addAll(audioSource);

    // تحديث واجهة النظام
    queue.add(queueItems);
  }

  // دالة المساعدة كما هي، ممتازة
  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    final String? sourceUri = mediaItem.extras?['uri'] ?? mediaItem.extras?['url'];
    final uriToUse = sourceUri ?? mediaItem.id;

    return AudioSource.uri(
      Uri.parse(uriToUse),
      tag: mediaItem, // مهم جداً لاسترجاع البيانات
    );
  }

  // --- 2. التحكم في التشغيل (Playback Controls) ---

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

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _playlist.length) return;

    // الانتقال للأغنية المحددة وتشغيلها
    // ملاحظة: إذا كان المشغل متوقفاً، seek وحده لا يقوم بالتشغيل، لذا نضيف play
    await _player.seek(Duration.zero, index: index);
    if (!_player.playing) {
      await _player.play();
    }
  }

  // --- 3. ربط الأحداث (Streams & Listeners) ---

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;

      playbackState.add(playbackState.value.copyWith(
        controls: [
          _favortieSolidControl,
          _previousControl,
          if (playing) _pauseControl else _playControl,
          _nextControl,
          _closeControl,
        ],
        // هذه الأزرار تظهر في إشعار الأندرويد المصغر
        androidCompactActionIndices: const [1, 2, 3],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
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

  // Favorite Action
  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'action_favorite') {
      // قم بتنفيذ منطق الإضافة للمفضلة هنا
      debugPrint("تمت الإضافة للمفضلة");

      // ملاحظة: لتغيير الأيقونة (مثلاً من قلب فارغ لقلب ممتلئ)،
      // ستحتاج لمنطق إضافي لتحديث playbackState وتغيير الزر في قائمة controls
    }
  }

  void _listenToCurrentSong() {
    // just_audio يغير الـ currentIndex تلقائياً عند انتهاء الأغنية
    _player.currentIndexStream.listen((index) {
      final currentQueue = queue.value;
      if (index != null && index < currentQueue.length) {
        // تحديث الميديا الحالية في النظام (ليظهر الاسم والصورة في الإشعار وشاشة القفل)
        mediaItem.add(currentQueue[index]);
      }
    });
  }

  // هذا Listener إضافي مهم للتأكد من أن ترتيب القائمة صحيح
  void _listenToSequenceState() {
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;

      // استخراج الـ Tags (MediaItems) من القائمة الحالية في just_audio
      final items = sequence.map((source) => source.tag as MediaItem).toList();

      // تحديث الـ Queue فقط إذا اختلف الترتيب (مثلاً عند تفعيل الـ Shuffle)
      // queue.add(items);
    });
  }

  void _listenToCurrentPosition() {
    // الاستماع لموقع الأغنية الحالي وتحديثه في AudioService
    // هذا يساعد الواجهة الأمامية (UI) على تحديث الـ Slider بسلاسة
    _player.positionStream.listen((position) {
      final oldState = playbackState.value;
      playbackState.add(oldState.copyWith(updatePosition: position));
    });
  }
}