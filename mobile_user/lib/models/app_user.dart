class AppUser {
  final int id;
  final String? name;
  final String phone;
  final double balance;
  final String language;
  final bool darkMode;
  final String? avatar;

  AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.balance,
    required this.language,
    required this.darkMode,
    this.avatar,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as int,
        name: json['name'] as String?,
        phone: json['phone'] as String,
        balance: double.tryParse('${json['balance']}') ?? 0,
        language: (json['language'] as String?) ?? 'uz',
        darkMode: json['dark_mode'] == true || json['dark_mode'] == 1,
        avatar: json['avatar'] as String?,
      );
}
