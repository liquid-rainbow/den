import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'user_service.dart';

class UserController {
  final UserService _userService;

  UserController({required UserService userService}) : _userService = userService;

  Router get router {
    final router = Router();

    router.get('/me', (Request request) async {
      try {
        final user = await _userService.getMe(request);
        if (user == null) {
          return Response.forbidden(
            jsonEncode({'success': false, 'message': 'Authentication required'}),
            headers: {'content-type': 'application/json'},
          );
        }

        return Response.ok(
          jsonEncode({'success': true, 'user': user}),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'success': false, 'message': 'Failed to load profile'}),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    router.post('/onboarding', (Request request) async {
      try {
        final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
        final user = await _userService.completeOnboarding(request, body);
        if (user == null) {
          return Response.forbidden(
            jsonEncode({'success': false, 'message': 'Authentication required'}),
            headers: {'content-type': 'application/json'},
          );
        }

        return Response(201,
          body: jsonEncode({
            'success': true,
            'message': 'Profile setup complete.',
            'user': user,
          }),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': e.toString()}),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    router.patch('/me', (Request request) async {
      try {
        final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
        final user = await _userService.updateProfile(request, body);
        if (user == null) {
          return Response.forbidden(
            jsonEncode({'success': false, 'message': 'Authentication required'}),
            headers: {'content-type': 'application/json'},
          );
        }

        return Response.ok(
          jsonEncode({'success': true, 'user': user}),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': e.toString()}),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    router.get('/by-username/<username>', (Request request, String username) async {
      try {
        final user = await _userService.getProfileByUsername(username);
        if (user == null) {
          return Response.notFound(
            jsonEncode({'success': false, 'message': 'Profile not found'}),
            headers: {'content-type': 'application/json'},
          );
        }

        return Response.ok(
          jsonEncode({'success': true, 'user': user}),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'success': false, 'message': 'Failed to load public profile'}),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    return router;
  }
}
