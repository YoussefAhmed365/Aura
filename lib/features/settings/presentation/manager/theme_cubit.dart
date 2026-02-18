import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences _prefs;
  static const String _themeKey = 'theme_mode';

  ThemeCubit(this._prefs) : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final themeString = _prefs.getString(_themeKey);
    if (themeString != null) {
      final themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeString,
        orElse: () => ThemeMode.system,
      );
      emit(themeMode);
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    await _prefs.setString(_themeKey, mode.toString());
    emit(mode);
  }
}
