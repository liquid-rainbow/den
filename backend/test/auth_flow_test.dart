import 'package:den_backend/config/database.dart';
import 'package:den_backend/config/env.dart';
import 'package:den_backend/modules/auth/auth_service.dart';
import 'package:den_backend/shared/aws/sms_sender.dart';
import 'package:den_backend/shared/security_utils.dart';
import 'package:test/test.dart';

class CapturingSmsSender implements SmsSender {
  String? lastPhoneNumber;
  String? lastCode;

  @override
  Future<void> sendOtp(String phoneNumber, String code) async {
    lastPhoneNumber = phoneNumber;
    lastCode = code;
  }
}

void main() {
  late CapturingSmsSender smsSender;
  late AuthService authService;

  setUpAll(() async {
    Env.load();
    await Database.initialize();
  });

  tearDownAll(() async {
    await Database.close();
  });

  setUp(() {
    smsSender = CapturingSmsSender();
    authService = AuthService(smsSender: smsSender);
  });

  test('Full Auth Flow: send-otp -> verify-otp creates user & session in DB', () async {
    final testPhone = '+919998887776';

    final sendResult = await authService.sendOtp(testPhone);
    expect(sendResult.success, isTrue);
    expect(smsSender.lastPhoneNumber, equals(testPhone));
    expect(smsSender.lastCode, isNotNull);
    expect(smsSender.lastCode!.length, equals(6));

    final capturedCode = smsSender.lastCode!;

    final verifyResult = await authService.verifyOtp(testPhone, capturedCode);
    expect(verifyResult.success, isTrue);
    expect(verifyResult.sessionToken, isNotNull);
    expect(verifyResult.user, isNotNull);
    expect(verifyResult.user!['phoneNumber'], equals(testPhone));
    expect(verifyResult.user!['status'], equals('pending_onboarding'));
    expect(verifyResult.user!['isVerified'], isFalse);

    final rawToken = verifyResult.sessionToken!;
    final tokenHash = SecurityUtils.hashSha256(rawToken);

    final pool = Database.pool;
    final sessionCheck = await pool.execute(
      r'SELECT id, user_id FROM user_sessions WHERE session_token_hash = $1',
      parameters: [tokenHash],
    );

    expect(sessionCheck.isNotEmpty, isTrue);
    expect(sessionCheck.first[1].toString(), equals(verifyResult.user!['id']));

    // Clean up
    await pool.execute('DELETE FROM users WHERE phone_number = \$1', parameters: [testPhone]);
    await pool.execute('DELETE FROM auth_otps WHERE phone_number = \$1', parameters: [testPhone]);
  });

  test('Existing user verify-otp second time: no duplicate row inserted, same user_id returned', () async {
    final testPhone = '+919876543211';

    // First login flow
    await authService.sendOtp(testPhone);
    final code1 = smsSender.lastCode!;
    final firstVerify = await authService.verifyOtp(testPhone, code1);
    expect(firstVerify.success, isTrue);
    final originalUserId = firstVerify.user!['id'];

    // Second login flow for the same phone number
    await authService.sendOtp(testPhone);
    final code2 = smsSender.lastCode!;
    final secondVerify = await authService.verifyOtp(testPhone, code2);
    expect(secondVerify.success, isTrue);
    final secondUserId = secondVerify.user!['id'];

    // Confirm exact same user_id returned
    expect(secondUserId, equals(originalUserId));

    // Confirm only 1 user row exists for this phone number
    final pool = Database.pool;
    final userRows = await pool.execute(
      r'SELECT COUNT(*) FROM users WHERE phone_number = $1',
      parameters: [testPhone],
    );
    expect((userRows.first[0] as num).toInt(), equals(1));

    // Clean up
    await pool.execute('DELETE FROM users WHERE phone_number = \$1', parameters: [testPhone]);
    await pool.execute('DELETE FROM auth_otps WHERE phone_number = \$1', parameters: [testPhone]);
  });

  test('Rate Limiting: 4th send-otp request within the same hour is rejected', () async {
    final testPhone = '+919111222333';

    // Send 3 requests (allowed)
    final res1 = await authService.sendOtp(testPhone);
    final res2 = await authService.sendOtp(testPhone);
    final res3 = await authService.sendOtp(testPhone);

    expect(res1.success, isTrue);
    expect(res2.success, isTrue);
    expect(res3.success, isTrue);

    // 4th request (should be rejected)
    final res4 = await authService.sendOtp(testPhone);
    expect(res4.success, isFalse);
    expect(res4.message, contains('Too many OTP requests'));

    // Clean up
    final pool = Database.pool;
    await pool.execute('DELETE FROM auth_otps WHERE phone_number = \$1', parameters: [testPhone]);
  });

  test('Incorrect or expired OTP code on verify: request is rejected', () async {
    final testPhone = '+919000011111';

    await authService.sendOtp(testPhone);

    // Attempt verify with wrong code
    final verifyResult = await authService.verifyOtp(testPhone, '000000');
    expect(verifyResult.success, isFalse);
    expect(verifyResult.message, equals('Invalid or expired verification code.'));
    expect(verifyResult.sessionToken, isNull);

    // Clean up
    final pool = Database.pool;
    await pool.execute('DELETE FROM auth_otps WHERE phone_number = \$1', parameters: [testPhone]);
  });
}
