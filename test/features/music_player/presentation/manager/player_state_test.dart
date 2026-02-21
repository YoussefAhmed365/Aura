import 'package:audio_service/audio_service.dart';
import 'package:aura/features/music_player/presentation/manager/player_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayerState', () {
    test('default constructor has correct initial values', () {
      const state = PlayerState();

      expect(state.currentSong, isNull);
      expect(state.currentIndex, 0);
      expect(state.queue, isEmpty);
      expect(state.isPlaying, false);
      expect(state.position, Duration.zero);
      expect(state.duration, Duration.zero);
      expect(state.isBuffering, false);
    });

    group('copyWith', () {
      const mediaItem = MediaItem(id: '1', title: 'Song 1', artist: 'Artist');

      test('returns identical state when no arguments are passed', () {
        const original = PlayerState(
          currentIndex: 2,
          isPlaying: true,
          position: Duration(seconds: 30),
          duration: Duration(minutes: 3),
          isBuffering: true,
        );

        final copy = original.copyWith();

        expect(copy, original);
      });

      test('overrides currentSong', () {
        const state = PlayerState();
        final copy = state.copyWith(currentSong: mediaItem);

        expect(copy.currentSong, mediaItem);
        // Other fields remain unchanged
        expect(copy.currentIndex, 0);
        expect(copy.isPlaying, false);
      });

      test('overrides currentIndex', () {
        const state = PlayerState();
        final copy = state.copyWith(currentIndex: 5);

        expect(copy.currentIndex, 5);
        expect(copy.currentSong, isNull);
      });

      test('overrides queue', () {
        const state = PlayerState();
        final queue = [mediaItem, const MediaItem(id: '2', title: 'Song 2')];
        final copy = state.copyWith(queue: queue);

        expect(copy.queue, queue);
        expect(copy.queue.length, 2);
      });

      test('overrides isPlaying', () {
        const state = PlayerState();
        final copy = state.copyWith(isPlaying: true);

        expect(copy.isPlaying, true);
      });

      test('overrides position', () {
        const state = PlayerState();
        final copy = state.copyWith(position: const Duration(seconds: 42));

        expect(copy.position, const Duration(seconds: 42));
      });

      test('overrides duration', () {
        const state = PlayerState();
        final copy = state.copyWith(duration: const Duration(minutes: 4));

        expect(copy.duration, const Duration(minutes: 4));
      });

      test('overrides isBuffering', () {
        const state = PlayerState();
        final copy = state.copyWith(isBuffering: true);

        expect(copy.isBuffering, true);
      });

      test('overrides multiple fields at once', () {
        const state = PlayerState();
        final copy = state.copyWith(
          currentSong: mediaItem,
          currentIndex: 3,
          isPlaying: true,
          position: const Duration(seconds: 10),
          duration: const Duration(minutes: 5),
          isBuffering: false,
        );

        expect(copy.currentSong, mediaItem);
        expect(copy.currentIndex, 3);
        expect(copy.isPlaying, true);
        expect(copy.position, const Duration(seconds: 10));
        expect(copy.duration, const Duration(minutes: 5));
        expect(copy.isBuffering, false);
      });
    });

    group('equality (props)', () {
      test('two default states are equal', () {
        const state1 = PlayerState();
        const state2 = PlayerState();

        expect(state1, state2);
      });

      test('states with same values are equal', () {
        const mediaItem = MediaItem(id: '1', title: 'Song');
        final state1 = const PlayerState().copyWith(
          currentSong: mediaItem,
          currentIndex: 1,
          isPlaying: true,
        );
        final state2 = const PlayerState().copyWith(
          currentSong: mediaItem,
          currentIndex: 1,
          isPlaying: true,
        );

        expect(state1, state2);
      });

      test('states with different isPlaying are not equal', () {
        final state1 = const PlayerState().copyWith(isPlaying: true);
        final state2 = const PlayerState().copyWith(isPlaying: false);

        expect(state1, isNot(state2));
      });

      test('states with different position are not equal', () {
        final state1 = const PlayerState().copyWith(
          position: const Duration(seconds: 10),
        );
        final state2 = const PlayerState().copyWith(
          position: const Duration(seconds: 20),
        );

        expect(state1, isNot(state2));
      });

      test('states with different currentSong are not equal', () {
        final state1 = const PlayerState().copyWith(
          currentSong: const MediaItem(id: '1', title: 'Song 1'),
        );
        final state2 = const PlayerState().copyWith(
          currentSong: const MediaItem(id: '2', title: 'Song 2'),
        );

        expect(state1, isNot(state2));
      });
    });
  });
}
