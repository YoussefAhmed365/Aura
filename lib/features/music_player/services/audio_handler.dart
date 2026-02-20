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
      // Notification icon (make sure it exists in android/app/src/main/res/drawable)
      androidNotificationIcon: 'drawable/ic_stat_music_note',
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  // 1. Use ConcatenatingAudioSource instead of a regular list
  // This allows for queue management (Gapless Playback) and automatic navigation
  final _player = AudioPlayer();

  // ignore: deprecated_member_use
  final _playlist = ConcatenatingAudioSource(children: []);

  bool isFavorite = false;

  static const String actionAddFavorite = 'action_add_favorite';
  static const String actionRemoveFavorite = 'action_remove_favorite';

  static const _favortieOutlinedControl = MediaControl(
    androidIcon: 'drawable/ic_favorite_outlined',
    label: 'Unfavorite',
    action: MediaAction.custom,
    customAction: CustomMediaAction(name: actionAddFavorite),
  );

  static const _favortieSolidControl = MediaControl(
    androidIcon: 'drawable/ic_favorite_solid',
    label: 'Favorite',
    action: MediaAction.custom,
    customAction: CustomMediaAction(name: actionRemoveFavorite),
  );

  static const _closeControl = MediaControl(
    androidIcon: 'drawable/ic_close',
    label: 'Close',
    action: MediaAction.stop,
  );

  static const _playControl = MediaControl(
    androidIcon: 'drawable/ic_play',
    label: 'Play',
    action: MediaAction.play,
  );

  static const _pauseControl = MediaControl(
    androidIcon: 'drawable/ic_pause',
    label: 'Pause',
    action: MediaAction.pause,
  );

  static const _nextControl = MediaControl(
    androidIcon: 'drawable/ic_next',
    label: 'Next',
    action: MediaAction.skipToNext,
  );

  static const _previousControl = MediaControl(
    androidIcon: 'drawable/ic_previous',
    label: 'Previous',
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
      // Bind the playlist to the player only once at startup
      await _player.setAudioSource(_playlist);
    } catch (e) {
      debugPrint("Error loading audio source: $e");
    }
  }

  // --- 1. Queue Management ---

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    // Convert MediaItems to audio sources
    final audioSource = mediaItems.map(_createAudioSource).toList();

    // Add items to the live playlist (without stopping the player)
    await _playlist.addAll(audioSource);

    // Update the queue in AudioService (for system display purposes)
    final newQueue = queue.value..addAll(mediaItems);
    queue.add(newQueue);
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    // When replacing the entire queue (e.g., playing a new album)
    final audioSource = queue.map(_createAudioSource).toList();

    // Clear current queue and add the new one
    await _playlist.clear();
    await _playlist.addAll(audioSource);

    // Update system UI
    this.queue.add(queue);
  }

  // Helper function
  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    final String? sourceUri = mediaItem.extras?['uri'] ?? mediaItem.extras?['url'];
    final uriToUse = sourceUri ?? mediaItem.id;

    return AudioSource.uri(
      Uri.parse(uriToUse),
      tag: mediaItem, // Very important for retrieving data
    );
  }

  // --- 2. Playback Controls ---

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

    // Seek to the specific song and play it
    // Note: If the player is stopped, seek alone doesn't play, so we add play()
    await _player.seek(Duration.zero, index: index);
    if (!_player.playing) {
      await _player.play();
    }
  }

  // --- 3. Streams & Listeners ---

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;

      playbackState.add(playbackState.value.copyWith(
        controls: [
          isFavorite ? _favortieOutlinedControl : _favortieSolidControl,
          _previousControl,
          if (playing) _pauseControl else _playControl,
          _nextControl,
          _closeControl,
        ],
        // These buttons appear in the Android compact notification
        androidCompactActionIndices: const [1, 2, 3],
        systemActions: const {
          MediaAction.play,
          MediaAction.pause,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.stop,
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
    if (name == actionAddFavorite) {
      isFavorite = true;

      // Note: To change the icon (e.g., from an outlined heart to a solid heart),
      // you will need additional logic to update playbackState and change the button in the controls list
      return;
    }
    if (name == actionRemoveFavorite) {
      isFavorite = false;

      // Note: To change the icon (e.g., from an outlined heart to a solid heart),
      // you will need additional logic to update playbackState and change the button in the controls list
      return;
    }
  }

  void _listenToCurrentSong() {
    // just_audio changes currentIndex automatically when a song finishes
    _player.currentIndexStream.listen((index) {
      final currentQueue = queue.value;
      if (index != null && index < currentQueue.length) {
        // Update current media in the system (to show name and image in notification and lock screen)
        mediaItem.add(currentQueue[index]);
      }
    });
  }

  // This is an important additional listener to ensure the queue order is correct
  void _listenToSequenceState() {
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;

      // Extract Tags (MediaItems) from the current list in just_audio
      final items = sequence.map((source) => source.tag as MediaItem).toList();

      // Update the Queue only if the order changes (e.g., when Shuffle is enabled)
      queue.add(items);
    });
  }

  void _listenToCurrentPosition() {
    // Listen to the current song position and update it in AudioService
    // This helps the frontend (UI) update the Slider smoothly
    _player.positionStream.listen((position) {
      final oldState = playbackState.value;
      playbackState.add(oldState.copyWith(updatePosition: position));
    });
  }
}