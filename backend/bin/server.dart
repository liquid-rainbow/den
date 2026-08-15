import 'dart:convert';
import 'dart:io';

import 'package:den_backend/config/database.dart';
import 'package:den_backend/config/env.dart';
import 'package:den_backend/middleware/security_headers.dart';
import 'package:den_backend/modules/auth/auth_controller.dart';
import 'package:den_backend/modules/auth/auth_service.dart';
import 'package:den_backend/modules/biometric/biometric_controller.dart';
import 'package:den_backend/modules/biometric/biometric_service.dart';
import 'package:den_backend/modules/upload/upload_controller.dart';
import 'package:den_backend/modules/upload/upload_service.dart';
import 'package:den_backend/modules/user/user_controller.dart';
import 'package:den_backend/modules/user/user_service.dart';
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

  final uploadService = UploadService(photoStorage: photoStorage);
  final uploadController = UploadController(uploadService: uploadService);

  final biometricService = BiometricService(faceVerificationService: faceVerificationService);
  final biometricController = BiometricController(biometricService: biometricService);

  final userService = UserService();
  final userController = UserController(userService: userService);

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

  // Mount API Routers
  app.mount('/api/auth', authController.router.call);
  app.mount('/api/uploads', uploadController.router.call);
  app.mount('/api/onboarding', biometricController.router.call);
  app.mount('/api/users', userController.router.call);

  final handler = const Pipeline()
      .addMiddleware(securityHeadersMiddleware())
      .addMiddleware(logRequests())
      .addHandler(app.call);

  final server = await io.serve(handler, InternetAddress.anyIPv4, Env.port);
  print('DEN Backend Server running on http://${server.address.host}:${server.port}');
  print('AWS Stubs wired: ${smsSender.runtimeType}, ${photoStorage.runtimeType}, ${faceVerificationService.runtimeType}');
}
