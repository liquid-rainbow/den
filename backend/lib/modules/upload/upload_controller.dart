import 'dart:convert';
import 'package:den_backend/middleware/auth_middleware.dart';
import 'package:den_backend/modules/upload/upload_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class UploadController {
  final UploadService _uploadService;

  UploadController({required UploadService uploadService}) : _uploadService = uploadService;

  Router get router {
    final router = Router();

    router.post('/photo-url', (Request request) async {
      try {
        final userId = request.context['userId'] as String?;
        if (userId == null) {
          return Response(
            401,
            body: jsonEncode({'success': false, 'message': 'Unauthorized'}),
            headers: {'content-type': 'application/json'},
          );
        }

        final bodyStr = await request.readAsString();
        Map<String, dynamic> body = {};
        if (bodyStr.isNotEmpty) {
          body = jsonDecode(bodyStr) as Map<String, dynamic>;
        }

        final contentType = (body['contentType'] as String?) ?? 'image/jpeg';

        final presigned = await _uploadService.generatePresignedPhotoUrl(userId, contentType);

        return Response.ok(
          jsonEncode({
            'success': true,
            'uploadUrl': presigned.uploadUrl,
            'objectKey': presigned.objectKey,
            'publicUrl': presigned.publicUrl,
          }),
          headers: {'content-type': 'application/json'},
        );
      } on ArgumentError catch (e) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': e.message}),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'success': false, 'message': 'Failed to generate upload URL'}),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    final pipeline = const Pipeline().addMiddleware(authMiddleware()).addHandler(router.call);
    final wrapperRouter = Router();
    wrapperRouter.all('/<ignored|.*>', pipeline);
    return wrapperRouter;
  }
}
