import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/services.dart';
import 'api_client.dart';

class AppState extends ChangeNotifier {
  Courier? courier;
  bool loading = true;

  bool get isLoggedIn => ApiClient.instance.token != null;

  Future<void> bootstrap() async {
    if (ApiClient.instance.token != null) {
      try {
        courier = await CourierService.me();
      } catch (_) {
        await ApiClient.instance.setToken(null);
      }
    }
    loading = false;
    notifyListeners();
  }

  Future<void> onLoggedIn(String token, Courier c) async {
    await ApiClient.instance.setToken(token);
    courier = c;
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await CourierService.logout();
    } catch (_) {}
    await ApiClient.instance.setToken(null);
    courier = null;
    notifyListeners();
  }
}
