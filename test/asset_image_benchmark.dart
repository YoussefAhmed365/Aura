import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Benchmark AssetImage creation', () {
    const int iterations = 1000000;

    // Baseline: Creating new AssetImage every time
    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      // Simulate what happens in the loop: creating a new object from a string
      final img = AssetImage('assets/images/cover-1.jpg');
    }
    stopwatch.stop();
    final baselineTime = stopwatch.elapsedMilliseconds;
    print('Creating $iterations AssetImages took: ${baselineTime}ms');

    // Optimization: Reusing const AssetImage
    stopwatch.reset();
    stopwatch.start();
    const cachedImg = AssetImage('assets/images/cover-1.jpg');
    for (int i = 0; i < iterations; i++) {
      // Simulate accessing a pre-created object
      final img = cachedImg;
    }
    stopwatch.stop();
    final optimizedTime = stopwatch.elapsedMilliseconds;
    print('Reusing const AssetImage took: ${optimizedTime}ms');

    print('Improvement: ${(baselineTime / optimizedTime).toStringAsFixed(2)}x faster');
  });
}
