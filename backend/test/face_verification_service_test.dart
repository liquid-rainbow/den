import 'package:den_backend/config/database.dart';
import 'package:den_backend/config/env.dart';
import 'package:den_backend/modules/onboarding/face_verification_service.dart';
import 'package:den_backend/shared/aws/face_verification_service.dart';
import 'package:den_backend/shared/security_utils.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

class _FakeFaceVerificationProvider implements FaceVerificationService {
  var _sessionNumber = 0;

  @override
  Future<String> createLivenessSession(String userId) async {
    _sessionNumber++;
    return 'test_liveness_session_$_sessionNumber';
  }

  @override
  Future<FaceVerificationResult> getResults(String sessionId) async {
    return const FaceVerificationResult(
      passed: false,
      confidenceScore: 0,
      similarityScore: 0,
      message: 'Test verification did not pass.',
    );
  }
}

void main() {
  const testPhone = '+15555550137';
  late String sessionToken;
  late String userId;
  late OnboardingFaceVerificationService service;

  setUpAll(() async {
    Env.load();
    await Database.initialize();
  });

  tearDownAll(() async {
    await Database.close();
  });

  setUp(() async {
    final pool = Database.pool;
    await pool.execute(
      r'DELETE FROM users WHERE phone_number = $1',
      parameters: [testPhone],
    );
    final user = await pool.execute(
      r'INSERT INTO users (phone_number) VALUES ($1) RETURNING id',
      parameters: [testPhone],
    );
    userId = user.first[0].toString();
    sessionToken = SecurityUtils.generateRandomToken();
    await pool.execute(
      r'''
      INSERT INTO user_sessions (user_id, session_token_hash, expires_at)
      VALUES ($1, $2, CURRENT_TIMESTAMP + INTERVAL '1 hour')
      ''',
      parameters: [userId, SecurityUtils.hashSha256(sessionToken)],
    );
    service = OnboardingFaceVerificationService(
      provider: _FakeFaceVerificationProvider(),
    );
  });

  tearDown(() async {
    await Database.pool.execute(
      r'DELETE FROM users WHERE phone_number = $1',
      parameters: [testPhone],
    );
  });

  Request authenticatedRequest() => Request(
        'POST',
        Uri.parse('http://localhost/api/onboarding/face-liveness/session'),
        headers: {'authorization': 'Bearer $sessionToken'},
      );

  test('creates and verifies only the authenticated user session', () async {
    final sessionId = await service.createSession(authenticatedRequest());
    final result = await service.verifySession(
      authenticatedRequest(),
      sessionId,
    );

    expect(result.passed, isFalse);
    final stored = await Database.pool.execute(
      r'''
      SELECT status
      FROM face_liveness_sessions
      WHERE user_id = $1 AND aws_session_id = $2
      ''',
      parameters: [userId, sessionId],
    );
    expect(stored.first[0], 'failed');
  });

  test('limits users to three session attempts in 24 hours', () async {
    for (var attempt = 0; attempt < 3; attempt++) {
      await service.createSession(authenticatedRequest());
    }

    expect(
      () => service.createSession(authenticatedRequest()),
      throwsA(isA<FaceVerificationRateLimitException>()),
    );
  });
}
