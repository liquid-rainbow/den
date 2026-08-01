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

    // 1. Call sendOtp
    final sendResult = await authService.sendOtp(testPhone);
    expect(sendResult.success, isTrue);
    expect(smsSender.lastPhoneNumber, equals(testPhone));
    expect(smsSender.lastCode, isNotNull);
    expect(smsSender.lastCode!.length, equals(6));

    final capturedCode = smsSender.lastCode!;

    // 2. Call verifyOtp with captured code
    final verifyResult = await authService.verifyOtp(testPhone, capturedCode);
    expect(verifyResult.success, isTrue);
    expect(verifyResult.sessionToken, isNotNull);
    expect(verifyResult.user, isNotNull);
    expect(verifyResult.user!['phoneNumber'], equals(testPhone));
    expect(verifyResult.user!['status'], equals('pending_verification'));
    expect(verifyResult.user!['isVerified'], isFalse);

    // 3. Verify Database Session entry exists with SHA-256 hashed token
    final rawToken = verifyResult.sessionToken!;
    final tokenHash = SecurityUtils.hashSha256(rawToken);

    final pool = Database.pool;
    final sessionCheck = await pool.execute(
      r'SELECT id, user_id FROM user_sessions WHERE session_token_hash = $1',
      parameters: [tokenHash],
    );

    expect(sessionCheck.isNotEmpty, isTrue);
    expect(sessionCheck.first[1].toString(), equals(verifyResult.user!['id']));

    // Clean up test data
    await pool.execute('DELETE FROM users WHERE phone_number = \$1', parameters: [testPhone]);
    await pool.execute('DELETE FROM auth_otps WHERE phone_number = \$1', parameters: [testPhone]);
  });
}
