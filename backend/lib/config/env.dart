import 'dart:io';
import 'package:dotenv/dotenv.dart';

class Env {
  static void load() {
    final file = File('.env');
    if (file.existsSync()) {
      final dotenv = DotEnv()..load(['.env']);
      _environment = dotenv['ENVIRONMENT'] ?? _environment;
      _port = int.tryParse(dotenv['PORT'] ?? '') ?? _port;
      _dbHost = dotenv['DB_HOST'] ?? _dbHost;
      _dbPort = int.tryParse(dotenv['DB_PORT'] ?? '') ?? _dbPort;
      _dbName = dotenv['DB_NAME'] ?? _dbName;
      _dbUser = dotenv['DB_USER'] ?? _dbUser;
      _dbPassword = dotenv['DB_PASSWORD'] ?? _dbPassword;
      if (dotenv['ALLOWED_ORIGINS'] != null) {
        _allowedOrigins = dotenv['ALLOWED_ORIGINS']!
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    // System Environment Variables take precedence if explicitly set
    if (Platform.environment.containsKey('ENVIRONMENT')) {
      _environment = Platform.environment['ENVIRONMENT']!;
    }
    if (Platform.environment.containsKey('ALLOWED_ORIGINS')) {
      _allowedOrigins = Platform.environment['ALLOWED_ORIGINS']!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    _environment = _environment.trim();
  }

  static String _environment = Platform.environment['ENVIRONMENT']?.trim() ?? 'development';
  static int _port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 5000;

  static String _dbHost = Platform.environment['DB_HOST'] ?? 'localhost';
  static int _dbPort = int.tryParse(Platform.environment['DB_PORT'] ?? '') ?? 5434;
  static String _dbName = Platform.environment['DB_NAME'] ?? 'den_db';
  static String _dbUser = Platform.environment['DB_USER'] ?? 'den_user';
  static String _dbPassword = Platform.environment['DB_PASSWORD'] ?? 'den_password';

  static List<String> _allowedOrigins = [
    'http://localhost:3000',
    'http://localhost:5000',
    'http://localhost:8080',
  ];

  static String get environment => _environment;
  static bool get isProduction => _environment.toLowerCase() == 'production';
  static int get port => _port;

  static String get dbHost => _dbHost;
  static int get dbPort => _dbPort;
  static String get dbName => _dbName;
  static String get dbUser => _dbUser;
  static String get dbPassword => _dbPassword;

  static List<String> get allowedOrigins => _allowedOrigins;
}
