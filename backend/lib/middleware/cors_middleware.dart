import 'package:shelf/shelf.dart';

const _allowedMethods = {'GET', 'POST', 'PATCH', 'PUT', 'OPTIONS'};
const _allowedHeaders = {'authorization', 'content-type'};

Middleware corsMiddleware({required Set<String> allowedOrigins}) {
  return (Handler innerHandler) {
    return (Request request) async {
      final origin = request.headers['origin'];

      if (origin != null && !allowedOrigins.contains(origin)) {
        return Response.forbidden('CORS origin is not allowed.');
      }

      if (request.method == 'OPTIONS') {
        if (origin == null) {
          return Response.badRequest(body: 'CORS origin is required.');
        }

        final requestedMethod =
            request.headers['access-control-request-method']?.toUpperCase();
        if (requestedMethod == null ||
            !_allowedMethods.contains(requestedMethod)) {
          return Response.forbidden('CORS method is not allowed.');
        }

        final requestedHeaders = request
                .headers['access-control-request-headers']
                ?.split(',')
                .map((header) => header.trim().toLowerCase())
                .where((header) => header.isNotEmpty)
                .toSet() ??
            const <String>{};
        if (!requestedHeaders.every(_allowedHeaders.contains)) {
          return Response.forbidden('CORS header is not allowed.');
        }

        return Response(204, headers: _corsHeaders(origin));
      }

      final response = await innerHandler(request);
      if (origin == null) {
        return response;
      }

      return response.change(
        headers: {
          ...response.headers,
          ..._corsHeaders(origin),
        },
      );
    };
  };
}

Map<String, String> _corsHeaders(String origin) {
  return {
    'access-control-allow-origin': origin,
    'access-control-allow-methods': _allowedMethods.join(', '),
    'access-control-allow-headers': _allowedHeaders.join(', '),
    'access-control-max-age': '600',
    'vary':
        'Origin, Access-Control-Request-Method, Access-Control-Request-Headers',
  };
}
