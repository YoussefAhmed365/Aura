import 'package:aura/features/music_player/presentation/manager/player_bloc.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PlayerState Equality Check Performance Benchmark', () {
    // Setup
    final int itemCount = 10000;
    final List<MediaItem> queue = List.generate(
      itemCount,
      (index) => MediaItem(
        id: 'id_$index',
        album: 'Album $index',
        title: 'Title $index',
      ),
    );

    // Scenario 1: Identical List Instance (should be fast)
    // Simulates typical position update where queue instance is reused
    final state1 = PlayerState(queue: queue, position: const Duration(seconds: 10));
    final state2 = state1.copyWith(position: const Duration(seconds: 20));

    final stopwatch1 = Stopwatch()..start();
    for (int i = 0; i < 10000; i++) {
      final bool _ = state1 == state2;
    }
    stopwatch1.stop();
    print('Benchmark: Identical List Instance (10k items, 10k iterations): ${stopwatch1.elapsedMilliseconds}ms');

    // Scenario 2: Different List Instance (Same Content) (should be slow without optimization)
    // Simulates a state update where queue is copied or recreated
    final List<MediaItem> queueCopy = List.from(queue);
    final state3 = PlayerState(queue: queueCopy, position: const Duration(seconds: 10)); // Same content as state1

    final stopwatch2 = Stopwatch()..start();
    // Fewer iterations because O(N) is slow
    // With optimization, this should become O(1) and very fast.
    // Without optimization, this triggers deep comparison of 10k items 100 times.
    for (int i = 0; i < 10000; i++) {
      final bool _ = state1 == state3;
    }
    stopwatch2.stop();
    print('Benchmark: Different List Instance (10k items, 10000 iterations): ${stopwatch2.elapsedMilliseconds}ms');
  });
}
