import 'package:den_backend/config/env.dart';

class PresignedUpload {
  final String uploadUrl;
  final String objectKey;
  final String publicUrl;

  const PresignedUpload({
    required this.uploadUrl,
    required this.objectKey,
    required this.publicUrl,
  });

  Map<String, dynamic> toJson() => {
        'uploadUrl': uploadUrl,
        'objectKey': objectKey,
        'publicUrl': publicUrl,
      };
}

abstract class PhotoStorage {
  Future<PresignedUpload> createUploadUrl(String userId, String contentType);
}

/// ============================================================================
/// PLACEHOLDER STUB IMPLEMENTATION: LocalPhotoStorage
/// ============================================================================
/// WHAT IT DOES: Returns fake/local placeholder URLs for S3 uploads.
/// WHAT REAL AWS IMPLEMENTATION MUST DO: Use AWS S3 SDK (S3Client) to generate
/// a 5-minute presigned PUT URL with key scoping: `users/{userId}/photos/{uuid}.jpg`.
/// SECURITY CONSTRAINT: Must NEVER be instantiated or executed in production.
/// ============================================================================
class LocalPhotoStorage implements PhotoStorage {
  LocalPhotoStorage() {
    if (Env.isProduction) {
      throw StateError(
        'SECURITY CRITICAL: LocalPhotoStorage stub cannot be initialized in production environment!',
      );
    }
  }

  @override
  Future<PresignedUpload> createUploadUrl(String userId, String contentType) async {
    if (Env.isProduction) {
      throw StateError(
        'SECURITY CRITICAL: LocalPhotoStorage stub attempted execution in production path!',
      );
    }
    final uuid = DateTime.now().millisecondsSinceEpoch.toString();
    final objectKey = 'users/$userId/photos/$uuid.jpg';
    return PresignedUpload(
      uploadUrl: 'http://localhost:5000/api/uploads/stub-put/$uuid',
      objectKey: objectKey,
      publicUrl: 'https://cdn.denapp.com/$objectKey',
    );
  }
}
