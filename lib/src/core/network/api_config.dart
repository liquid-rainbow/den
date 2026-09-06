class ApiConfig {
  /// The base URL for all API requests.
  /// 
  /// By default, it falls back to a standard local development IP.
  /// In production, this must be overridden during build time using:
  /// `flutter build apk --dart-define=API_URL=https://api.den-app.com`
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://192.168.0.9:5000',
  );

  /// Connection timeout for HTTP requests
  static const Duration connectTimeout = Duration(seconds: 10);
  
  /// Receive timeout for HTTP requests
  static const Duration receiveTimeout = Duration(seconds: 10);
  
  /// Whether the app is running in mock mode to bypass network requests
  static const bool isMockMode = bool.fromEnvironment('MOCK_MODE', defaultValue: false);
}
