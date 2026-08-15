import 'dart:convert';
import 'package:den_backend/middleware/auth_middleware.dart';
import 'package:den_backend/modules/biometric/biometric_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class BiometricController {
  final BiometricService _biometricService;

  BiometricController({required BiometricService biometricService})
      : _biometricService = biometricService;

  Router get router {
    final router = Router();

    router.post('/face-liveness/session', (Request request) async {
      try {
        final userId = request.context['userId'] as String?;
        if (userId == null) {
          return Response(
            401,
            body: jsonEncode({'success': false, 'message': 'Unauthorized'}),
            headers: {'content-type': 'application/json'},
          );
        }

        final result = await _biometricService.createSession(userId);

        return Response(
          result.statusCode,
          body: jsonEncode({
            'success': result.success,
            'message': result.message,
            if (result.sessionId != null) 'sessionId': result.sessionId,
          }),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'success': false, 'message': 'Failed to create face liveness session'}),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    router.post('/verify-face', (Request request) async {
      try {
        final userId = request.context['userId'] as String?;
        if (userId == null) {
          return Response(
            401,
            body: jsonEncode({'success': false, 'message': 'Unauthorized'}),
            headers: {'content-type': 'application/json'},
          );
        }

        final bodyStr = await request.readAsString();
        Map<String, dynamic> body = {};
        if (bodyStr.isNotEmpty) {
          body = jsonDecode(bodyStr) as Map<String, dynamic>;
        }

        final sessionId = body['sessionId'] as String?;
        if (sessionId == null || sessionId.trim().isEmpty) {
          return Response.badRequest(
            body: jsonEncode({'success': false, 'message': 'sessionId is required'}),
            headers: {'content-type': 'application/json'},
          );
        }

        final result = await _biometricService.verifyFace(userId, sessionId);

        return Response(
          result.statusCode,
          body: jsonEncode({
            'success': result.success,
            'verified': result.verified,
            'badge': result.badge,
            'message': result.message,
          }),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'success': false, 'message': 'Failed to verify face'}),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    final pipeline = const Pipeline().addMiddleware(authMiddleware()).addHandler(router.call);
    final wrapperRouter = Router();
    wrapperRouter.all('/<ignored|.*>', pipeline);
    return wrapperRouter;
  }
}
