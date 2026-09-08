import 'dart:convert';
import 'package:den_backend/config/env.dart';
import 'package:http/http.dart' as http;

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

class TwilioSmsSender implements SmsSender {
  @override
  Future<void> sendOtp(String phoneNumber, String code) async {
    final accountSid = Env.twilioAccountSid;
    final authToken = Env.twilioAuthToken;
    final fromNumber = Env.twilioFromNumber;

    if (accountSid.isEmpty || authToken.isEmpty || fromNumber.isEmpty) {
      throw StateError('Twilio credentials are not configured in environment variables.');
    }

    final url = Uri.parse('https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json');
    final credentials = base64Encode(utf8.encode('$accountSid:$authToken'));

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'To': phoneNumber,
        'From': fromNumber,
        'Body': 'Your DEN verification code is $code',
      },
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to send SMS via Twilio: ${response.statusCode} - ${response.body}');
    }
  }
}
