import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:aura/features/music_player/presentation/manager/player_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';

// --- Mocks ---
class MockAudioHandler extends Mock implements AudioHandler {}
class MockSongModel extends Mock implements SongModel {}

void main() {
  late PlayerBloc playerBloc;
  late MockAudioHandler mockAudioHandler;

  // Streams controllers to simulate AudioHandler updates
  late BehaviorSubject<MediaItem?> mediaItemController;
  late BehaviorSubject<PlaybackState> playbackStateController;
  late BehaviorSubject<List<MediaItem>> queueController;
  late StreamController<Duration> positionController;

  setUpAll(() {
    registerFallbackValue(const Duration(seconds: 0));
    registerFallbackValue(const MediaItem(id: '0', title: 'dummy'));
  });

  setUp(() {
    mockAudioHandler = MockAudioHandler();

    // Initialize stream controllers using BehaviorSubject (to return ValueStream)
    mediaItemController = BehaviorSubject<MediaItem?>();
    playbackStateController = BehaviorSubject<PlaybackState>();
    queueController = BehaviorSubject<List<MediaItem>>();
    positionController = StreamController<Duration>.broadcast();

    // Mock AudioHandler streams
    when(() => mockAudioHandler.mediaItem).thenAnswer((_) => mediaItemController.stream);
    when(() => mockAudioHandler.playbackState).thenAnswer((_) => playbackStateController.stream);
    when(() => mockAudioHandler.queue).thenAnswer((_) => queueController.stream);

    // Initialize Bloc with mocked handler and position stream
    playerBloc = PlayerBloc(mockAudioHandler, positionStream: positionController.stream);
  });

  tearDown(() {
    playerBloc.close();
    mediaItemController.close();
    playbackStateController.close();
    queueController.close();
    positionController.close();
  });

  group('PlayerBloc', () {
    test('initial state is correct', () {
      expect(playerBloc.state, const PlayerState());
    });

    group('UI Events', () {
      final song = MockSongModel();
      when(() => song.id).thenReturn(1);
      when(() => song.title).thenReturn('Title');
      when(() => song.artist).thenReturn('Artist');
      when(() => song.album).thenReturn('Album');
      when(() => song.duration).thenReturn(1000);
      when(() => song.data).thenReturn('path/to/song');
      when(() => song.uri).thenReturn('uri');

      blocTest<PlayerBloc, PlayerState>(
        'PlayAllEvent calls updateQueue, skipToQueueItem and play',
        build: () {
          when(() => mockAudioHandler.updateQueue(any())).thenAnswer((_) async {});
          when(() => mockAudioHandler.skipToQueueItem(any())).thenAnswer((_) async {});
          when(() => mockAudioHandler.play()).thenAnswer((_) async {});
          return playerBloc;
        },
        act: (bloc) => bloc.add(PlayAllEvent(songs: [song], index: 0)),
        verify: (_) {
          verify(() => mockAudioHandler.updateQueue(any())).called(1);
          verify(() => mockAudioHandler.skipToQueueItem(0)).called(1);
          verify(() => mockAudioHandler.play()).called(1);
        },
      );

      blocTest<PlayerBloc, PlayerState>(
        'PlayPauseEvent calls pause when playing',
        seed: () => const PlayerState(isPlaying: true),
        build: () {
          when(() => mockAudioHandler.pause()).thenAnswer((_) async {});
          return playerBloc;
        },
        act: (bloc) => bloc.add(PlayPauseEvent()),
        verify: (_) {
          verify(() => mockAudioHandler.pause()).called(1);
        },
      );

      blocTest<PlayerBloc, PlayerState>(
        'PlayPauseEvent calls play when paused',
        seed: () => const PlayerState(isPlaying: false),
        build: () {
          when(() => mockAudioHandler.play()).thenAnswer((_) async {});
          return playerBloc;
        },
        act: (bloc) => bloc.add(PlayPauseEvent()),
        verify: (_) {
          verify(() => mockAudioHandler.play()).called(1);
        },
      );

      blocTest<PlayerBloc, PlayerState>(
        'SeekEvent calls seek',
        build: () {
          when(() => mockAudioHandler.seek(any())).thenAnswer((_) async {});
          return playerBloc;
        },
        act: (bloc) => bloc.add(const SeekEvent(Duration(seconds: 10))),
        verify: (_) {
          verify(() => mockAudioHandler.seek(const Duration(seconds: 10))).called(1);
        },
      );

      blocTest<PlayerBloc, PlayerState>(
        'SkipNextEvent calls skipToNext',
        build: () {
          when(() => mockAudioHandler.skipToNext()).thenAnswer((_) async {});
          return playerBloc;
        },
        act: (bloc) => bloc.add(SkipNextEvent()),
        verify: (_) {
          verify(() => mockAudioHandler.skipToNext()).called(1);
        },
      );

      blocTest<PlayerBloc, PlayerState>(
        'SkipPreviousEvent calls skipToPrevious',
        build: () {
          when(() => mockAudioHandler.skipToPrevious()).thenAnswer((_) async {});
          return playerBloc;
        },
        act: (bloc) => bloc.add(SkipPreviousEvent()),
        verify: (_) {
          verify(() => mockAudioHandler.skipToPrevious()).called(1);
        },
      );
    });

    group('Internal Events (AudioHandler Updates)', () {
      final mediaItem = const MediaItem(id: '1', title: 'Song 1');

      test('emits state with new MediaItem when AudioHandler updates mediaItem', () async {
        final expectedState = const PlayerState().copyWith(
          currentSong: mediaItem,
          duration: Duration.zero,
        );

        expectLater(playerBloc.stream, emits(expectedState));
        mediaItemController.add(mediaItem);
      });

      test('emits state with isPlaying/isBuffering when AudioHandler updates playbackState', () async {
         final playbackState = PlaybackState(
           playing: true,
           processingState: AudioProcessingState.buffering
         );

         final expectedState = const PlayerState(
           isPlaying: true,
           isBuffering: true,
         );

         expectLater(playerBloc.stream, emits(expectedState));
         playbackStateController.add(playbackState);
      });

      test('emits state with new position when position stream updates', () async {
        final position = const Duration(seconds: 5);
        final expectedState = PlayerState(position: position);

        expectLater(playerBloc.stream, emits(expectedState));
        positionController.add(position);
      });

      test('emits state with new queue when AudioHandler updates queue', () async {
        final queue = [
          const MediaItem(id: '1', title: 'Song 1'),
          const MediaItem(id: '2', title: 'Song 2'),
        ];

        final expectedState = const PlayerState().copyWith(queue: queue);

        expectLater(playerBloc.stream, emits(expectedState));
        queueController.add(queue);
      });
    });
  });
}
