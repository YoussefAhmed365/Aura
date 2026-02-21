import 'package:aura/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Prevent GoogleFonts from making HTTP requests during tests
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AppTheme', () {
    // Use testWidgets instead of test since GoogleFonts triggers async font
    // loading. testWidgets can handle the async work properly.

    group('lightTheme', () {
      testWidgets('uses Material 3', (tester) async {
        expect(AppTheme.lightTheme.useMaterial3, true);
      });

      testWidgets('has light brightness color scheme', (tester) async {
        expect(AppTheme.lightTheme.colorScheme.brightness, Brightness.light);
      });

      testWidgets('color scheme is properly generated', (tester) async {
        expect(AppTheme.lightTheme.colorScheme, isNotNull);
        expect(AppTheme.lightTheme.colorScheme.primary, isNotNull);
      });
    });

    group('darkTheme', () {
      testWidgets('uses Material 3', (tester) async {
        expect(AppTheme.darkTheme.useMaterial3, true);
      });

      testWidgets('has dark brightness color scheme', (tester) async {
        expect(AppTheme.darkTheme.colorScheme.brightness, Brightness.dark);
      });

      testWidgets('has pure black scaffold background', (tester) async {
        expect(
          AppTheme.darkTheme.scaffoldBackgroundColor,
          const Color(0xFF000000),
        );
      });

      testWidgets('color scheme is properly generated', (tester) async {
        expect(AppTheme.darkTheme.colorScheme, isNotNull);
        expect(AppTheme.darkTheme.colorScheme.primary, isNotNull);
      });
    });

    group('consistency', () {
      testWidgets('light and dark themes have different brightness', (
        tester,
      ) async {
        expect(
          AppTheme.lightTheme.colorScheme.brightness,
          isNot(AppTheme.darkTheme.colorScheme.brightness),
        );
      });

      testWidgets('both themes have non-null text themes', (tester) async {
        expect(AppTheme.lightTheme.textTheme, isNotNull);
        expect(AppTheme.darkTheme.textTheme, isNotNull);
      });
    });
  });
}
