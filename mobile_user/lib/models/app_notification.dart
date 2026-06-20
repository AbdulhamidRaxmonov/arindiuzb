class AppNotification {
  final int id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        type: json['type'] as String? ?? 'info',
        isRead: json['is_read'] == true || json['is_read'] == 1,
        createdAt: DateTime.tryParse('${json['created_at']}') ?? DateTime.now(),
      );
}
