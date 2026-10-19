import 'package:flutter/foundation.dart';

class ApiConfig {
  static const _override = String.fromEnvironment('DEN_API_BASE_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5001';
    }
    return 'http://localhost:5001';
  }
}
