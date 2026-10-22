import 'dart:convert';
import 'package:den_backend/modules/chat/chat_service.dart';
import 'package:den_backend/modules/user/user_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class ChatController {
  final ChatService service;
  final UserService users;
  ChatController({required this.service, required this.users});

  Response _json(int status, Object body) => Response(status,
      body: jsonEncode(body), headers: {'content-type': 'application/json'});

  Future<Map<String, dynamic>> _body(Request request) async {
    if ((request.contentLength ?? 0) > 16384) {
      throw const ChatFailure(413, 'Request too large.');
    }
    final bytes = <int>[];
    await for (final chunk in request.read()) {
      bytes.addAll(chunk);
      if (bytes.length > 16384) {
        throw const ChatFailure(413, 'Request too large.');
      }
    }
    final value = jsonDecode(utf8.decode(bytes));
    if (value is! Map<String, dynamic>) throw const FormatException();
    return value;
  }

  Future<Response> _handle(
      Request request, Future<Object> Function(String me) action) async {
    try {
      final user = await users.getAuthenticatedUser(request);
      if (user == null) return _json(401, {'message': 'Please sign in again.'});
      if (user['status'] != 'active') {
        return _json(403, {'message': 'An active profile is required.'});
      }
      return _json(200, await action(user['id'].toString()));
    } on ChatFailure catch (e) {
      return _json(e.status, {'message': e.message});
    } on FormatException {
      return _json(400, {'message': 'Invalid request.'});
    } catch (_) {
      return _json(500, {'message': 'Chat is unavailable. Please try again.'});
    }
  }

  Router get router {
    final router = Router();
    router.post(
        '/likes',
        (Request r) => _handle(r, (me) async {
              final body = await _body(r);
              if (body['username'] is! String) throw const FormatException();
              return service.like(
                  me,
                  (body['username'] as String)
                      .trim()
                      .replaceFirst(RegExp(r'^@'), ''));
            }));
    router.get(
        '/conversations',
        (Request r) => _handle(r,
            (me) async => {'conversations': await service.conversations(me)}));
    router.get(
        '/conversations/<id>/messages',
        (Request r, String id) => _handle(r, (me) async {
              final value = r.url.queryParameters['before'];
              final before = value == null ? null : int.tryParse(value);
              if (value != null && (before == null || before <= 0)) {
                throw const FormatException();
              }
              return {'messages': await service.messages(me, id, before)};
            }));
    router.post(
        '/conversations/<id>/messages',
        (Request r, String id) => _handle(r, (me) async {
              final body = await _body(r);
              await service.send(me, id, body['text']);
              return {'success': true};
            }));
    return router;
  }
}
