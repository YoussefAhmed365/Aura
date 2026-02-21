import 'package:aura/features/music_player/presentation/manager/player_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MockSongModel extends Mock implements SongModel {}

void main() {
  group('PlayerEvent', () {
    group('PlayAllEvent', () {
      test('supports value equality with same songs and index', () {
        final song = MockSongModel();
        final event1 = PlayAllEvent(songs: [song], index: 0);
        final event2 = PlayAllEvent(songs: [song], index: 0);

        expect(event1, event2);
      });

      test('is not equal when index differs', () {
        final song = MockSongModel();
        final event1 = PlayAllEvent(songs: [song], index: 0);
        final event2 = PlayAllEvent(songs: [song], index: 1);

        expect(event1, isNot(event2));
      });

      test('is not equal when songs differ', () {
        final song1 = MockSongModel();
        final song2 = MockSongModel();
        final event1 = PlayAllEvent(songs: [song1], index: 0);
        final event2 = PlayAllEvent(songs: [song2], index: 0);

        expect(event1, isNot(event2));
      });

      test('props contain songs and index', () {
        final song = MockSongModel();
        final event = PlayAllEvent(songs: [song], index: 3);

        expect(event.props, [
          [song],
          3,
        ]);
      });
    });

    group('PlayPauseEvent', () {
      test('supports value equality', () {
        final event1 = PlayPauseEvent();
        final event2 = PlayPauseEvent();

        expect(event1, event2);
      });

      test('props is empty list', () {
        expect(PlayPauseEvent().props, []);
      });
    });

    group('SeekEvent', () {
      test('supports value equality with same position', () {
        const event1 = SeekEvent(Duration(seconds: 10));
        const event2 = SeekEvent(Duration(seconds: 10));

        expect(event1, event2);
      });

      test('is not equal when position differs', () {
        const event1 = SeekEvent(Duration(seconds: 10));
        const event2 = SeekEvent(Duration(seconds: 20));

        expect(event1, isNot(event2));
      });

      test('props contain position', () {
        const event = SeekEvent(Duration(seconds: 42));

        expect(event.props, [const Duration(seconds: 42)]);
      });
    });

    group('SkipNextEvent', () {
      test('supports value equality', () {
        final event1 = SkipNextEvent();
        final event2 = SkipNextEvent();

        expect(event1, event2);
      });
    });

    group('SkipPreviousEvent', () {
      test('supports value equality', () {
        final event1 = SkipPreviousEvent();
        final event2 = SkipPreviousEvent();

        expect(event1, event2);
      });
    });
  });
}
