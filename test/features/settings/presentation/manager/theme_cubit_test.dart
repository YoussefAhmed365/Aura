import 'package:aura/features/settings/presentation/manager/theme_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. إنشاء كلاس Mock لـ SharedPreferences
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late ThemeCubit themeCubit;
  late MockSharedPreferences mockPrefs;

  // 2. هذه الدالة تعمل قبل كل اختبار (test) لتجهيز بيئة نظيفة
  setUp(() {
    mockPrefs = MockSharedPreferences();

    // إخبار الـ Mock ماذا يفعل عندما يتم استدعاء getString
    when(() => mockPrefs.getString('theme_mode')).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

    themeCubit = ThemeCubit(mockPrefs);
  });

  // 3. هذه الدالة تعمل بعد كل اختبار لتنظيف الذاكرة
  tearDown(() {
    themeCubit.close();
  });

  group('ThemeCubit Tests', () {
    test('الحالة الابتدائية يجب أن تكون ThemeMode.system', () {
      expect(themeCubit.state, ThemeMode.system);
    });

    // استخدام blocTest من حزمة bloc_test
    blocTest<ThemeCubit, ThemeMode>(
      'يجب أن يُصدر ThemeMode.dark عند استدعاء setTheme(ThemeMode.dark)',
      build: () => themeCubit,
      act: (cubit) => cubit.setTheme(ThemeMode.dark),
      expect: () => [ThemeMode.dark], // الحالات المتوقع إصدارها بالترتيب
      verify: (_) {
        // التأكد من أن التطبيق قام بحفظ القيمة في الـ SharedPreferences
        verify(
          () => mockPrefs.setString('theme_mode', ThemeMode.dark.toString()),
        ).called(1);
      },
    );

    blocTest<ThemeCubit, ThemeMode>(
      'يجب أن يُصدر ThemeMode.light عند استدعاء setTheme(ThemeMode.light)',
      build: () => themeCubit,
      act: (cubit) => cubit.setTheme(ThemeMode.light),
      expect: () => [ThemeMode.light],
      verify: (_) {
        verify(
          () => mockPrefs.setString('theme_mode', ThemeMode.light.toString()),
        ).called(1);
      },
    );

    test('يجب أن يحمّل ThemeMode.dark من SharedPreferences عند التهيئة', () {
      final darkPrefs = MockSharedPreferences();
      when(
        () => darkPrefs.getString('theme_mode'),
      ).thenReturn(ThemeMode.dark.toString());
      when(
        () => darkPrefs.setString(any(), any()),
      ).thenAnswer((_) async => true);

      final cubit = ThemeCubit(darkPrefs);

      expect(cubit.state, ThemeMode.dark);
      cubit.close();
    });

    test('يجب أن يحمّل ThemeMode.light من SharedPreferences عند التهيئة', () {
      final lightPrefs = MockSharedPreferences();
      when(
        () => lightPrefs.getString('theme_mode'),
      ).thenReturn(ThemeMode.light.toString());
      when(
        () => lightPrefs.setString(any(), any()),
      ).thenAnswer((_) async => true);

      final cubit = ThemeCubit(lightPrefs);

      expect(cubit.state, ThemeMode.light);
      cubit.close();
    });

    test(
      'يجب أن يرجع إلى ThemeMode.system إذا كانت القيمة المحفوظة غير صالحة',
      () {
        final badPrefs = MockSharedPreferences();
        when(
          () => badPrefs.getString('theme_mode'),
        ).thenReturn('invalid_value');
        when(
          () => badPrefs.setString(any(), any()),
        ).thenAnswer((_) async => true);

        final cubit = ThemeCubit(badPrefs);

        expect(cubit.state, ThemeMode.system);
        cubit.close();
      },
    );
  });
}
