class Courier {
  final int id;
  final String name;
  final String phone;

  Courier({required this.id, required this.name, required this.phone});

  factory Courier.fromJson(Map<String, dynamic> j) => Courier(
        id: j['id'] as int,
        name: j['name'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
      );
}

class Application {
  final int id;
  final String type;
  final double weightKg;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? comment;
  final String? photoUrl;
  final String status;
  final double estimatedAmount;
  final String? courierComment;
  final String userName;
  final String userPhone;
  final DateTime createdAt;

  Application({
    required this.id,
    required this.type,
    required this.weightKg,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.comment,
    required this.photoUrl,
    required this.status,
    required this.estimatedAmount,
    required this.courierComment,
    required this.userName,
    required this.userPhone,
    required this.createdAt,
  });

  factory Application.fromJson(Map<String, dynamic> j) {
    final user = j['user'] as Map<String, dynamic>?;
    return Application(
      id: j['id'] as int,
      type: j['type'] as String,
      weightKg: double.tryParse('${j['weight_kg']}') ?? 0,
      address: j['address'] as String? ?? '',
      latitude: j['latitude'] != null ? double.tryParse('${j['latitude']}') : null,
      longitude: j['longitude'] != null ? double.tryParse('${j['longitude']}') : null,
      comment: j['comment'] as String?,
      photoUrl: j['photo_url'] as String?,
      status: j['status'] as String,
      estimatedAmount: double.tryParse('${j['estimated_amount']}') ?? 0,
      courierComment: j['courier_comment'] as String?,
      userName: user?['name'] as String? ?? 'Foydalanuvchi',
      userPhone: user?['phone'] as String? ?? '',
      createdAt: DateTime.tryParse('${j['created_at']}') ?? DateTime.now(),
    );
  }
}
