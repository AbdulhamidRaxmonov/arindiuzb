import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/services.dart';
import 'storage.dart';

class AppState extends ChangeNotifier {
  AppUser? _user;
  bool _loading = true;
  Locale _locale = Locale(Storage.language);
  ThemeMode _themeMode = Storage.darkMode ? ThemeMode.dark : ThemeMode.light;

  AppUser? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => Storage.token != null;
  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  Future<void> bootstrap() async {
    if (Storage.token != null) {
      try {
        _user = await ProfileService.me();
        _applyUserPrefs();
      } catch (_) {
        await Storage.setToken(null);
      }
    }
    _loading = false;
    notifyListeners();
  }

  void _applyUserPrefs() {
    if (_user == null) return;
    _locale = Locale(_user!.language);
    _themeMode = _user!.darkMode ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> onLoggedIn(String token, AppUser user) async {
    await Storage.setToken(token);
    _user = user;
    _applyUserPrefs();
    notifyListeners();
  }

  Future<void> refreshUser() async {
    _user = await ProfileService.me();
    notifyListeners();
  }

  void setUser(AppUser user) {
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await AuthService.logout();
    } catch (_) {}
    await Storage.setToken(null);
    _user = null;
    notifyListeners();
  }

  Future<void> setLocale(String code) async {
    _locale = Locale(code);
    await Storage.setLanguage(code);
    notifyListeners();
    try {
      _user = await ProfileService.update({'language': code});
    } catch (_) {}
  }

  Future<void> toggleDarkMode(bool value) async {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    await Storage.setDarkMode(value);
    notifyListeners();
    try {
      _user = await ProfileService.update({'dark_mode': value ? '1' : '0'});
    } catch (_) {}
  }
}
