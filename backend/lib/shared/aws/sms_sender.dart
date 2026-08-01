import 'package:den_backend/config/env.dart';

abstract class SmsSender {
  Future<void> sendOtp(String phoneNumber, String code);
}

/// ============================================================================
/// PLACEHOLDER STUB IMPLEMENTATION: ConsoleSmsSender
/// ============================================================================
/// WHAT IT DOES: Logs the 6-digit OTP code to stdout console for local testing.
/// WHAT REAL AWS IMPLEMENTATION MUST DO: Use AWS SNS SDK (or Twilio SDK) to
/// send a transactional SMS message containing the 6-digit verification code.
/// SECURITY CONSTRAINT: Must NEVER be instantiated or executed in production.
/// ============================================================================
class ConsoleSmsSender implements SmsSender {
  ConsoleSmsSender() {
    if (Env.isProduction) {
      throw StateError(
        'SECURITY CRITICAL: ConsoleSmsSender stub cannot be initialized in production environment!',
      );
    }
  }

  @override
  Future<void> sendOtp(String phoneNumber, String code) async {
    if (Env.isProduction) {
      throw StateError(
        'SECURITY CRITICAL: ConsoleSmsSender stub attempted execution in production path!',
      );
    }
    print('[DEV SMS STUB] Send OTP "$code" to phone "$phoneNumber"');
  }
}
