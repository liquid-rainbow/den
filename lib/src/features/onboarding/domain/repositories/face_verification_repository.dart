class FaceVerificationOutcome {
  final bool isLive;
  final String message;

  const FaceVerificationOutcome({required this.isLive, required this.message});
}

abstract class FaceVerificationRepository {
  /// Obtains a new AWS Rekognition Face Liveness session ID from the backend
  /// per docs/04-face-verification-approach.md.
  Future<String> createLivenessSession({required String sessionToken});

  /// Submits the liveness session ID to backend for verification and face matching.
  Future<FaceVerificationOutcome> verifyFace({
    required String sessionId,
    required String sessionToken,
  });
}
