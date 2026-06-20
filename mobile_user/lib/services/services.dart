import 'dart:io';

import '../core/api_client.dart';
import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/application.dart';
import '../models/category.dart';
import '../models/withdrawal.dart';

final _api = ApiClient.instance;

class AuthService {
  /// Requests an OTP. Returns the debug code in non-production environments.
  static Future<String?> requestOtp(String phone) async {
    final data = await _api.post('/auth/request-otp', {'phone': phone});
    return data?['debug_code']?.toString();
  }

  static Future<({String token, AppUser user})> verifyOtp(
      String phone, String code, String? name) async {
    final data = await _api.post('/auth/verify-otp', {
      'phone': phone,
      'code': code,
      if (name != null && name.isNotEmpty) 'name': name,
    });
    return (
      token: data['token'] as String,
      user: AppUser.fromJson(Map<String, dynamic>.from(data['user'])),
    );
  }

  static Future<void> logout() => _api.post('/auth/logout');
}

class ProfileService {
  static Future<AppUser> me() async {
    final data = await _api.get('/profile');
    return AppUser.fromJson(Map<String, dynamic>.from(data));
  }

  static Future<AppUser> update(Map<String, String> fields, {File? avatar}) async {
    final res = await _api.upload('/profile', fields: fields, file: avatar, fileField: 'avatar');
    return AppUser.fromJson(Map<String, dynamic>.from(res.data));
  }

  static Future<Map<String, dynamic>> balance() async {
    final data = await _api.get('/balance');
    return Map<String, dynamic>.from(data);
  }
}

class CategoryService {
  static Future<List<WasteCategory>> list() async {
    final data = await _api.get('/categories');
    return (data['categories'] as List)
        .map((e) => WasteCategory.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

class ApplicationService {
  static Future<List<Application>> list() async {
    final data = await _api.get('/applications');
    final items = data['data'] as List? ?? [];
    return items
        .map((e) => Application.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<ApiResult> create({
    required String type,
    required double weightKg,
    required String address,
    double? latitude,
    double? longitude,
    String? comment,
    File? photo,
  }) {
    return _api.upload('/applications', fields: {
      'type': type,
      'weight_kg': '$weightKg',
      'address': address,
      if (latitude != null) 'latitude': '$latitude',
      if (longitude != null) 'longitude': '$longitude',
      if (comment != null) 'comment': comment,
    }, file: photo);
  }

  static Future<void> cancel(int id) => _api.post('/applications/$id/cancel');
}

class WithdrawalService {
  static Future<List<Withdrawal>> list() async {
    final data = await _api.get('/withdrawals');
    final items = data['data'] as List? ?? [];
    return items
        .map((e) => Withdrawal.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<ApiResult> create({
    required double amount,
    required String cardNumber,
    required String cardHolder,
  }) {
    return _api.postFull('/withdrawals', {
      'amount': amount,
      'card_number': cardNumber,
      'card_holder': cardHolder,
    });
  }
}

class NotificationService {
  static Future<(List<AppNotification>, int)> list() async {
    final data = await _api.get('/notifications');
    final items = (data['notifications']?['data'] as List?) ?? [];
    final unread = data['unread_count'] as int? ?? 0;
    return (
      items
          .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      unread
    );
  }

  static Future<void> markAllRead() => _api.post('/notifications/read-all');
}
