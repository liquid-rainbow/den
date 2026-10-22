// Run only against a disposable database with CHAT_TEST_DB=1. Does not load .env.
import 'dart:convert';
import 'dart:io';
import 'package:den_backend/config/database.dart';
import 'package:den_backend/modules/chat/chat_controller.dart';
import 'package:den_backend/modules/chat/chat_service.dart';
import 'package:den_backend/modules/user/user_service.dart';
import 'package:den_backend/shared/security_utils.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  test(
      'mutual likes, concurrent matching, persistence, pagination and access control',
      () async {
    await Database.initialize();
    final pool = Database.pool;
    final ids = <String>[];
    try {
      for (var i = 0; i < 3; i++) {
        final rows = await pool.execute(r'''
          INSERT INTO users(phone_number, full_name, instagram_username, status)
          VALUES ($1, $2, $2, 'active') RETURNING id
        ''', parameters: ['+91000000900$i', 'chat_test_$i']);
        ids.add(rows.first[0].toString());
        await pool.execute(r'''
          INSERT INTO user_sessions(user_id, session_token_hash, expires_at)
          VALUES ($1, $2, CURRENT_TIMESTAMP + INTERVAL '1 hour')
        ''', parameters: [ids.last, SecurityUtils.hashSha256('test-token-$i')]);
      }
      final service = ChatService();
      expect((await service.like(ids[0], 'chat_test_1'))['matched'], false);
      expect(await service.conversations(ids[0]), isEmpty);
      final result = await service.like(ids[1], 'chat_test_0');
      expect(result['matched'], true);
      final id = result['conversationId'] as String;
      await Future.wait([
        service.like(ids[0], 'chat_test_1'),
        service.like(ids[1], 'chat_test_0')
      ]);
      expect(await service.conversations(ids[0]), hasLength(1));
      expect((await service.like(ids[0], 'chat_test_1'))['conversationId'], id);
      await service.send(ids[0], id, 'Hello Tejb');
      await service.send(ids[1], id, 'Hello Ragh');
      final messages = await service.messages(ids[1], id, null);
      expect(messages.map((m) => m['text']), ['Hello Tejb', 'Hello Ragh']);
      expect(messages.first['isMe'], false);
      expect(messages.last['isMe'], true);
      expect(
          await service.messages(
              ids[0], id, int.parse(messages.last['id'] as String)),
          hasLength(1));
      await expectLater(
          service.messages(ids[2], id, null), throwsA(isA<ChatFailure>()));
      await expectLater(
          service.send(ids[2], id, 'intruder'), throwsA(isA<ChatFailure>()));
      await expectLater(
          service.send(ids[0], id, '  '), throwsA(isA<ChatFailure>()));
      await expectLater(
          service.like(ids[0], 'chat_test_0'), throwsA(isA<ChatFailure>()));
      final router =
          ChatController(service: service, users: UserService()).router;
      Future<Response> request(String path,
              {String? token, String method = 'GET', String? body}) =>
          router.call(Request(method, Uri.parse('http://localhost$path'),
              headers: {if (token != null) 'authorization': 'Bearer $token'},
              body: body));
      expect((await request('/conversations')).statusCode, 401);
      expect(
          (await request('/conversations/$id/messages', token: 'test-token-2'))
              .statusCode,
          404);
      expect(
          (await request('/conversations/$id/messages',
                  token: 'test-token-0', method: 'POST', body: '{"text":123}'))
              .statusCode,
          400);
      expect(
          (await request('/conversations/$id/messages?before=bad',
                  token: 'test-token-0'))
              .statusCode,
          400);
      final response =
          await request('/conversations/$id/messages', token: 'test-token-0');
      expect(response.statusCode, 200);
      expect((jsonDecode(await response.readAsString())['messages'] as List),
          hasLength(2));
      await pool.execute(r"UPDATE users SET status = 'suspended' WHERE id = $1",
          parameters: [ids[1]]);
      await expectLater(
          service.send(ids[0], id, 'blocked'), throwsA(isA<ChatFailure>()));
      await Future.wait([
        service.like(ids[0], 'chat_test_2'),
        service.like(ids[2], 'chat_test_0'),
      ]);
      expect(await service.conversations(ids[2]), hasLength(1));
    } finally {
      for (final id in ids) {
        await pool
            .execute(r'DELETE FROM users WHERE id = $1', parameters: [id]);
      }
      await Database.close();
    }
  },
      skip: Platform.environment['CHAT_TEST_DB'] != '1'
          ? 'Requires explicitly configured disposable database'
          : false);
}
