abstract class FaceVerificationRepository {
  /// Obtains a new AWS Rekognition Face Liveness session ID from the backend
  /// per docs/04-face-verification-approach.md.
  Future<String> createLivenessSession();

  /// Submits the liveness session ID to backend for verification and face matching.
  Future<bool> verifyFace({required String sessionId});
}
