import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:den_backend/modules/user/user_service.dart';
import 'event_service.dart';

class EventController {
  final EventService _eventService;
  final UserService _userService;

  EventController({
    required EventService eventService,
    required UserService userService,
  })  : _eventService = eventService,
        _userService = userService;

  Router get eventRouter {
    final router = Router();

    // 1. Event Creation / Publish
    router.post('/', (Request request) async {
      try {
        final user = await _userService.getAuthenticatedUser(request);
        if (user == null) {
          return Response.forbidden(jsonEncode({'success': false, 'message': 'Authentication required'}));
        }

        final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
        
        // Basic validation
        if (body['title'] == null || body['title'].toString().isEmpty) {
          return Response.badRequest(body: jsonEncode({'success': false, 'message': 'Title is required'}));
        }
        if (body['category'] == null || body['category'].toString().isEmpty) {
          return Response.badRequest(body: jsonEncode({'success': false, 'message': 'Category is required'}));
        }

        final result = await _eventService.createEvent(body, user['id']);
        
        return Response.ok(
          jsonEncode({'success': true, 'event': result}),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'success': false, 'message': e.toString()}),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    // 3. Single Event Detail
    router.get('/<id>', (Request request, String id) async {
      try {
        final event = await _eventService.getEventById(id);
        if (event == null) {
          return Response.notFound(jsonEncode({'success': false, 'message': 'Event not found'}));
        }

        return Response.ok(
          jsonEncode({'success': true, 'event': event}),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'success': false, 'message': e.toString()}),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    // 4a. Event Update
    router.patch('/<id>', (Request request, String id) async {
      try {
        final user = await _userService.getAuthenticatedUser(request);
        if (user == null) {
          return Response.forbidden(jsonEncode({'success': false, 'message': 'Authentication required'}));
        }

        final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
        await _eventService.updateEvent(id, body, user['id']);
        
        return Response.ok(
          jsonEncode({'success': true, 'message': 'Event updated'}),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'success': false, 'message': e.toString()}),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    // 4b. Event Cancel
    router.post('/<id>/cancel', (Request request, String id) async {
      try {
        final user = await _userService.getAuthenticatedUser(request);
        if (user == null) {
          return Response.forbidden(jsonEncode({'success': false, 'message': 'Authentication required'}));
        }

        await _eventService.cancelEvent(id, user['id']);
        
        return Response.ok(
          jsonEncode({'success': true, 'message': 'Event cancelled'}),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': e.toString()}),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    return router;
  }

  Router get homeRouter {
    final router = Router();

    // 2. Home Feed
    router.get('/feed', (Request request) async {
      try {
        final user = await _userService.getAuthenticatedUser(request);
        if (user == null) {
          return Response.forbidden(jsonEncode({'success': false, 'message': 'Authentication required'}));
        }

        // Parse query params for location filtering
        // Assumption: frontend sends 'lat' and 'lng' query params
        final queryParams = request.url.queryParameters;
        final latStr = queryParams['lat'];
        final lngStr = queryParams['lng'];
        final radiusStr = queryParams['radius'] ?? '50';

        // Default to a central coordinate (e.g. SF) if none provided by client
        final userLat = latStr != null ? double.parse(latStr) : 37.7749;
        final userLng = lngStr != null ? double.parse(lngStr) : -122.4194;
        final radiusKm = double.parse(radiusStr);

        final feed = await _eventService.getFeed(
          userLat: userLat,
          userLng: userLng,
          radiusKm: radiusKm,
        );
        
        return Response.ok(
          jsonEncode({'events': feed}), // Exact shape expected by mock_interceptor.dart
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'success': false, 'message': e.toString()}),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    return router;
  }
}
