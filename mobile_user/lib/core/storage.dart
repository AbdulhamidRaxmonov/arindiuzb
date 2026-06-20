import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences for auth token & settings.
class Storage {
  static const _kToken = 'auth_token';
  static const _kLang = 'language';
  static const _kDark = 'dark_mode';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? get token => _prefs.getString(_kToken);
  static Future<void> setToken(String? value) async {
    if (value == null) {
      await _prefs.remove(_kToken);
    } else {
      await _prefs.setString(_kToken, value);
    }
  }

  static String get language => _prefs.getString(_kLang) ?? 'uz';
  static Future<void> setLanguage(String value) =>
      _prefs.setString(_kLang, value);

  static bool get darkMode => _prefs.getBool(_kDark) ?? false;
  static Future<void> setDarkMode(bool value) =>
      _prefs.setBool(_kDark, value);
}
