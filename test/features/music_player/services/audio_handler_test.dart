import 'package:aura/features/music_player/services/audio_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

// ignore: deprecated_member_use
class MockConcatenatingAudioSource extends Mock implements ConcatenatingAudioSource {}

class FakeAudioSource extends Fake implements AudioSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAudioSource());
  });

  late MyAudioHandler audioHandler;
  late MockAudioPlayer mockPlayer;
  late MockConcatenatingAudioSource mockPlaylist;

  setUp(() {
    mockPlayer = MockAudioPlayer();
    mockPlaylist = MockConcatenatingAudioSource();

    // Stub streams to avoid null errors in constructor
    when(() => mockPlayer.playbackEventStream).thenAnswer((_) => Stream.empty());
    when(() => mockPlayer.positionStream).thenAnswer((_) => Stream.empty());
    when(() => mockPlayer.currentIndexStream).thenAnswer((_) => Stream.empty());
    when(() => mockPlayer.sequenceStateStream).thenAnswer((_) => Stream.empty());

    // Stub properties accessed in constructor or initial logic
    when(() => mockPlayer.setAudioSource(any())).thenAnswer((_) async => null);

    // Stub other properties that might be accessed
    when(() => mockPlayer.playing).thenReturn(false);
    when(() => mockPlayer.processingState).thenReturn(ProcessingState.idle);
    when(() => mockPlayer.position).thenReturn(Duration.zero);
    when(() => mockPlayer.bufferedPosition).thenReturn(Duration.zero);
    when(() => mockPlayer.speed).thenReturn(1.0);

    // Stub seek and play
    when(() => mockPlayer.seek(any(), index: any(named: 'index'))).thenAnswer((_) async {});
    when(() => mockPlayer.play()).thenAnswer((_) async {});

    // Stub playlist length default
    when(() => mockPlaylist.length).thenReturn(0);

    audioHandler = MyAudioHandler(player: mockPlayer, playlist: mockPlaylist);
  });

  group('skipToQueueItem', () {
    test('does nothing when index is negative', () async {
      when(() => mockPlaylist.length).thenReturn(5);

      await audioHandler.skipToQueueItem(-1);

      verifyNever(() => mockPlayer.seek(any(), index: any(named: 'index')));
      verifyNever(() => mockPlayer.play());
    });

    test('does nothing when index is greater than or equal to playlist length', () async {
      when(() => mockPlaylist.length).thenReturn(5);

      await audioHandler.skipToQueueItem(5);

      verifyNever(() => mockPlayer.seek(any(), index: any(named: 'index')));
      verifyNever(() => mockPlayer.play());
    });

    test('calls seek and play when index is valid', () async {
      when(() => mockPlaylist.length).thenReturn(5);
      when(() => mockPlayer.playing).thenReturn(false); // Ensure play() is called

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
}
