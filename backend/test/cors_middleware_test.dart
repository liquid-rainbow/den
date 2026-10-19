import 'package:den_backend/middleware/cors_middleware.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

const _webOrigin = 'http://127.0.0.1:8081';

void main() {
  late Handler handler;
  late int handledRequests;

  setUp(() {
    handledRequests = 0;
    handler = corsMiddleware(allowedOrigins: const {_webOrigin})(
      (request) {
        handledRequests++;
        return Response.ok('ok');
      },
    );
  });

  test('answers an allowed JSON preflight request', () async {
    final response = await handler(
      Request(
        'OPTIONS',
        Uri.parse('http://localhost:5001/api/auth/send-otp'),
        headers: {
          'origin': _webOrigin,
          'access-control-request-method': 'POST',
          'access-control-request-headers': 'content-type',
        },
      ),
    );

    expect(response.statusCode, 204);
    expect(response.headers['access-control-allow-origin'], _webOrigin);
    expect(response.headers['access-control-allow-methods'], contains('POST'));
    expect(response.headers['access-control-allow-headers'],
        contains('content-type'));
    expect(handledRequests, 0);
  });

  test('adds CORS headers to an allowed request response', () async {
    final response = await handler(
      Request(
        'GET',
        Uri.parse('http://localhost:5001/health'),
        headers: {'origin': _webOrigin},
      ),
    );

    expect(response.statusCode, 200);
    expect(response.headers['access-control-allow-origin'], _webOrigin);
    expect(handledRequests, 1);
  });

  test('rejects a browser origin outside the allowlist', () async {
    final response = await handler(
      Request(
        'POST',
        Uri.parse('http://localhost:5001/api/auth/send-otp'),
        headers: {
          'origin': 'https://untrusted.example',
          'content-type': 'application/json',
        },
      ),
    );

    expect(response.statusCode, 403);
    expect(response.headers['access-control-allow-origin'], isNull);
    expect(handledRequests, 0);
  });
}
