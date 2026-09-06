import 'package:den_backend/config/database.dart';
import 'package:den_backend/shared/aws/sms_sender.dart';
import 'package:den_backend/shared/security_utils.dart';

class AuthResult {
  final bool success;
  final String message;
  final String? sessionToken;
  final Map<String, dynamic>? user;

  const AuthResult({
    required this.success,
    required this.message,
    this.sessionToken,
    this.user,
  });
}

class AuthService {
  final SmsSender _smsSender;

  AuthService({required SmsSender smsSender}) : _smsSender = smsSender;

  Future<AuthResult> sendOtp(String phoneNumber) async {
    // Validate E.164 phone format
    final cleanPhone = phoneNumber.trim();
    if (!RegExp(r'^\+[1-9]\d{1,14}$').hasMatch(cleanPhone)) {
      return const AuthResult(
        success: false,
        message: 'Invalid phone number format. Must be E.164 format (e.g. +919876543210).',
      );
    }

    final pool = Database.pool;

    // Rate Limit Check: max 3 OTP requests per phone number in the last 1 hour
    final countResult = await pool.execute(
      r"SELECT COUNT(*) FROM auth_otps WHERE phone_number = $1 AND created_at > (CURRENT_TIMESTAMP - INTERVAL '1 hour')",
      parameters: [cleanPhone],
    );

    final attemptsInLastHour = (countResult.first[0] as num).toInt();
    if (attemptsInLastHour >= 3) {
      return const AuthResult(
        success: false,
        message: 'Too many OTP requests. Maximum 3 attempts per hour allowed.',
      );
    }

    final otpCode = SecurityUtils.generate6DigitOtp();
    final otpHash = SecurityUtils.hashSha256(otpCode);

    // Insert hashed OTP into auth_otps table
    await pool.execute(
      r"INSERT INTO auth_otps (phone_number, otp_hash, expires_at) VALUES ($1, $2, CURRENT_TIMESTAMP + INTERVAL '5 minutes')",
      parameters: [cleanPhone, otpHash],
    );

    // Send OTP via SMS sender stub
    await _smsSender.sendOtp(cleanPhone, otpCode);

    return const AuthResult(
      success: true,
      message: 'Verification code sent if the phone number can receive messages.',
    );
  }

  Future<AuthResult> verifyOtp(String phoneNumber, String code) async {
    final cleanPhone = phoneNumber.trim();
    final cleanCode = code.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(cleanCode)) {
      return const AuthResult(
        success: false,
        message: 'Invalid OTP code format. Must be exactly 6 digits.',
      );
    }

    final pool = Database.pool;
    final codeHash = SecurityUtils.hashSha256(cleanCode);

    return await pool.runTx((session) async {
      // 1. Find the latest active OTP request for the phone number with FOR UPDATE to prevent race conditions.
      final latestOtpResult = await session.execute(
        r'''
        SELECT id, otp_hash, attempts
        FROM auth_otps
        WHERE phone_number = $1 AND verified_at IS NULL AND expires_at > CURRENT_TIMESTAMP
        ORDER BY created_at DESC LIMIT 1
        FOR UPDATE
        ''',
        parameters: [cleanPhone],
      );

      if (latestOtpResult.isEmpty) {
        return const AuthResult(
          success: false,
          message: 'Invalid or expired verification code.',
        );
      }

      final row = latestOtpResult.first;
      final String otpId = row[0] as String;
      final String storedHash = row[1] as String;
      final int attempts = (row[2] as num).toInt();

      if (attempts >= 5) {
        return const AuthResult(
          success: false,
          message: 'Too many incorrect attempts. Please request a new code.',
        );
      }

      if (storedHash != codeHash) {
        // Increment attempts atomically within the lock
        await session.execute(
          r'UPDATE auth_otps SET attempts = attempts + 1 WHERE id = $1',
          parameters: [otpId],
        );
        return const AuthResult(
          success: false,
          message: 'Invalid verification code.',
        );
      }

      // 2. Code is correct. Mark as verified.
      await session.execute(
        r'UPDATE auth_otps SET verified_at = CURRENT_TIMESTAMP WHERE id = $1',
        parameters: [otpId],
      );

      // 3. Find or Create user safely using ON CONFLICT to avoid race condition double-inserts.
      final userUpsert = await session.execute(
        r'''
        INSERT INTO users (phone_number, full_name, dob, gender, height_cm, location, instagram_username, status, is_verified, role)
        VALUES ($1, 'New RedFlag Member', '2000-01-01', 'Unspecified', 170, '', '', 'pending_verification', FALSE, 'user')
        ON CONFLICT (phone_number) DO UPDATE
        SET updated_at = CURRENT_TIMESTAMP
        RETURNING id, phone_number, full_name, dob, gender, height_cm, location, instagram_username, status, is_verified, created_at
        ''',
        parameters: [cleanPhone],
      );

      final userRow = userUpsert.first;
      final userMap = {
        'id': userRow[0].toString(),
        'phoneNumber': userRow[1].toString(),
        'fullName': userRow[2]?.toString() ?? '',
        'dob': userRow[3]?.toString() ?? '',
        'gender': userRow[4]?.toString() ?? '',
        'heightCm': userRow[5] != null ? (userRow[5] as num).toInt() : 170,
        'location': userRow[6]?.toString() ?? '',
        'instagramUsername': userRow[7]?.toString() ?? '',
        'status': userRow[8].toString(),
        'isVerified': userRow[9] as bool,
        'createdAt': (userRow[10] as DateTime).toIso8601String(),
      };

      // 4. Generate crypto-secure random session token
      final rawSessionToken = SecurityUtils.generateRandomToken(32);
      final sessionTokenHash = SecurityUtils.hashSha256(rawSessionToken);

      // Insert hashed session token into user_sessions table
      await session.execute(
        r"INSERT INTO user_sessions (user_id, session_token_hash, expires_at) VALUES ($1, $2, CURRENT_TIMESTAMP + INTERVAL '30 days')",
        parameters: [userMap['id'], sessionTokenHash],
      );

      return AuthResult(
        success: true,
        message: 'Authenticated successfully.',
        sessionToken: rawSessionToken,
        user: userMap,
      );
    });
  }

  Future<bool> revokeSession(String sessionToken) async {
    final tokenHash = SecurityUtils.hashSha256(sessionToken);
    final pool = Database.pool;
    final result = await pool.execute(
      r'UPDATE user_sessions SET expires_at = CURRENT_TIMESTAMP WHERE session_token_hash = $1 AND expires_at > CURRENT_TIMESTAMP RETURNING id',
      parameters: [tokenHash],
    );
    return result.isNotEmpty;
  }
}
