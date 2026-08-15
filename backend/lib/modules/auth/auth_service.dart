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

    // Find active unverified OTP match
    final otpResult = await pool.execute(
      r'SELECT id FROM auth_otps WHERE phone_number = $1 AND otp_hash = $2 AND verified_at IS NULL AND expires_at > CURRENT_TIMESTAMP ORDER BY created_at DESC LIMIT 1',
      parameters: [cleanPhone, codeHash],
    );

    if (otpResult.isEmpty) {
      return const AuthResult(
        success: false,
        message: 'Invalid or expired verification code.',
      );
    }

    final otpId = otpResult.first[0] as String;

    // Mark OTP as verified
    await pool.execute(
      r'UPDATE auth_otps SET verified_at = CURRENT_TIMESTAMP WHERE id = $1',
      parameters: [otpId],
    );

    // Explicit Find-or-Create user by phone_number
    final userSelect = await pool.execute(
      r'SELECT id, phone_number, full_name, dob, gender, height_cm, location, instagram_username, status, is_verified, created_at, username FROM users WHERE phone_number = $1',
      parameters: [cleanPhone],
    );

    Map<String, dynamic> userMap;

    if (userSelect.isNotEmpty) {
      // User exists
      final row = userSelect.first;
      userMap = {
        'id': row[0].toString(),
        'phoneNumber': row[1].toString(),
        'fullName': row[2]?.toString() ?? '',
        'dob': row[3]?.toString() ?? '',
        'gender': row[4]?.toString() ?? '',
        'heightCm': row[5] != null ? (row[5] as num).toInt() : 170,
        'location': row[6]?.toString() ?? '',
        'instagramUsername': row[7]?.toString() ?? '',
        'status': row[8].toString(),
        'isVerified': row[9] as bool,
        'createdAt': (row[10] as DateTime).toIso8601String(),
        'username': row[11].toString(),
      };
    } else {
      // User does NOT exist -> INSERT new user with least-privilege defaults ('pending_onboarding')
      // Note: username is omitted from column list so PostgreSQL sequence default fires automatically
      final userInsert = await pool.execute(
        r"INSERT INTO users (phone_number, full_name, dob, gender, height_cm, location, instagram_username, status, is_verified, role) VALUES ($1, 'New RedFlag Member', '2000-01-01', 'Unspecified', 170, '', '', 'pending_onboarding', FALSE, 'user') RETURNING id, phone_number, full_name, dob, gender, height_cm, location, instagram_username, status, is_verified, created_at, username",
        parameters: [cleanPhone],
      );
      final row = userInsert.first;
      userMap = {
        'id': row[0].toString(),
        'phoneNumber': row[1].toString(),
        'fullName': row[2].toString(),
        'dob': row[3].toString(),
        'gender': row[4].toString(),
        'heightCm': (row[5] as num).toInt(),
        'location': row[6].toString(),
        'instagramUsername': row[7].toString(),
        'status': row[8].toString(),
        'isVerified': row[9] as bool,
        'createdAt': (row[10] as DateTime).toIso8601String(),
        'username': row[11].toString(),
      };
    }

    // Generate crypto-secure random session token
    final rawSessionToken = SecurityUtils.generateRandomToken(32);
    final sessionTokenHash = SecurityUtils.hashSha256(rawSessionToken);

    // Insert hashed session token into user_sessions table
    await pool.execute(
      r"INSERT INTO user_sessions (user_id, session_token_hash, expires_at) VALUES ($1, $2, CURRENT_TIMESTAMP + INTERVAL '30 days')",
      parameters: [userMap['id'], sessionTokenHash],
    );

    return AuthResult(
      success: true,
      message: 'Authenticated successfully.',
      sessionToken: rawSessionToken,
      user: userMap,
    );
  }
}
