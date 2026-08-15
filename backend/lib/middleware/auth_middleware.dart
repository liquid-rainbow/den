import 'dart:convert';
import 'package:den_backend/config/database.dart';
import 'package:den_backend/shared/security_utils.dart';
import 'package:shelf/shelf.dart';

Middleware authMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      String? token;

      // Check Authorization: Bearer <token>
      final authHeader = request.headers['authorization'];
      if (authHeader != null && authHeader.toLowerCase().startsWith('bearer ')) {
        token = authHeader.substring(7).trim();
      }

      // Check rf_session cookie if token not found in header
      if (token == null || token.isEmpty) {
        final cookieHeader = request.headers['cookie'];
        if (cookieHeader != null) {
          final cookies = cookieHeader.split(';');
          for (final c in cookies) {
            final parts = c.trim().split('=');
            if (parts.length == 2 && parts[0] == 'rf_session') {
              token = parts[1].trim();
              break;
            }
          }
        }
      }

      if (token == null || token.isEmpty) {
        return Response(
          401,
          body: jsonEncode({'success': false, 'message': 'Unauthorized - Missing session token'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final tokenHash = SecurityUtils.hashSha256(token);
      final pool = Database.pool;

      final sessionResult = await pool.execute(
        r'''
        SELECT s.user_id, u.phone_number, u.status, u.is_verified
        FROM user_sessions s
        JOIN users u ON s.user_id = u.id
        WHERE s.session_token_hash = $1 AND s.expires_at > CURRENT_TIMESTAMP
        ''',
        parameters: [tokenHash],
      );

      if (sessionResult.isEmpty) {
        return Response(
          401,
          body: jsonEncode({'success': false, 'message': 'Unauthorized - Invalid or expired session token'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final row = sessionResult.first;
      final userId = row[0].toString();

      final updatedRequest = request.change(context: {
        'userId': userId,
        'userPhone': row[1].toString(),
        'userStatus': row[2].toString(),
        'isVerified': row[3] as bool,
      });

      return await innerHandler(updatedRequest);
    };
  };
}
