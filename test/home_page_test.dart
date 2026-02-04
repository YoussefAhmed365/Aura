import 'package:flutter_test/flutter_test.dart';
import 'package:aura/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('HomePage compiles and renders', (WidgetTester tester) async {
    // Set a large enough surface to avoid overflow in tests, or rely on scrolling
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: HomePage())));

    // Clear any previous overflows if they were transient (unlikely for static layout)
    // Actually changing physicalSize requires reset on tearDown usually, but this is a one-off test file.

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Chill Hits'), findsOneWidget);
    expect(find.text('My Playlist'), findsOneWidget);
  });
}
