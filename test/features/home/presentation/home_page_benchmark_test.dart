import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:aura/features/home/presentation/home_page.dart';

void main() {
  testWidgets('HomePage Benchmark', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < 50; i++) {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: HomePage())));
      await tester.pumpAndSettle();
    }

    stopwatch.stop();
    // ignore: avoid_print
    print('Baseline build time for 50 HomePage creations: ${stopwatch.elapsedMilliseconds}ms');
  });
}
