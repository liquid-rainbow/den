import 'package:den_backend/config/database.dart';
import 'package:den_backend/shared/aws/face_verification_service.dart';
import 'package:den_backend/shared/security_utils.dart';
import 'package:shelf/shelf.dart';

class FaceVerificationAuthenticationException implements Exception {
  const FaceVerificationAuthenticationException();
}

class FaceVerificationRateLimitException implements Exception {
  const FaceVerificationRateLimitException();
}

class FaceVerificationSessionException implements Exception {
  final String message;

  const FaceVerificationSessionException(this.message);
}

class OnboardingFaceVerificationService {
  final FaceVerificationService _provider;

  OnboardingFaceVerificationService({
    required FaceVerificationService provider,
  }) : _provider = provider;

  Future<String> createSession(Request request) async {
    final userId = await _authenticatedUserId(request);
    if (userId == null) {
      throw const FaceVerificationAuthenticationException();
    }

    final pool = Database.pool;
    final recentSessions = await pool.execute(
      r'''
      SELECT COUNT(*)
      FROM face_liveness_sessions
      WHERE user_id = $1
        AND created_at > CURRENT_TIMESTAMP - INTERVAL '24 hours'
      ''',
      parameters: [userId],
    );
    final attempts = (recentSessions.first[0] as num).toInt();
    if (attempts >= 3) {
      throw const FaceVerificationRateLimitException();
    }

    final providerSessionId = await _provider.createLivenessSession(userId);
    await pool.execute(
      r'''
      INSERT INTO face_liveness_sessions (user_id, aws_session_id, status)
      VALUES ($1, $2, 'created')
      ''',
      parameters: [userId, providerSessionId],
    );
    return providerSessionId;
  }

  Future<FaceVerificationResult> verifySession(
    Request request,
    String sessionId,
  ) async {
    final userId = await _authenticatedUserId(request);
    if (userId == null) {
      throw const FaceVerificationAuthenticationException();
    }

    final cleanSessionId = sessionId.trim();
    if (!RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(cleanSessionId)) {
      throw const FaceVerificationSessionException(
        'Invalid face verification session.',
      );
    }

    final pool = Database.pool;
    final session = await pool.execute(
      r'''
      SELECT id
      FROM face_liveness_sessions
      WHERE user_id = $1
        AND aws_session_id = $2
        AND status = 'created'
        AND created_at > CURRENT_TIMESTAMP - INTERVAL '15 minutes'
      LIMIT 1
      ''',
      parameters: [userId, cleanSessionId],
    );
    if (session.isEmpty) {
      throw const FaceVerificationSessionException(
        'Face verification session is invalid or expired.',
      );
    }

    final result = await _provider.getResults(cleanSessionId);
    await pool.runTx((transaction) async {
      await transaction.execute(
        r'''
        UPDATE face_liveness_sessions
        SET status = $1,
            confidence_score = $2,
            similarity_score = $3,
            completed_at = CURRENT_TIMESTAMP
        WHERE id = $4
        ''',
        parameters: [
          result.passed ? 'passed' : 'failed',
          result.confidenceScore,
          result.similarityScore,
          session.first[0],
        ],
      );

      if (result.passed) {
        await transaction.execute(
          r'''
          UPDATE users
          SET is_verified = TRUE, updated_at = CURRENT_TIMESTAMP
          WHERE id = $1
          ''',
          parameters: [userId],
        );
      }
    });
    return result;
  }

  Future<String?> _authenticatedUserId(Request request) async {
    final token = _extractSessionToken(request);
    if (token == null || token.isEmpty) return null;

    final result = await Database.pool.execute(
      r'''
      SELECT user_id
      FROM user_sessions
      WHERE session_token_hash = $1
        AND expires_at > CURRENT_TIMESTAMP
      LIMIT 1
      ''',
      parameters: [SecurityUtils.hashSha256(token)],
    );
    return result.isEmpty ? null : result.first[0].toString();
  }

  String? _extractSessionToken(Request request) {
    final authorization = request.headers['authorization'];
    if (authorization != null &&
        authorization.toLowerCase().startsWith('bearer ')) {
      return authorization.substring(7).trim();
    }

    final cookieHeader = request.headers['cookie'];
    if (cookieHeader == null || cookieHeader.isEmpty) return null;
    for (final cookie in cookieHeader.split(';')) {
      final separator = cookie.indexOf('=');
      if (separator <= 0) continue;
      if (cookie.substring(0, separator).trim() == 'rf_session') {
        return cookie.substring(separator + 1).trim();
      }
    }
    return null;
  }
}
