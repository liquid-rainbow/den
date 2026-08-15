import 'dart:convert';
import 'package:den_backend/middleware/auth_middleware.dart';
import 'package:den_backend/modules/user/user_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class UserController {
  final UserService _userService;

  UserController({required UserService userService}) : _userService = userService;

  Router get router {
    final router = Router();

    router.post('/onboarding', (Request request) async {
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
        if (bodyStr.isEmpty) {
          return Response.badRequest(
            body: jsonEncode({'success': false, 'message': 'Request body is required'}),
            headers: {'content-type': 'application/json'},
          );
        }

        final body = jsonDecode(bodyStr) as Map<String, dynamic>;

        final result = await _userService.completeOnboarding(userId, body);

        return Response(
          201,
          body: jsonEncode({
            'success': true,
            'message': result.message,
            'user': result.user,
          }),
          headers: {'content-type': 'application/json'},
        );
      } on ArgumentError catch (e) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': e.message}),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'success': false, 'message': 'Failed to complete profile onboarding'}),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    router.get('/me', (Request request) async {
      try {
        final userId = request.context['userId'] as String?;
        if (userId == null) {
          return Response(
            401,
            body: jsonEncode({'success': false, 'message': 'Unauthorized'}),
            headers: {'content-type': 'application/json'},
          );
        }

        final userProfile = await _userService.getUserProfile(userId);
        if (userProfile == null) {
          return Response.notFound(
            jsonEncode({'success': false, 'message': 'User profile not found'}),
            headers: {'content-type': 'application/json'},
          );
        }

        return Response.ok(
          jsonEncode({
            'success': true,
            'user': userProfile,
          }),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'success': false, 'message': 'Failed to fetch user profile'}),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    router.patch('/me/username', (Request request) async {
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
        if (bodyStr.isEmpty) {
          return Response.badRequest(
            body: jsonEncode({'success': false, 'message': 'Request body is required'}),
            headers: {'content-type': 'application/json'},
          );
        }

        final body = jsonDecode(bodyStr) as Map<String, dynamic>;
        final usernameInput = body['username'];
        if (usernameInput == null || usernameInput is! String) {
          return Response.badRequest(
            body: jsonEncode({'success': false, 'message': 'username string is required'}),
            headers: {'content-type': 'application/json'},
          );
        }

        final newUsername = await _userService.updateUsername(userId, usernameInput);

        return Response.ok(
          jsonEncode({
            'success': true,
            'username': newUsername,
          }),
          headers: {'content-type': 'application/json'},
        );
      } on ArgumentError catch (e) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': e.message}),
          headers: {'content-type': 'application/json'},
        );
      } on ConflictException catch (e) {
        return Response(
          409,
          body: jsonEncode({'success': false, 'message': e.message}),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'success': false, 'message': 'Failed to update username'}),
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
