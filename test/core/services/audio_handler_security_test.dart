import 'package:audio_service/audio_service.dart';
import 'package:aura/core/services/audio_handler.dart';
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

  late AuraAudioHandler audioHandler;
  late MockAudioPlayer mockPlayer;
  late MockConcatenatingAudioSource mockPlaylist;

  setUp(() {
    mockPlayer = MockAudioPlayer();
    mockPlaylist = MockConcatenatingAudioSource();

    when(() => mockPlayer.playbackEventStream).thenAnswer((_) => Stream.empty());
    when(() => mockPlayer.positionStream).thenAnswer((_) => Stream.empty());
    when(() => mockPlayer.currentIndexStream).thenAnswer((_) => Stream.empty());
    when(() => mockPlayer.sequenceStateStream).thenAnswer((_) => Stream.empty());
    when(() => mockPlayer.playingStream).thenAnswer((_) => Stream.empty());
    when(() => mockPlayer.setAudioSource(any())).thenAnswer((_) async => null);
    when(() => mockPlayer.playbackEvent).thenReturn(PlaybackEvent(
      processingState: ProcessingState.idle,
      updateTime: DateTime.now(),
      updatePosition: Duration.zero,
      bufferedPosition: Duration.zero,
      currentIndex: 0,
    ));

    audioHandler = AuraAudioHandler(player: mockPlayer, playlist: mockPlaylist);
  });

  group('AuraAudioHandler Security - _safeParseUri via updateQueue', () {
    test('allows valid http URIs', () async {
      final mediaItems = [
        const MediaItem(id: '1', title: 'Song 1', extras: {'url': 'http://example.com/song.mp3'}),
      ];

      // We need to capture the AudioSource passed to addAll
      List<AudioSource>? capturedSources;
      when(() => mockPlaylist.addAll(any())).thenAnswer((invocation) async {
        capturedSources = invocation.positionalArguments[0] as List<AudioSource>;
      });
      when(() => mockPlaylist.clear()).thenAnswer((_) async {});

      await audioHandler.updateQueue(mediaItems);

      expect(capturedSources, isNotNull);
      expect(capturedSources![0], isA<UriAudioSource>());
      expect((capturedSources![0] as UriAudioSource).uri.toString(), 'http://example.com/song.mp3');
    });

    test('allows valid file URIs', () async {
      final mediaItems = [
        const MediaItem(id: '1', title: 'Song 1', extras: {'url': 'file:///storage/emulated/0/Music/song.mp3'}),
      ];

      List<AudioSource>? capturedSources;
      when(() => mockPlaylist.addAll(any())).thenAnswer((invocation) async {
        capturedSources = invocation.positionalArguments[0] as List<AudioSource>;
      });
      when(() => mockPlaylist.clear()).thenAnswer((_) async {});

      await audioHandler.updateQueue(mediaItems);

      expect(capturedSources![0], isA<UriAudioSource>());
      expect((capturedSources![0] as UriAudioSource).uri.toString(), 'file:///storage/emulated/0/Music/song.mp3');
    });

    test('rejects invalid schemes (javascript)', () async {
      final mediaItems = [
        const MediaItem(id: '1', title: 'Exploit', extras: {'url': 'javascript:alert(1)'}),
      ];

      List<AudioSource>? capturedSources;
      when(() => mockPlaylist.addAll(any())).thenAnswer((invocation) async {
        capturedSources = invocation.positionalArguments[0] as List<AudioSource>;
      });
      when(() => mockPlaylist.clear()).thenAnswer((_) async {});

      await audioHandler.updateQueue(mediaItems);

      expect((capturedSources![0] as UriAudioSource).uri.toString(), 'about:blank');
    });

    test('rejects directory traversal in file paths', () async {
      final mediaItems = [
        const MediaItem(id: '1', title: 'Exploit', extras: {'url': 'file:///storage/emulated/0/Music/../../../etc/passwd'}),
      ];

      List<AudioSource>? capturedSources;
      when(() => mockPlaylist.addAll(any())).thenAnswer((invocation) async {
        capturedSources = invocation.positionalArguments[0] as List<AudioSource>;
      });
      when(() => mockPlaylist.clear()).thenAnswer((_) async {});

      await audioHandler.updateQueue(mediaItems);

      expect((capturedSources![0] as UriAudioSource).uri.toString(), 'about:blank');
    });

    test('rejects directory traversal even if normalized by Uri.parse', () async {
      // Some parsers might normalize "a/../b" to "b"
      // Our implementation checks both normalized path and raw string
      final mediaItems = [
        const MediaItem(id: '1', title: 'Exploit', extras: {'url': '/safe/path/../../etc/shadow'}),
      ];

      List<AudioSource>? capturedSources;
      when(() => mockPlaylist.addAll(any())).thenAnswer((invocation) async {
        capturedSources = invocation.positionalArguments[0] as List<AudioSource>;
      });
      when(() => mockPlaylist.clear()).thenAnswer((_) async {});

      await audioHandler.updateQueue(mediaItems);

      expect((capturedSources![0] as UriAudioSource).uri.toString(), 'about:blank');
    });
  });
}
