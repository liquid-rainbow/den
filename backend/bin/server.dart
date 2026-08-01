import 'dart:convert';
import 'dart:io';

import 'package:den_backend/config/database.dart';
import 'package:den_backend/config/env.dart';
import 'package:den_backend/modules/auth/auth_controller.dart';
import 'package:den_backend/modules/auth/auth_service.dart';
import 'package:den_backend/shared/aws/face_verification_service.dart';
import 'package:den_backend/shared/aws/photo_storage.dart';
import 'package:den_backend/shared/aws/sms_sender.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

void main() async {
  Env.load();

  // Initialize Database Pool
  await Database.initialize();

  // Dependency Injection: AWS Interfaces & Stub Implementations
  final SmsSender smsSender = ConsoleSmsSender();
  final PhotoStorage photoStorage = LocalPhotoStorage();
  final FaceVerificationService faceVerificationService = StubFaceVerificationService();

  // Instantiate Modules
  final authService = AuthService(smsSender: smsSender);
  final authController = AuthController(authService: authService);

  final app = Router();

  app.get('/health', (Request request) {
    return Response.ok(
      jsonEncode({
        'status': 'ok',
        'environment': Env.environment,
        'stubsActive': !Env.isProduction,
        'wiredServices': [
          smsSender.runtimeType.toString(),
          photoStorage.runtimeType.toString(),
          faceVerificationService.runtimeType.toString(),
        ],
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // Mount Auth Router
  app.mount('/api/auth', authController.router.call);

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(app.call);

  final server = await io.serve(handler, InternetAddress.anyIPv4, Env.port);
  print('DEN Backend Server running on http://${server.address.host}:${server.port}');
  print('AWS Stubs wired: ${smsSender.runtimeType}, ${photoStorage.runtimeType}, ${faceVerificationService.runtimeType}');
}
