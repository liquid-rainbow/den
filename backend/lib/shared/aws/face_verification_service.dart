import 'package:den_backend/config/env.dart';

class FaceVerificationResult {
  final bool passed;
  final double confidenceScore;
  final double similarityScore;
  final String message;

  const FaceVerificationResult({
    required this.passed,
    required this.confidenceScore,
    required this.similarityScore,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
        'passed': passed,
        'confidenceScore': confidenceScore,
        'similarityScore': similarityScore,
        'message': message,
      };
}

abstract class FaceVerificationService {
  Future<String> createLivenessSession(String userId);
  Future<FaceVerificationResult> getResults(String sessionId);
}

/// ============================================================================
/// PLACEHOLDER STUB IMPLEMENTATION: StubFaceVerificationService
/// ============================================================================
/// WHAT IT DOES: Returns structurally valid stub session IDs and results.
/// WHAT REAL AWS IMPLEMENTATION MUST DO:
/// 1. Invoke AWS Rekognition `CreateFaceLivenessSession`.
/// 2. Invoke AWS Rekognition `GetFaceLivenessSessionResults` and `CompareFaces`.
/// SECURITY CONSTRAINT: Must NEVER be instantiated or executed in production.
/// ============================================================================
class StubFaceVerificationService implements FaceVerificationService {
  StubFaceVerificationService() {
    if (Env.isProduction) {
      throw StateError(
        'SECURITY CRITICAL: StubFaceVerificationService cannot be initialized in production environment!',
      );
    }
  }

  @override
  Future<String> createLivenessSession(String userId) async {
    if (Env.isProduction) {
      throw StateError(
        'SECURITY CRITICAL: StubFaceVerificationService attempted execution in production path!',
      );
    }
    return 'aws_rekognition_liveness_stub_session_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<FaceVerificationResult> getResults(String sessionId) async {
    if (Env.isProduction) {
      throw StateError(
        'SECURITY CRITICAL: StubFaceVerificationService attempted execution in production path!',
      );
    }
    return const FaceVerificationResult(
      passed: false,
      confidenceScore: 0.0,
      similarityScore: 0.0,
      message: 'Not implemented — awaiting real AWS Rekognition backend integration',
    );
  }
}
