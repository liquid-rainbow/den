
import 'package:den_backend/config/database.dart';
import 'package:den_backend/shared/security_utils.dart';
import 'package:shelf/shelf.dart';

class UserService {
  Future<Map<String, dynamic>?> getAuthenticatedUser(Request request) async {
    final sessionToken = _extractSessionToken(request);
    if (sessionToken == null || sessionToken.isEmpty) {
      return null;
    }

    final pool = Database.pool;
    final tokenHash = SecurityUtils.hashSha256(sessionToken);

    final result = await pool.execute(
      r'''
      SELECT
        u.id,
        u.phone_number,
        u.full_name,
        u.dob,
        u.gender,
        u.height_cm,
        u.location,
        u.instagram_username,
        u.bio,
        u.status,
        u.is_verified,
        u.created_at
      FROM user_sessions s
      JOIN users u ON u.id = s.user_id
      WHERE s.session_token_hash = $1
        AND s.expires_at > CURRENT_TIMESTAMP
      LIMIT 1
      ''',
      parameters: [tokenHash],
    );

    if (result.isEmpty) {
      return null;
    }

    return _mapUserRow(result.first, includePhone: true);
  }

  Future<Map<String, dynamic>?> getProfileByUsername(String username) async {
    final cleanUsername = _normalizeUsername(username);
    if (cleanUsername.isEmpty) return null;

    final pool = Database.pool;
    final result = await pool.execute(
      r'''
      SELECT
        u.id,
        u.full_name,
        u.gender,
        u.height_cm,
        u.location,
        u.instagram_username,
        u.bio,
        u.status,
        u.is_verified,
        u.created_at
      FROM users u
      WHERE LOWER(u.instagram_username) = LOWER($1)
      LIMIT 1
      ''',
      parameters: [cleanUsername],
    );

    if (result.isEmpty) return null;

    final user = _mapPublicUserRow(result.first);
    user['photos'] = await _fetchPhotosForUser(user['id'].toString());
    return user;
  }

  Future<Map<String, dynamic>?> getMe(Request request) async {
    final user = await getAuthenticatedUser(request);
    if (user == null) return null;

    user['photos'] = await _fetchPhotosForUser(user['id'].toString());
    return user;
  }

  Future<Map<String, dynamic>?> completeOnboarding(
    Request request,
    Map<String, dynamic> body,
  ) async {
    final user = await getAuthenticatedUser(request);
    if (user == null) return null;

    final expectedPhone = user['phoneNumber']?.toString() ?? '';
    final phoneNumber = body['phoneNumber']?.toString() ?? '';
    if (phoneNumber != expectedPhone) {
      throw const FormatException('phoneNumber must match the authenticated user');
    }

    final fullName = _requiredString(body['fullName'], maxLength: 120);
    final dob = _requiredString(body['dob']);
    final gender = _requiredString(body['gender'], maxLength: 30);
    final location = _requiredString(body['location'], maxLength: 120);
    final instagramUsername = _requiredString(body['instagramUsername'], maxLength: 30);
    final bio = _optionalString(body['bio'], maxLength: 280);
    final heightCm = _requiredInt(body['heightCm'], min: 120, max: 230);
    final photos = _requiredStringList(body['photos']);

    if (photos.length < 2 || photos.length > 10) {
      throw const FormatException('photos must contain between 2 and 10 entries');
    }

    final pool = Database.pool;
    await pool.runTx((session) async {
      await session.execute(
        r'''
        UPDATE users
        SET
          full_name = $1,
          dob = $2::date,
          gender = $3,
          height_cm = $4,
          location = $5,
          instagram_username = $6,
          bio = $7,
          status = 'active',
          updated_at = CURRENT_TIMESTAMP
        WHERE id = $8
        ''',
        parameters: [
          fullName,
          dob,
          gender,
          heightCm,
          location,
          instagramUsername,
          bio,
          user['id'],
        ],
      );

      await session.execute(
        r'DELETE FROM user_photos WHERE user_id = $1',
        parameters: [user['id']],
      );

      for (var index = 0; index < photos.length; index++) {
        final photoUrl = photos[index];
        await session.execute(
          r'''
          INSERT INTO user_photos (user_id, object_key, public_url, position, is_primary)
          VALUES ($1, $2, $3, $4, $5)
          ''',
          parameters: [
            user['id'],
            'profile_photos/${user['id']}/$index',
            photoUrl,
            index,
            index == 0,
          ],
        );
      }
    });

    return await getMe(request);
  }

