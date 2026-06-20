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
  final double creditedAmount;
  final double estimatedAmount;
  final String? courierComment;
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
    required this.creditedAmount,
    required this.estimatedAmount,
    required this.courierComment,
    required this.createdAt,
  });

  factory Application.fromJson(Map<String, dynamic> json) => Application(
        id: json['id'] as int,
        type: json['type'] as String,
        weightKg: double.tryParse('${json['weight_kg']}') ?? 0,
        address: json['address'] as String? ?? '',
        latitude: json['latitude'] != null
            ? double.tryParse('${json['latitude']}')
            : null,
        longitude: json['longitude'] != null
            ? double.tryParse('${json['longitude']}')
            : null,
        comment: json['comment'] as String?,
        photoUrl: json['photo_url'] as String?,
        status: json['status'] as String,
        creditedAmount: double.tryParse('${json['credited_amount']}') ?? 0,
        estimatedAmount: double.tryParse('${json['estimated_amount']}') ?? 0,
        courierComment: json['courier_comment'] as String?,
        createdAt: DateTime.tryParse('${json['created_at']}') ?? DateTime.now(),
      );
}
