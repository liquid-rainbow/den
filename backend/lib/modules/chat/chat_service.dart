import 'package:den_backend/config/database.dart';

class ChatFailure implements Exception {
  final int status;
  final String message;
  const ChatFailure(this.status, this.message);
}

class ChatService {
  static void validateId(String id) {
    if (!RegExp(
            r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
        .hasMatch(id)) {
      throw const ChatFailure(400, 'Invalid conversation ID.');
    }
  }

  Future<Map<String, dynamic>> like(String me, String username) async {
    if (!RegExp(r'^[a-zA-Z0-9._]{1,30}$').hasMatch(username)) {
      throw const ChatFailure(400, 'Enter a valid username.');
    }
    return Database.pool.runTx((tx) async {
      // Lock both users in a consistent order so simultaneous reciprocal likes
      // cannot both miss each other or create duplicate conversations.
      final users = await tx.execute(r'''
        SELECT id FROM users WHERE status = 'active'
        AND (id = $1::uuid OR lower(instagram_username) = lower($2))
        ORDER BY id FOR UPDATE
      ''', parameters: [me, username]);
      if (users.length != 2) {
        throw const ChatFailure(
            400, 'Choose another active user with a unique username.');
      }
      final other =
          users.map((r) => r[0].toString()).singleWhere((id) => id != me);
      await tx.execute(r'''
        INSERT INTO user_likes(sender_id, recipient_id) VALUES ($1, $2)
        ON CONFLICT DO NOTHING
      ''', parameters: [me, other]);
      final mutual = await tx.execute(r'''
        SELECT 1 FROM user_likes WHERE sender_id = $1 AND recipient_id = $2
      ''', parameters: [other, me]);
      if (mutual.isEmpty) return {'matched': false};
      final pair = [me, other]..sort();
      final conversation = await tx.execute(r'''
        INSERT INTO conversations(user_a, user_b) VALUES ($1, $2)
        ON CONFLICT (user_a, user_b) DO UPDATE SET user_a = EXCLUDED.user_a
        RETURNING id
      ''', parameters: pair);
      return {
        'matched': true,
        'conversationId': conversation.first[0].toString()
      };
    });
  }

  Future<List<Map<String, dynamic>>> conversations(String me) async {
    final rows = await Database.pool.execute(r'''
      SELECT c.id, u.full_name, u.instagram_username, m.body, m.created_at
      FROM conversations c
      JOIN users u ON u.id = CASE WHEN c.user_a = $1::uuid THEN c.user_b ELSE c.user_a END
      JOIN users a ON a.id = c.user_a AND a.status = 'active'
      JOIN users b ON b.id = c.user_b AND b.status = 'active'
      LEFT JOIN LATERAL (
        SELECT body, created_at FROM chat_messages WHERE conversation_id = c.id
        ORDER BY id DESC LIMIT 1
      ) m ON true
      WHERE c.user_a = $1::uuid OR c.user_b = $1::uuid
      ORDER BY COALESCE(m.created_at, c.created_at) DESC, c.id
    ''', parameters: [me]);
    return rows
        .map((r) => <String, dynamic>{
              'id': r[0].toString(),
              'name': r[1] ?? r[2] ?? 'Your match',
              'username': r[2],
              'lastMessage': r[3],
              'lastMessageAt': (r[4] as DateTime?)?.toUtc().toIso8601String(),
            })
        .toList();
  }

  Future<void> requireMember(String me, String conversation) async {
    validateId(conversation);
    final result = await Database.pool.execute(r'''
      SELECT c.id FROM conversations c
      JOIN users a ON a.id = c.user_a AND a.status = 'active'
      JOIN users b ON b.id = c.user_b AND b.status = 'active'
      WHERE c.id = $1 AND (c.user_a = $2 OR c.user_b = $2)
    ''', parameters: [conversation, me]);
    if (result.isEmpty) {
      throw const ChatFailure(404, 'Conversation unavailable.');
    }
  }

  Future<List<Map<String, dynamic>>> messages(
      String me, String conversation, int? before) async {
    await requireMember(me, conversation);
    final rows = await Database.pool.execute(r'''
      SELECT id, sender_id, body, created_at FROM chat_messages
      WHERE conversation_id = $1 AND ($2::bigint IS NULL OR id < $2)
      ORDER BY id DESC LIMIT 100
    ''', parameters: [conversation, before]);
    return rows.reversed
        .map((r) => <String, dynamic>{
              'id': r[0].toString(),
              'isMe': r[1].toString() == me,
              'text': r[2],
              'createdAt': (r[3] as DateTime).toUtc().toIso8601String(),
            })
        .toList();
  }

  Future<void> send(String me, String conversation, Object? body) async {
    if (body is! String || body.trim().isEmpty || body.runes.length > 2000) {
      throw const ChatFailure(400, 'Messages must contain 1–2000 characters.');
    }
    await requireMember(me, conversation);
    await Database.pool.execute(r'''
      INSERT INTO chat_messages(conversation_id, sender_id, body) VALUES ($1, $2, $3)
    ''', parameters: [conversation, me, body.trim()]);
  }
}