  Future<Map<String, dynamic>?> updateProfile(
    Request request,
    Map<String, dynamic> body,
  ) async {
    final user = await getAuthenticatedUser(request);
    if (user == null) return null;

    final fullName = _optionalString(body['fullName'], maxLength: 120);
    final username = _optionalString(body['username'], maxLength: 30);
    final bio = _optionalString(body['bio'], maxLength: 280);
    final location = _optionalString(body['location'], maxLength: 120);
    final gender = _optionalString(body['gender'], maxLength: 30);
    final heightCm = body['heightCm'] != null ? _requiredInt(body['heightCm'], min: 120, max: 230) : null;

    final pool = Database.pool;
    await pool.execute(
      r'''
      UPDATE users
      SET
        full_name = COALESCE($1, full_name),
        instagram_username = COALESCE($2, instagram_username),
        bio = COALESCE($3, bio),
        location = COALESCE($4, location),
        gender = COALESCE($5, gender),
        height_cm = COALESCE($6, height_cm),
        updated_at = CURRENT_TIMESTAMP
      WHERE id = $7
      ''',
      parameters: [fullName, username, bio, location, gender, heightCm, user['id']],
    );

    return await getMe(request);
  }

  Future<List<String>> _fetchPhotosForUser(String userId) async {
    final result = await Database.pool.execute(
      r'''
      SELECT public_url
      FROM user_photos
      WHERE user_id = $1
      ORDER BY position ASC, created_at ASC
      ''',
      parameters: [userId],
    );

    return result.map((row) => row[0].toString()).toList();
  }

  Map<String, dynamic> _mapUserRow(dynamic row, {required bool includePhone}) {
    final user = <String, dynamic>{
      'id': row[0].toString(),
      if (includePhone) 'phoneNumber': row[1].toString(),
      'fullName': row[2]?.toString() ?? '',
      'dob': row[3]?.toString() ?? '',
      'gender': row[4]?.toString() ?? '',
      'heightCm': row[5] != null ? (row[5] as num).toInt() : 170,
      'location': row[6]?.toString() ?? '',
      'instagramUsername': row[7]?.toString() ?? '',
      'bio': row[8]?.toString() ?? '',
      'status': row[9].toString(),
      'isVerified': row[10] as bool,
      'createdAt': (row[11] as DateTime).toIso8601String(),
      'photos': <String>[],
    };
    return user;
  }

  Map<String, dynamic> _mapPublicUserRow(dynamic row) {
    return <String, dynamic>{
      'id': row[0].toString(),
      'fullName': row[1]?.toString() ?? '',
      'gender': row[2]?.toString() ?? '',
      'heightCm': row[3] != null ? (row[3] as num).toInt() : 170,
      'location': row[4]?.toString() ?? '',
      'instagramUsername': row[5]?.toString() ?? '',
      'bio': row[6]?.toString() ?? '',
      'status': row[7].toString(),
      'isVerified': row[8] as bool,
      'createdAt': (row[9] as DateTime).toIso8601String(),
    };
  }

  String _normalizeUsername(String value) {
    return value.trim().replaceAll(RegExp(r'^@'), '');
  }

  String _requiredString(dynamic value, {int? maxLength}) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) {
      throw const FormatException('Required string field is missing');
    }
    if (maxLength != null && text.length > maxLength) {
      throw FormatException('String exceeds maximum length of $maxLength');
    }
    return text;
  }

  String _optionalString(dynamic value, {int? maxLength}) {
    final text = value?.toString().trim() ?? '';
    if (maxLength != null && text.length > maxLength) {
      throw FormatException('String exceeds maximum length of $maxLength');
    }
    return text;
  }

  int _requiredInt(dynamic value, {required int min, required int max}) {
    final parsed = value is int ? value : int.tryParse(value.toString());
    if (parsed == null || parsed < min || parsed > max) {
      throw FormatException('Integer must be between $min and $max');
    }
    return parsed;
  }

  List<String> _requiredStringList(dynamic value) {
    if (value is! List) {
      throw const FormatException('photos must be a list');
    }
    return value.map((item) => item.toString().trim()).where((item) => item.isNotEmpty).toList();
  }

  String? _extractSessionToken(Request request) {
    final authHeader = request.headers['authorization'];
    if (authHeader != null && authHeader.toLowerCase().startsWith('bearer ')) {
      return authHeader.substring(7).trim();
    }

    final cookieHeader = request.headers['cookie'];
    if (cookieHeader == null || cookieHeader.isEmpty) return null;

    for (final cookie in cookieHeader.split(';')) {
      final parts = cookie.trim().split('=');
      if (parts.length == 2 && parts[0] == 'rf_session') {
        return parts[1].trim();
      }
    }

    return null;
  }
}
