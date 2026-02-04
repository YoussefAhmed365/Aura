import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/presentation/widgets/song_player_screen.dart';

void main() {
  testWidgets('SongPlayerScreen slider performance benchmark', (WidgetTester tester) async {
    // Set a large enough size to avoid overflow
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 3.0;

    // Build the widget
    await tester.pumpWidget(
      const MaterialApp(
        home: SongPlayerScreen(),
      ),
    );

    final sliderFinder = find.byType(Slider);
    expect(sliderFinder, findsOneWidget);

    final stopwatch = Stopwatch()..start();

    // Benchmark loop
    const int iterations = 5000;
    for (int i = 0; i < iterations; i++) {
        final Slider slider = tester.widget(sliderFinder);
        // Toggle value to force rebuild
        double newValue = (i % 100).toDouble();
        if (newValue != slider.value) {
           slider.onChanged?.call(newValue);
        }
        await tester.pump();
    }

    stopwatch.stop();
    // ignore: avoid_print
    print('Benchmark: ${stopwatch.elapsedMilliseconds}ms for $iterations rebuilds');
  });
}
