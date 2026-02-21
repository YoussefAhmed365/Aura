import 'package:audio_service/audio_service.dart';
import 'package:aura/features/music_player/services/audio_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

// ignore: deprecated_member_use
class MockConcatenatingAudioSource extends Mock
    implements ConcatenatingAudioSource {}

class FakeAudioSource extends Fake implements AudioSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAudioSource());
    registerFallbackValue(Duration.zero);
  });

  late MyAudioHandler audioHandler;
  late MockAudioPlayer mockPlayer;
  late MockConcatenatingAudioSource mockPlaylist;

  setUp(() {
    mockPlayer = MockAudioPlayer();
    mockPlaylist = MockConcatenatingAudioSource();

    // Stub streams to avoid null errors in constructor
    when(
      () => mockPlayer.playbackEventStream,
    ).thenAnswer((_) => Stream.empty());
    when(() => mockPlayer.positionStream).thenAnswer((_) => Stream.empty());
    when(() => mockPlayer.currentIndexStream).thenAnswer((_) => Stream.empty());
    when(
      () => mockPlayer.sequenceStateStream,
    ).thenAnswer((_) => Stream.empty());

    // Stub properties accessed in constructor or initial logic
    when(() => mockPlayer.setAudioSource(any())).thenAnswer((_) async => null);

    // Stub other properties that might be accessed
    when(() => mockPlayer.playing).thenReturn(false);
    when(() => mockPlayer.processingState).thenReturn(ProcessingState.idle);
    when(() => mockPlayer.position).thenReturn(Duration.zero);
    when(() => mockPlayer.bufferedPosition).thenReturn(Duration.zero);
    when(() => mockPlayer.speed).thenReturn(1.0);

    // Stub seek and play
    when(
      () => mockPlayer.seek(any(), index: any(named: 'index')),
    ).thenAnswer((_) async {});
    when(() => mockPlayer.play()).thenAnswer((_) async {});
    when(() => mockPlayer.pause()).thenAnswer((_) async {});
    when(() => mockPlayer.stop()).thenAnswer((_) async {});
    when(() => mockPlayer.seek(any())).thenAnswer((_) async {});
    when(() => mockPlayer.seekToNext()).thenAnswer((_) async {});
    when(() => mockPlayer.seekToPrevious()).thenAnswer((_) async {});

    // Stub playlist length default
    when(() => mockPlaylist.length).thenReturn(0);
    when(() => mockPlaylist.clear()).thenAnswer((_) async {});
    when(() => mockPlaylist.addAll(any())).thenAnswer((_) async {});

    audioHandler = MyAudioHandler(player: mockPlayer, playlist: mockPlaylist);
  });

  group('skipToQueueItem', () {
    test('does nothing when index is negative', () async {
      when(() => mockPlaylist.length).thenReturn(5);

      await audioHandler.skipToQueueItem(-1);

      verifyNever(() => mockPlayer.seek(any(), index: any(named: 'index')));
      verifyNever(() => mockPlayer.play());
    });

    test(
      'does nothing when index is greater than or equal to playlist length',
      () async {
        when(() => mockPlaylist.length).thenReturn(5);

        await audioHandler.skipToQueueItem(5);

        verifyNever(() => mockPlayer.seek(any(), index: any(named: 'index')));
        verifyNever(() => mockPlayer.play());
      },
    );

    test('calls seek and play when index is valid', () async {
      when(() => mockPlaylist.length).thenReturn(5);
      when(
        () => mockPlayer.playing,
      ).thenReturn(false); // Ensure play() is called

      await audioHandler.skipToQueueItem(2);

      verify(() => mockPlayer.seek(Duration.zero, index: 2)).called(1);
      verify(() => mockPlayer.play()).called(1);
    });

    test('calls seek but skips play if already playing', () async {
      when(() => mockPlaylist.length).thenReturn(5);
      when(() => mockPlayer.playing).thenReturn(true);

      await audioHandler.skipToQueueItem(2);

      verify(() => mockPlayer.seek(Duration.zero, index: 2)).called(1);
      verifyNever(() => mockPlayer.play());
    });
  });

  group('Playback Controls', () {
    test('play() delegates to AudioPlayer.play()', () async {
      await audioHandler.play();

      verify(() => mockPlayer.play()).called(1);
    });

    test('pause() delegates to AudioPlayer.pause()', () async {
      await audioHandler.pause();

      verify(() => mockPlayer.pause()).called(1);
    });

    test(
      'seek() delegates to AudioPlayer.seek() with correct position',
      () async {
        const position = Duration(seconds: 30);
        await audioHandler.seek(position);

        verify(() => mockPlayer.seek(position)).called(1);
      },
    );

    test('skipToNext() delegates to AudioPlayer.seekToNext()', () async {
      await audioHandler.skipToNext();

      verify(() => mockPlayer.seekToNext()).called(1);
    });

    test(
      'skipToPrevious() delegates to AudioPlayer.seekToPrevious()',
      () async {
        await audioHandler.skipToPrevious();

        verify(() => mockPlayer.seekToPrevious()).called(1);
      },
    );

    test('stop() delegates to AudioPlayer.stop()', () async {
      await audioHandler.stop();

      verify(() => mockPlayer.stop()).called(1);
    });
  });

  group('customAction (Favorites)', () {
    test('sets isFavorite to true when actionAddFavorite is called', () async {
      expect(audioHandler.isFavorite, false);

      await audioHandler.customAction(MyAudioHandler.actionAddFavorite);

      expect(audioHandler.isFavorite, true);
    });

    test(
      'sets isFavorite to false when actionRemoveFavorite is called',
      () async {
        // First set it to true
        audioHandler.isFavorite = true;
        expect(audioHandler.isFavorite, true);

        await audioHandler.customAction(MyAudioHandler.actionRemoveFavorite);

        expect(audioHandler.isFavorite, false);
      },
    );

    test('does nothing for unknown action name', () async {
      audioHandler.isFavorite = false;

      await audioHandler.customAction('unknown_action');

      expect(audioHandler.isFavorite, false);
    });
  });

  group('Queue Management', () {
    test('updateQueue clears playlist and adds new items', () async {
      final mediaItems = [
        const MediaItem(
          id: '1',
          title: 'Song 1',
          extras: {'uri': 'file:///song1.mp3'},
        ),
        const MediaItem(
          id: '2',
          title: 'Song 2',
          extras: {'uri': 'file:///song2.mp3'},
        ),
      ];

      await audioHandler.updateQueue(mediaItems);

      verify(() => mockPlaylist.clear()).called(1);
      verify(() => mockPlaylist.addAll(any())).called(1);
    });

    test('addQueueItems appends items without clearing', () async {
      final mediaItems = [
        const MediaItem(
          id: '1',
          title: 'Song 1',
          extras: {'uri': 'file:///song1.mp3'},
        ),
      ];

      await audioHandler.addQueueItems(mediaItems);

      verifyNever(() => mockPlaylist.clear());
      verify(() => mockPlaylist.addAll(any())).called(1);
    });
  });
}
