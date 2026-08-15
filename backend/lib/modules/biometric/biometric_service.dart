import 'package:den_backend/config/database.dart';
import 'package:den_backend/shared/aws/face_verification_service.dart';

class BiometricSessionResult {
  final bool success;
  final String message;
  final String? sessionId;
  final int statusCode;

  const BiometricSessionResult({
    required this.success,
    required this.message,
    this.sessionId,
    this.statusCode = 200,
  });
}

class BiometricVerifyResult {
  final bool success;
  final bool verified;
  final String badge;
  final String message;
  final int statusCode;

  const BiometricVerifyResult({
    required this.success,
    required this.verified,
    required this.badge,
    required this.message,
    this.statusCode = 200,
  });
}

class BiometricService {
  final FaceVerificationService _faceVerificationService;

  BiometricService({required FaceVerificationService faceVerificationService})
      : _faceVerificationService = faceVerificationService;

  Future<BiometricSessionResult> createSession(String userId) async {
    final pool = Database.pool;

    // Note: Known/accepted tradeoff: count-then-insert race window during high concurrency; accepted for this phase.
    // Hard Requirement: Enforce max 3 attempts per user per 24 hours at the database layer
    final attemptsResult = await pool.execute(
      r"SELECT COUNT(*) FROM face_liveness_sessions WHERE user_id = $1 AND created_at > (CURRENT_TIMESTAMP - INTERVAL '24 hours')",
      parameters: [userId],
    );

    final attemptsLast24h = (attemptsResult.first[0] as num).toInt();
    if (attemptsLast24h >= 3) {
      return const BiometricSessionResult(
        success: false,
        message: 'Rate limit exceeded: Maximum 3 face verification attempts allowed per 24 hours.',
        statusCode: 429,
      );
    }

    // Call face verification service abstraction
    final awsSessionId = await _faceVerificationService.createLivenessSession(userId);

    // Persist face liveness session attempt in DB
    await pool.execute(
      r"INSERT INTO face_liveness_sessions (user_id, aws_session_id, status) VALUES ($1, $2, 'created')",
      parameters: [userId, awsSessionId],
    );

    return BiometricSessionResult(
      success: true,
      message: 'Face liveness session created successfully.',
      sessionId: awsSessionId,
      statusCode: 200,
    );
  }

  Future<BiometricVerifyResult> verifyFace(String userId, String sessionId) async {
    final cleanSessionId = sessionId.trim();
    if (cleanSessionId.isEmpty) {
      return const BiometricVerifyResult(
        success: false,
        verified: false,
        badge: 'Unverified',
        message: 'sessionId is required.',
        statusCode: 400,
      );
    }

    final pool = Database.pool;

    // Confirm session exists for this user (filters strictly by aws_session_id AND user_id)
    final sessionCheck = await pool.execute(
      r'SELECT id FROM face_liveness_sessions WHERE aws_session_id = $1 AND user_id = $2',
      parameters: [cleanSessionId, userId],
    );

    if (sessionCheck.isEmpty) {
      return const BiometricVerifyResult(
        success: false,
        verified: false,
        badge: 'Unverified',
        message: 'Face liveness session not found for this user.',
        statusCode: 404,
      );
    }

    // Retrieve liveness + comparison results from face verification abstraction
    final res = await _faceVerificationService.getResults(cleanSessionId);

    final newStatus = res.passed ? 'passed' : 'failed';

    // Update face liveness session record in DB
    await pool.execute(
      r'''
      UPDATE face_liveness_sessions
      SET status = $1, confidence_score = $2, similarity_score = $3, completed_at = CURRENT_TIMESTAMP
      WHERE aws_session_id = $4
      ''',
      parameters: [newStatus, res.confidenceScore, res.similarityScore, cleanSessionId],
    );

    // If passed, mark user as identity verified
    if (res.passed) {
      await pool.execute(
        r'UPDATE users SET is_verified = TRUE, updated_at = CURRENT_TIMESTAMP WHERE id = $1',
        parameters: [userId],
      );
    }

    return BiometricVerifyResult(
      success: true,
      verified: res.passed,
      badge: res.passed ? 'Identity Verified' : 'Unverified',
      message: res.message,
      statusCode: 200,
    );
  }
}
