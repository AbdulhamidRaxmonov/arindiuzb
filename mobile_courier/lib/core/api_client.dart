import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
  @override
  String toString() => message;
}

class ApiResult {
  final String message;
  final dynamic data;
  ApiResult(this.message, this.data);
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const _kToken = 'courier_token';
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String? get token => _prefs.getString(_kToken);
  Future<void> setToken(String? value) async {
    if (value == null) {
      await _prefs.remove(_kToken);
    } else {
      await _prefs.setString(_kToken, value);
    }
  }

  Map<String, String> get _headers {
    final h = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final t = token;
    if (t != null) h['Authorization'] = 'Bearer $t';
    return h;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) =>
      Uri.parse('${AppConfig.apiUrl}$path')
          .replace(queryParameters: query?.map((k, v) => MapEntry(k, '$v')));

  Future<ApiResult> get(String path, {Map<String, dynamic>? query}) async {
    final res = await http.get(_uri(path, query), headers: _headers);
    return _process(res);
  }

  Future<ApiResult> post(String path, [Map<String, dynamic>? body]) async {
    final res =
        await http.post(_uri(path), headers: _headers, body: jsonEncode(body ?? {}));
    return _process(res);
  }

  ApiResult _process(http.Response res) {
    final Map<String, dynamic> body =
        res.body.isNotEmpty ? jsonDecode(res.body) as Map<String, dynamic> : {};
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return ApiResult(body['message']?.toString() ?? '', body['data']);
    }
    throw ApiException(
      body['message']?.toString() ?? 'Xatolik yuz berdi',
      res.statusCode,
    );
  }
}
