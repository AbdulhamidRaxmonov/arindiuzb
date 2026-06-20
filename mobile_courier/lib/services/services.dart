import '../core/api_client.dart';
import '../models/models.dart';

final _api = ApiClient.instance;

class CourierService {
  static Future<({String token, Courier courier})> login(
      String phone, String password) async {
    final res = await _api.post('/login', {'phone': phone, 'password': password});
    final data = Map<String, dynamic>.from(res.data);
    return (
      token: data['token'] as String,
      courier: Courier.fromJson(Map<String, dynamic>.from(data['courier'])),
    );
  }

  static Future<Courier> me() async {
    final res = await _api.get('/me');
    return Courier.fromJson(Map<String, dynamic>.from(res.data));
  }

  static Future<void> logout() => _api.post('/logout');

  static Future<List<Application>> applications({String? status}) async {
    final res = await _api.get('/applications',
        query: status != null ? {'status': status} : null);
    final items = (res.data['data'] as List?) ?? [];
    return items
        .map((e) => Application.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<ApiResult> accept(int id) => _api.post('/applications/$id/accept');

  static Future<ApiResult> complete(int id,
      {String? comment, double? weightKg}) {
    return _api.post('/applications/$id/complete', {
      if (comment != null) 'courier_comment': comment,
      if (weightKg != null) 'weight_kg': weightKg,
    });
  }
}
