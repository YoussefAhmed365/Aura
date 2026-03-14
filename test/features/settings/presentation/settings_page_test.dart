import 'package:aura/features/settings/presentation/manager/theme_cubit.dart';
import 'package:aura/features/settings/presentation/settings_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MockThemeCubit extends MockCubit<ThemeMode> implements ThemeCubit {}

void main() {
  late MockThemeCubit mockThemeCubit;

  setUpAll(() {
    registerFallbackValue(ThemeMode.system);
    PackageInfo.setMockInitialValues(
      appName: 'Aura',
      packageName: 'com.codev.aura',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: 'buildSignature',
    );
  });

  setUp(() {
    mockThemeCubit = MockThemeCubit();
    when(() => mockThemeCubit.state).thenReturn(ThemeMode.system);
  });

  Widget buildSettingsPage() {
    return BlocProvider<ThemeCubit>.value(
      value: mockThemeCubit,
      child: const MaterialApp(
        home: Scaffold(
          body: SettingsPage(),
        ),
      ),
    );
  }

  group('SettingsPage Widget Tests', () {
    testWidgets('renders all main sections correctly', (tester) async {
      await tester.pumpWidget(buildSettingsPage());

      // Theme Section
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Theme Mode'), findsOneWidget);
      expect(find.text('System Default'), findsOneWidget);

      // Playback Section
      expect(find.text('Playback'), findsOneWidget);
      expect(find.text('Crossfade'), findsOneWidget);
      expect(find.text('Equalizer'), findsOneWidget);
      expect(find.text('Gapless Playback'), findsOneWidget);

      // Scroll to the bottom to ensure the "About" section is visible
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // About Section
      expect(find.text('About'), findsOneWidget);
      expect(find.text('About Aura'), findsOneWidget);
      expect(find.text('Version & Licenses'), findsOneWidget);
    });

    testWidgets('opens theme dialog and changes theme', (tester) async {
      when(() => mockThemeCubit.setTheme(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildSettingsPage());

      // Tap Theme Mode tile
      await tester.tap(find.text('Theme Mode'));
      await tester.pumpAndSettle(); // Wait for dialog to open

      // Verify dialog options
      expect(find.text('Choose Theme'), findsOneWidget);
      expect(find.text('System Default'), findsWidgets);
      expect(find.text('Light Mode'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);

      // Tap Dark Mode option
      await tester.tap(find.text('Dark Mode'));
      await tester.pumpAndSettle(); // Wait for dialog to close

      // Verify setTheme was called with ThemeMode.dark
      verify(() => mockThemeCubit.setTheme(ThemeMode.dark)).called(1);

      // Dialog should be closed
      expect(find.text('Choose Theme'), findsNothing);
    });

    testWidgets('opens about dialog and displays mock package info', (tester) async {
      await tester.pumpWidget(buildSettingsPage());

      // Scroll to the bottom to ensure the "About" section is visible
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Tap About Aura tile
      await tester.tap(find.text('About Aura'));
      await tester.pumpAndSettle(); // Wait for Future (PackageInfo) and dialog

      // Verify dialog appears with correct mocked info
      expect(find.text('Aura Music Player'), findsOneWidget);
      expect(find.text('Version: 1.0.0'), findsOneWidget);
      expect(find.text('Build Number: 1'), findsOneWidget);
      expect(find.text('A stylish music player built with Flutter.'), findsOneWidget);

      // Tap Close button
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle(); // Wait for dialog to close

      // Verify dialog is closed
      expect(find.text('Aura Music Player'), findsNothing);
    });
  });
}
