import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final PreferencesService _preferencesService;

  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('id');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  SettingsViewModel(this._preferencesService) {
    _loadSettings();
  }

  void _loadSettings() {
    final theme = _preferencesService.getTheme();
    _themeMode = theme == 'dark' ? ThemeMode.dark : ThemeMode.light;

    final lang = _preferencesService.getLanguage();
    _locale = Locale(lang);

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _preferencesService.saveTheme(
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _preferencesService.saveLanguage(locale.languageCode);
    notifyListeners();
  }
}
