import 'dart:convert';

import 'package:den_backend/modules/onboarding/face_verification_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class FaceVerificationController {
  final OnboardingFaceVerificationService _service;

  FaceVerificationController({
    required OnboardingFaceVerificationService service,
  }) : _service = service;

  Router get router {
    final router = Router();

    router.post('/face-liveness/session', (Request request) async {
      try {
        final sessionId = await _service.createSession(request);
        return Response(
          201,
          body: jsonEncode({'success': true, 'sessionId': sessionId}),
          headers: {'content-type': 'application/json'},
        );
      } on FaceVerificationAuthenticationException {
        return _jsonError(403, 'Authentication required.');
      } on FaceVerificationRateLimitException {
        return _jsonError(
          429,
          'Maximum 3 face verification attempts per 24 hours allowed.',
        );
      } catch (_) {
        return _jsonError(500, 'Failed to create face verification session.');
      }
    });

    router.post('/verify-face', (Request request) async {
      try {
        final decoded = jsonDecode(await request.readAsString());
        if (decoded is! Map<String, dynamic>) {
          return _jsonError(400, 'A JSON object is required.');
        }
        final sessionId = decoded['sessionId'];
        if (sessionId is! String || sessionId.trim().isEmpty) {
          return _jsonError(400, 'sessionId is required.');
        }

        final result = await _service.verifySession(request, sessionId);
        return Response.ok(
          jsonEncode({
            'success': true,
            'isLive': result.passed,
            'message': result.message,
          }),
          headers: {'content-type': 'application/json'},
        );
      } on FaceVerificationAuthenticationException {
        return _jsonError(403, 'Authentication required.');
      } on FaceVerificationSessionException catch (error) {
        return _jsonError(400, error.message);
      } on FormatException {
        return _jsonError(400, 'Request body must contain valid JSON.');
      } catch (_) {
        return _jsonError(500, 'Failed to verify face session.');
      }
    });

    return router;
  }

  Response _jsonError(int status, String message) {
    return Response(
      status,
      body: jsonEncode({'success': false, 'message': message}),
      headers: {'content-type': 'application/json'},
    );
  }
}
