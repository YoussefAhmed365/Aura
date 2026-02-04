import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/presentation/pages/home_page.dart';

void main() {
  testWidgets('HomePage builds only visible items with CustomScrollView', (WidgetTester tester) async {
    // Save original favorites to restore later
    final originalFavorites = List<Map<String, dynamic>>.from(favorites);
    addTearDown(() {
      favorites.clear();
      favorites.addAll(originalFavorites);
    });

    // Setup: Populate favorites with many items to demonstrate the issue
    favorites.clear();
    for (int i = 0; i < 1000; i++) {
      favorites.add({
        "name": "Song $i",
        "author": "Artist $i",
        "album": "Album $i",
        "duration": "3:00"
      });
    }

    // Set a large surface size to ensure we aren't just limited by screen size
    // (although with shrinkWrap in SingleChildScrollView, it should build all regardless of screen height)
    // But to be realistic, we use a standard phone size.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HomePage(),
        ),
      ),
    );

    // With CustomScrollView and SliverList, only visible items (plus cache) should be built.
    // We expect to find significantly fewer than 1000 ListTiles (likely < 20).
    expect(find.byType(ListTile), findsWidgets);
    expect(tester.widgetList(find.byType(ListTile)).length, lessThanOrEqualTo(20));
  });
}
