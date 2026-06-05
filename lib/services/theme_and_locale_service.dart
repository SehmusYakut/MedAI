import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeAndLocaleService extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _appLocaleKey = 'app_locale';
  static const String _seenOnboardingKey = 'seen_onboarding';

  final SharedPreferences _prefs;
  late ThemeMode _themeMode;
  late Locale _locale;

  ThemeAndLocaleService(this._prefs) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    final themeStr = _prefs.getString(_themeModeKey) ?? 'light';
    _themeMode = themeStr == 'dark' ? ThemeMode.dark : ThemeMode.light;

    final localeStr = _prefs.getString(_appLocaleKey) ?? 'en';
    _locale = Locale(localeStr);
  }

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isDark => _themeMode == ThemeMode.dark;
  bool get seenOnboarding => _prefs.getBool(_seenOnboardingKey) ?? false;

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(_themeModeKey, mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _prefs.setString(_appLocaleKey, locale.languageCode);
    notifyListeners();
  }

  Future<void> setSeenOnboarding(bool value) async {
    await _prefs.setBool(_seenOnboardingKey, value);
    notifyListeners();
  }
}
