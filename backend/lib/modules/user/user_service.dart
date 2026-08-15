import 'package:den_backend/config/database.dart';

class ConflictException implements Exception {
  final String message;
  ConflictException(this.message);
}

class OnboardingResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? user;

  const OnboardingResult({
    required this.success,
    required this.message,
    this.user,
  });
}

class UserService {
  Future<OnboardingResult> completeOnboarding(
    String userId,
    Map<String, dynamic> data,
  ) async {
    final fullName = (data['fullName'] as String?)?.trim();
    final dobStr = (data['dob'] as String?)?.trim();
    final gender = (data['gender'] as String?)?.trim();
    final heightCm = data['heightCm'] as num?;
    final location = (data['location'] as String?)?.trim();
    final instagramUsername = (data['instagramUsername'] as String?)?.trim() ?? '';
    final photosRaw = data['photos'] as List<dynamic>?;

    // 1. Validation: Full Name
    if (fullName == null || fullName.isEmpty || fullName.length > 120) {
      throw ArgumentError('fullName is required and must be between 1 and 120 characters.');
    }

    // 2. Validation: DOB & Age >= 18
    if (dobStr == null || dobStr.isEmpty) {
      throw ArgumentError('dob is required (YYYY-MM-DD).');
    }
    final dob = DateTime.tryParse(dobStr);
    if (dob == null) {
      throw ArgumentError('Invalid dob format. Must be YYYY-MM-DD.');
    }

    final now = DateTime.now().toUtc();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    if (age < 18) {
      throw ArgumentError('Users must be at least 18 years old.');
    }

    // 3. Validation: Gender Enum
    final allowedGenders = ['female', 'male', 'non-binary', 'Female', 'Male', 'Non-Binary'];
    if (gender == null || !allowedGenders.contains(gender)) {
      throw ArgumentError('Invalid gender value.');
    }

    // 4. Validation: Height (120 - 230 cm)
    if (heightCm == null || heightCm < 120 || heightCm > 230) {
      throw ArgumentError('heightCm must be an integer between 120 and 230.');
    }

    // 5. Validation: Location
    if (location == null || location.isEmpty || location.length > 120) {
      throw ArgumentError('location is required and must be between 1 and 120 characters.');
    }

    // 6. Validation: Instagram handle regex
    if (instagramUsername.isNotEmpty) {
      final instaRegex = RegExp(r'^[A-Za-z0-9._]{1,30}$');
      if (!instaRegex.hasMatch(instagramUsername)) {
        throw ArgumentError('Invalid Instagram username. Must be 1-30 characters (letters, numbers, dots, underscores).');
      }
    }

    // 7. Validation: Photos Array & Database-backed Presigned Upload Verification (IDOR Check)
    if (photosRaw == null || photosRaw.isEmpty || photosRaw.length > 10) {
      throw ArgumentError('photos array is required and must contain 1 to 10 photos.');
    }

    final photos = photosRaw.map((e) => e.toString().trim()).toList();
    final pool = Database.pool;

    final verifiedObjectKeys = <String>[];

    for (final photoStr in photos) {
      String objectKey = photoStr;
      if (photoStr.contains('cdn.denapp.com/')) {
        objectKey = photoStr.split('cdn.denapp.com/').last;
      } else if (photoStr.contains('.amazonaws.com/')) {
        objectKey = photoStr.split('.amazonaws.com/').last.split('?').first;
      }

      // Query DB to verify a row exists with matching object_key AND authenticated user_id
      final photoCheck = await pool.execute(
        r'SELECT id FROM user_photos WHERE object_key = $1 AND user_id = $2',
        parameters: [objectKey, userId],
      );

      if (photoCheck.isEmpty) {
        throw ArgumentError(
          'Invalid photo: object_key "$objectKey" was not legitimately uploaded by this user.',
        );
      }

      verifiedObjectKeys.add(objectKey);
    }

    // Database Update: Update users table & set status = 'active'
    await pool.execute(
      r'''
      UPDATE users
      SET full_name = $1, dob = $2, gender = $3, height_cm = $4, location = $5,
          instagram_username = $6, status = 'active', updated_at = CURRENT_TIMESTAMP
      WHERE id = $7
      ''',
      parameters: [
        fullName,
        dob.toIso8601String().split('T').first,
        gender.toLowerCase(),
        heightCm.toInt(),
        location,
        instagramUsername,
        userId,
      ],
    );

    // Update positions and primary flags for verified photos
    for (int i = 0; i < verifiedObjectKeys.length; i++) {
      final key = verifiedObjectKeys[i];
      await pool.execute(
        r'''
        UPDATE user_photos
        SET position = $1, is_primary = $2
        WHERE object_key = $3 AND user_id = $4
        ''',
        parameters: [i, i == 0, key, userId],
      );
    }

    // Delete unlinked / unused presigned upload rows (position = -1) for this user
    await pool.execute(
      r'DELETE FROM user_photos WHERE user_id = $1 AND position = -1',
      parameters: [userId],
    );

    final userProfile = await getUserProfile(userId);
    return OnboardingResult(
      success: true,
      message: 'Profile setup complete.',
      user: userProfile,
    );
  }

  Future<String> updateUsername(String userId, String rawUsername) async {
    final username = rawUsername.trim();

    // Validation: 3 to 30 characters
    if (username.length < 3 || username.length > 30) {
      throw ArgumentError('Username must be between 3 and 30 characters.');
    }

    // Validation: Regex letters, numbers, dot, underscore only
    if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(username)) {
      throw ArgumentError(
        'Username can only contain letters, numbers, dots, and underscores.',
      );
    }

    final pool = Database.pool;

    // Case-insensitive uniqueness check against lower(username) for other users
    final checkResult = await pool.execute(
      r'SELECT id FROM users WHERE lower(username) = lower($1) AND id != $2',
      parameters: [username, userId],
    );

    if (checkResult.isNotEmpty) {
      throw ConflictException('Username already taken.');
    }

    // Update username in database
    await pool.execute(
      r'UPDATE users SET username = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2',
      parameters: [username, userId],
    );

    return username;
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final pool = Database.pool;

    final userResult = await pool.execute(
      r'''
      SELECT id, phone_number, full_name, dob, gender, height_cm, location,
             instagram_username, status, is_verified, role, created_at, username
      FROM users WHERE id = $1
      ''',
      parameters: [userId],
    );

    if (userResult.isEmpty) return null;

    final row = userResult.first;

    final photosResult = await pool.execute(
      r'''
      SELECT public_url FROM user_photos
      WHERE user_id = $1 AND position >= 0 ORDER BY position ASC
      ''',
      parameters: [userId],
    );

    final photosList = photosResult.map((r) => r[0].toString()).toList();

    return {
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
      'role': row[10].toString(),
      'photos': photosList,
      'createdAt': (row[11] as DateTime).toIso8601String(),
      'username': row[12]?.toString() ?? '',
    };
  }
}
