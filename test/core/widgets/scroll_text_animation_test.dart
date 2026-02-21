import 'package:aura/core/widgets/scroll_text_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScrollingText Widget', () {
    testWidgets('renders text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: ScrollingText(text: 'Short text'),
            ),
          ),
        ),
      );

      expect(find.text('Short text'), findsOneWidget);
    });

    testWidgets('does not scroll when text fits', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500, // Large width to ensure fit
              child: ScrollingText(text: 'Short text'),
            ),
          ),
        ),
      );

      // Allow layout to settle.
      // Note: pumpAndSettle might timeout if animation starts unexpectedly,
      // but here we expect no animation.
      await tester.pumpAndSettle();

      // Verify ScrollController position is 0
      final scrollFinder = find.byType(SingleChildScrollView);
      final scrollable = tester.widget<SingleChildScrollView>(scrollFinder);
      expect(scrollable.controller!.offset, 0.0);
    });

    testWidgets('scrolls when text overflows', (WidgetTester tester) async {
      // Create a long text
      const longText =
          'This is a very very very very very very long text that should definitely overflow the container width';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100, // Small width to force overflow
              child: ScrollingText(text: longText),
            ),
          ),
        ),
      );

      // Allow layout to settle and animation to start
      // Frame 1: Build
      await tester.pump();
      // Frame 2: PostFrameCallback runs _checkAndAnimate
      await tester.pump();

      // Check initial position
      final scrollFinder = find.byType(SingleChildScrollView);
      SingleChildScrollView scrollable =
      tester.widget<SingleChildScrollView>(scrollFinder);
      expect(scrollable.controller!.offset, 0.0);

      // Advance animation by 10 seconds (half of 20s cycle)
      await tester.pump(const Duration(seconds: 10));

      scrollable = tester.widget<SingleChildScrollView>(scrollFinder);
      // It should have scrolled some amount
      expect(scrollable.controller!.offset, greaterThan(0.0));

      // We cannot use pumpAndSettle here because the animation repeats indefinitely
    });

    testWidgets('handles Arabic text correctly (RTL)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: ScrollingText(text: 'مرحبا بكم'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the Directionality widget inside ScrollingText
      // ScrollingText wraps its content in Directionality
      final directionalityFinder = find.descendant(
        of: find.byType(ScrollingText),
        matching: find.byType(Directionality),
      );

      final directionality = tester.widget<Directionality>(directionalityFinder);

      expect(directionality.textDirection, TextDirection.rtl);
    });

    testWidgets('handles English text correctly (LTR)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: ScrollingText(text: 'Hello World'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final directionalityFinder = find.descendant(
        of: find.byType(ScrollingText),
        matching: find.byType(Directionality),
      );

      final directionality = tester.widget<Directionality>(directionalityFinder);

      expect(directionality.textDirection, TextDirection.ltr);
    });

    testWidgets('respects isMiniPlayer flag for height', (WidgetTester tester) async {
      // Mini player = true
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: ScrollingText(text: 'Text', isMiniPlayer: true)),
          ),
        ),
      );

      // The outer SizedBox in ScrollingText sets the height
      // We can find it by finding the immediate child of ScrollingText if possible,
      // or looking for a SizedBox with specific height, but let's be robust.
      // ScrollingText build method returns a SizedBox.

      // Let's find the SizedBox that wraps the Directionality
      final _ = find.ancestor(
        of: find.byType(Directionality),
        matching: find.byType(SizedBox),
      ).first; // There might be others up the tree, but the closest one should be it.

      // Actually, standard find.byType(SizedBox) finds many.
      // Let's rely on the fact that ScrollingText *is* a StatefulWidget, and its build returns SizedBox.
      // But we can't easily "find return value of build".

      // We can inspect the render object size of the ScrollingText widget itself?
      // No, ScrollingText is a StatefulWidget, it doesn't have a size itself, its render object comes from its child.

      final scrollingTextFinder = find.byType(ScrollingText);
      final sizeMini = tester.getSize(scrollingTextFinder);
      expect(sizeMini.height, 28.0);

      // Mini player = false
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: ScrollingText(text: 'Text', isMiniPlayer: false)),
          ),
        ),
      );

      final sizeNormal = tester.getSize(scrollingTextFinder);
      expect(sizeNormal.height, 40.0);
    });

    testWidgets('resets animation when text changes', (WidgetTester tester) async {
      const text1 = 'Text 1 that is long enough to scroll definitely';
      const text2 = 'Text 2 that is also long enough to scroll definitely';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              child: ScrollingText(text: text1),
            ),
          ),
        ),
      );

      await tester.pump(); // Build
      await tester.pump(); // Start animation

      await tester.pump(const Duration(seconds: 5));

      final scrollFinder = find.byType(SingleChildScrollView);
      final scrollable1 = tester.widget<SingleChildScrollView>(scrollFinder);
      final offset1 = scrollable1.controller!.offset;
      expect(offset1, greaterThan(0));

      // Update widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              child: ScrollingText(text: text2),
            ),
          ),
        ),
      );

      // It should reset. The didUpdateWidget calls _animationController.reset()
      // But it also schedules _checkAndAnimate.

      // Immediately after update, animation should be reset?
      // didUpdateWidget -> reset().

      await tester.pump(); // Build (and didUpdateWidget)

      // We need to check if offset is 0.
      // Note: _scrollController.jumpTo(_animation.value) happens in listener.
      // If animation is reset, value is 0.

      final scrollable2 = tester.widget<SingleChildScrollView>(scrollFinder);
      // Wait, scroll controller might not have jumped yet if listener didn't fire?
      // But reset() might notify listeners?

      // Let's see if we can check if it starts from 0 again.
      // We expect it to restart.

      await tester.pump(const Duration(milliseconds: 100));
      final offset2 = scrollable2.controller!.offset;

      // It should be near 0, definitely less than where it was (5 seconds in)
      // 5 seconds in is 25% of 20s.
      // 100ms is < 1%.

      expect(offset2, lessThan(offset1));
    });
  });
}