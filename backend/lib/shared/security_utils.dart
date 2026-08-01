import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class SecurityUtils {
  static String hashSha256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static String generateRandomToken([int length = 32]) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static String generate6DigitOtp() {
    final random = Random.secure();
    final otp = random.nextInt(900000) + 100000;
    return otp.toString();
  }
}
