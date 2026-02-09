import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  static const String _prefKey = 'selected_locale';
  static final LocaleService _instance = LocaleService._internal();

  factory LocaleService() => _instance;
  LocaleService._internal();

  Locale? _locale;

  /// Returns null when using system default, otherwise the user-selected locale.
  Locale? get locale => _locale;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);
    if (code != null) {
      _locale = Locale(code);
    }
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefKey);
    } else {
      await prefs.setString(_prefKey, locale.languageCode);
    }
    notifyListeners();
  }
}
