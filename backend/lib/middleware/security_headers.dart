import 'package:den_backend/config/env.dart';
import 'package:shelf/shelf.dart';

/// ============================================================================
/// SECURITY HEADERS & CORS MIDDLEWARE
/// ============================================================================
/// PRODUCTION DEPLOYMENT REQUIREMENT:
/// The ALLOWED_ORIGINS environment variable must be set in production to match
/// the actual web application domain(s) (e.g. ALLOWED_ORIGINS=https://app.den.com).
/// Wildcard origin '*' combined with credentialed cookies (rf_session) is strictly
/// prohibited to prevent Cross-Origin Resource Sharing (CORS) security risks.
/// ============================================================================
Middleware securityHeadersMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final requestOrigin = request.headers['origin'];
      final allowedOrigins = Env.allowedOrigins;

      String corsOrigin = allowedOrigins.first;
      if (requestOrigin != null && allowedOrigins.contains(requestOrigin)) {
        corsOrigin = requestOrigin;
      }

      // Handle OPTIONS preflight requests directly
      if (request.method == 'OPTIONS') {
        return Response.ok(
          '',
          headers: {
            'Access-Control-Allow-Origin': corsOrigin,
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization, Cookie',
            'Access-Control-Allow-Credentials': 'true',
            'Access-Control-Max-Age': '86400',
          },
        );
      }

      final response = await innerHandler(request);

      return response.change(headers: {
        'Access-Control-Allow-Origin': corsOrigin,
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization, Cookie',
        'Access-Control-Allow-Credentials': 'true',
        'X-Content-Type-Options': 'nosniff',
        'X-Frame-Options': 'DENY',
        'X-XSS-Protection': '1; mode=block',
        'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
        'Content-Security-Policy': "default-src 'self'",
        ...response.headers,
      });
    };
  };
}
