class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static String get apiUrl => '$baseUrl/api/courier';
}

class AppColors {
  static const int primary = 0xFF0EA5E9; // sky-blue to distinguish from user app
}
