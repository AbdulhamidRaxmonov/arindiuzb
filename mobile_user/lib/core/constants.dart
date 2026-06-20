class AppConfig {
  /// Base URL of the Laravel backend. For Android emulator use 10.0.2.2,
  /// for iOS simulator use localhost, for a real device use your LAN IP.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static String get apiUrl => '$baseUrl/api';

  static const int pricePerKg = 300;
  static const int minWithdrawal = 15000;
}

class AppColors {
  static const int primaryValue = 0xFF16A34A;
}
