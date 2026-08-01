import 'dart:convert';
import 'package:den_backend/modules/auth/auth_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class AuthController {
  final AuthService _authService;

  AuthController({required AuthService authService}) : _authService = authService;

  Router get router {
    final router = Router();

    router.post('/send-otp', (Request request) async {
      try {
        final bodyStr = await request.readAsString();
        final body = jsonDecode(bodyStr) as Map<String, dynamic>;
        final phoneNumber = body['phoneNumber'] as String?;

        if (phoneNumber == null || phoneNumber.isEmpty) {
          return Response.badRequest(
            body: jsonEncode({'success': false, 'message': 'phoneNumber is required'}),
            headers: {'content-type': 'application/json'},
          );
        }

        final result = await _authService.sendOtp(phoneNumber);

        return Response(
          result.success ? 200 : 400,
          body: jsonEncode({
            'success': result.success,
            'message': result.message,
          }),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'success': false, 'message': 'Failed to process send OTP request'}),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    router.post('/verify-otp', (Request request) async {
      try {
        final bodyStr = await request.readAsString();
        final body = jsonDecode(bodyStr) as Map<String, dynamic>;
        final phoneNumber = body['phoneNumber'] as String?;
        final code = body['code'] as String?;

        if (phoneNumber == null || code == null) {
          return Response.badRequest(
            body: jsonEncode({'success': false, 'message': 'phoneNumber and code are required'}),
            headers: {'content-type': 'application/json'},
          );
        }

        final result = await _authService.verifyOtp(phoneNumber, code);

        if (!result.success) {
          return Response.badRequest(
            body: jsonEncode({
              'success': false,
              'message': result.message,
            }),
            headers: {'content-type': 'application/json'},
          );
        }

        return Response.ok(
          jsonEncode({
            'success': true,
            'message': result.message,
            'sessionToken': result.sessionToken,
            'user': result.user,
          }),
          headers: {
            'content-type': 'application/json',
            'set-cookie': 'rf_session=${result.sessionToken}; HttpOnly; Path=/; SameSite=Lax',
          },
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'success': false, 'message': 'Failed to verify OTP code'}),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    return router;
  }
}
