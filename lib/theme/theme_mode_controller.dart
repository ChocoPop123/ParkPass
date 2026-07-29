import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeController extends ValueNotifier<ThemeMode> {
  // Default to light mode for debugging to see if it fixes the black screen
  ThemeModeController() : super(ThemeMode.light);

  static const _prefsKey = 'parkpass_theme_mode';

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      if (saved == 'dark') {
        value = ThemeMode.dark;
      } else if (saved == 'light') {
        value = ThemeMode.light;
      } else {
        value = ThemeMode.light;
      }
    } catch (e) {
      value = ThemeMode.light;
    }
  }

  Future<void> setDark(bool isDark) async {
    value = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, isDark ? 'dark' : 'light');
  }

  static final instance = ThemeModeController();
}
