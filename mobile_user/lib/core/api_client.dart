import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'constants.dart';
import 'storage.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;
  ApiException(this.message, this.statusCode, [this.errors]);

  @override
  String toString() => message;
}

/// Central HTTP client that handles auth headers and the
/// `{ success, message, data }` response envelope.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  Map<String, String> _headers({bool json = true}) {
    final headers = <String, String>{'Accept': 'application/json'};
    if (json) headers['Content-Type'] = 'application/json';
    final token = Storage.token;
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    return Uri.parse('${AppConfig.apiUrl}$path').replace(
      queryParameters: query?.map((k, v) => MapEntry(k, '$v')),
    );
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final res = await http.get(_uri(path, query), headers: _headers());
    return _process(res);
  }

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    final res = await http.post(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body ?? {}),
    );
    return _process(res);
  }

  /// Like [post] but returns the full `{ success, message, data }` envelope
  /// so callers can show the server-provided message.
  Future<ApiResult> postFull(String path, [Map<String, dynamic>? body]) async {
    final res = await http.post(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body ?? {}),
    );
    _ensureOk(res);
    final map = res.body.isNotEmpty
        ? jsonDecode(res.body) as Map<String, dynamic>
        : <String, dynamic>{};
    return ApiResult(map['message']?.toString() ?? '', map['data']);
  }

  /// Multipart upload (used for application photo and avatar).
  Future<ApiResult> upload(
    String path, {
    required Map<String, String> fields,
    File? file,
    String fileField = 'photo',
  }) async {
    final request = http.MultipartRequest('POST', _uri(path));
    request.headers.addAll(_headers(json: false));
    request.fields.addAll(fields);
    if (file != null) {
      request.files.add(await http.MultipartFile.fromPath(fileField, file.path));
    }
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    final body = _ensureOk(res);
    return ApiResult(body['message']?.toString() ?? '', body['data']);
  }

  dynamic _process(http.Response res) {
    final body = _ensureOk(res);
    return body['data'];
  }

  Map<String, dynamic> _ensureOk(http.Response res) {
    final Map<String, dynamic> body =
        res.body.isNotEmpty ? jsonDecode(res.body) as Map<String, dynamic> : {};

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }

    throw ApiException(
      body['message']?.toString() ?? 'Xatolik yuz berdi',
      res.statusCode,
      body['errors'] is Map ? Map<String, dynamic>.from(body['errors']) : null,
    );
  }
}

class ApiResult {
  final String message;
  final dynamic data;
  ApiResult(this.message, this.data);
}
