import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:aura/features/music_player/services/audio_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}
class MockSequenceState extends Mock implements SequenceState {}

void main() {
  late MyAudioHandler audioHandler;
  late MockAudioPlayer mockAudioPlayer;
  late StreamController<PlaybackEvent> playbackEventController;
  late StreamController<Duration> positionController;
  late StreamController<int?> currentIndexController;
  late StreamController<SequenceState> sequenceStateController;

  setUpAll(() {
    registerFallbackValue(AudioSource.uri(Uri.parse('http://example.com')));
    registerFallbackValue(Duration.zero);
  });

  setUp(() {
    mockAudioPlayer = MockAudioPlayer();
    playbackEventController = StreamController<PlaybackEvent>.broadcast();
    positionController = StreamController<Duration>.broadcast();
    currentIndexController = StreamController<int?>.broadcast();
    sequenceStateController = StreamController<SequenceState>.broadcast();

    // Stub necessary streams and properties accessed in MyAudioHandler constructor
    when(() => mockAudioPlayer.playbackEventStream).thenAnswer((_) => playbackEventController.stream);
    when(() => mockAudioPlayer.positionStream).thenAnswer((_) => positionController.stream);
    when(() => mockAudioPlayer.currentIndexStream).thenAnswer((_) => currentIndexController.stream);
    when(() => mockAudioPlayer.sequenceStateStream).thenAnswer((_) => sequenceStateController.stream);

    when(() => mockAudioPlayer.processingState).thenReturn(ProcessingState.idle);
    when(() => mockAudioPlayer.playing).thenReturn(false);
    when(() => mockAudioPlayer.position).thenReturn(Duration.zero);
    when(() => mockAudioPlayer.bufferedPosition).thenReturn(Duration.zero);
    when(() => mockAudioPlayer.speed).thenReturn(1.0);

    // Stub setAudioSource which is called in _loadEmptyPlaylist
    when(() => mockAudioPlayer.setAudioSource(any())).thenAnswer((_) async => null);

    audioHandler = MyAudioHandler(player: mockAudioPlayer);
  });

  tearDown(() {
    playbackEventController.close();
    positionController.close();
    currentIndexController.close();
    sequenceStateController.close();
  });

  group('MyAudioHandler', () {
    test('initializes correctly', () {
      expect(audioHandler, isNotNull);
      verify(() => mockAudioPlayer.setAudioSource(any())).called(1);
      verify(() => mockAudioPlayer.playbackEventStream).called(1);
      verify(() => mockAudioPlayer.positionStream).called(1);
      verify(() => mockAudioPlayer.currentIndexStream).called(1);
      verify(() => mockAudioPlayer.sequenceStateStream).called(1);
    });

    group('Queue Management', () {
      test('addQueueItems adds items to queue', () async {
        final mediaItems = [
          MediaItem(id: '1', title: 'Song 1', artist: 'Artist 1', extras: {'url': 'http://example.com/1'}),
          MediaItem(id: '2', title: 'Song 2', artist: 'Artist 2', extras: {'url': 'http://example.com/2'}),
        ];

        await audioHandler.addQueueItems(mediaItems);
        expect(audioHandler.queue.value, equals(mediaItems));
      });

      test('updateQueue replaces queue', () async {
        final initialItems = [MediaItem(id: '1', title: 'Song 1')];
        await audioHandler.addQueueItems(initialItems);

        final newItems = [MediaItem(id: '3', title: 'Song 3')];
        await audioHandler.updateQueue(newItems);

        expect(audioHandler.queue.value, equals(newItems));
      });
    });

    group('Playback Controls', () {
      test('play calls player.play', () async {
        when(() => mockAudioPlayer.play()).thenAnswer((_) async {});
        await audioHandler.play();
        verify(() => mockAudioPlayer.play()).called(1);
      });

      test('pause calls player.pause', () async {
        when(() => mockAudioPlayer.pause()).thenAnswer((_) async {});
        await audioHandler.pause();
        verify(() => mockAudioPlayer.pause()).called(1);
      });

      test('seek calls player.seek', () async {
        const position = Duration(seconds: 10);
        when(() => mockAudioPlayer.seek(position)).thenAnswer((_) async {});
        await audioHandler.seek(position);
        verify(() => mockAudioPlayer.seek(position)).called(1);
      });

      test('skipToNext calls player.seekToNext', () async {
        when(() => mockAudioPlayer.seekToNext()).thenAnswer((_) async {});
        await audioHandler.skipToNext();
        verify(() => mockAudioPlayer.seekToNext()).called(1);
      });

      test('skipToPrevious calls player.seekToPrevious', () async {
        when(() => mockAudioPlayer.seekToPrevious()).thenAnswer((_) async {});
        await audioHandler.skipToPrevious();
        verify(() => mockAudioPlayer.seekToPrevious()).called(1);
      });

      test('stop calls player.stop', () async {
        when(() => mockAudioPlayer.stop()).thenAnswer((_) async {});
        await audioHandler.stop();
        verify(() => mockAudioPlayer.stop()).called(1);
      });

      test('skipToQueueItem seeks to index and plays', () async {
         final mediaItems = [MediaItem(id: '1', title: 'Song 1')];
         await audioHandler.addQueueItems(mediaItems);

         when(() => mockAudioPlayer.seek(Duration.zero, index: 0)).thenAnswer((_) async {});
         when(() => mockAudioPlayer.playing).thenReturn(false);
         when(() => mockAudioPlayer.play()).thenAnswer((_) async {});

         await audioHandler.skipToQueueItem(0);

         verify(() => mockAudioPlayer.seek(Duration.zero, index: 0)).called(1);
         verify(() => mockAudioPlayer.play()).called(1);
      });

      test('skipToQueueItem does nothing if index is out of bounds', () async {
         // Queue is empty initially
         await audioHandler.skipToQueueItem(0);
         verifyNever(() => mockAudioPlayer.seek(any(), index: any(named: 'index')));
         verifyNever(() => mockAudioPlayer.play());
      });
    });

    group('State Updates', () {
        test('updates playbackState when player event occurs', () async {
            // Arrange
            final event = PlaybackEvent(
                processingState: ProcessingState.ready,
                updateTime: DateTime.now(),
                updatePosition: Duration.zero,
                bufferedPosition: Duration.zero,
                duration: Duration.zero,
                currentIndex: 0,
            );

            when(() => mockAudioPlayer.processingState).thenReturn(ProcessingState.ready);
            when(() => mockAudioPlayer.playing).thenReturn(true);
            when(() => mockAudioPlayer.position).thenReturn(Duration(seconds: 1));
            when(() => mockAudioPlayer.bufferedPosition).thenReturn(Duration(seconds: 2));
            when(() => mockAudioPlayer.speed).thenReturn(1.0);

            // Act
            playbackEventController.add(event);

            // Wait for stream to process
            await Future.delayed(Duration.zero);

            // Assert
            final state = audioHandler.playbackState.value;
            expect(state.processingState, AudioProcessingState.ready);
            expect(state.playing, true);
            expect(state.updatePosition, Duration(seconds: 1));
            expect(state.bufferedPosition, Duration(seconds: 2));
        });

        test('updates mediaItem when current song changes', () async {
             final mediaItems = [
                MediaItem(id: '1', title: 'Song 1', artist: 'Artist 1', extras: {'url': 'url1'}),
                MediaItem(id: '2', title: 'Song 2', artist: 'Artist 2', extras: {'url': 'url2'}),
            ];

            audioHandler.queue.add(mediaItems);

            // Act
            currentIndexController.add(1);

            // Wait
            await Future.delayed(Duration.zero);

            // Assert
            expect(audioHandler.mediaItem.value, equals(mediaItems[1]));
        });
    });
  });
}
