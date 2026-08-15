import 'package:den_backend/config/database.dart';
import 'package:den_backend/shared/aws/photo_storage.dart';

class UploadService {
  final PhotoStorage _photoStorage;

  UploadService({required PhotoStorage photoStorage}) : _photoStorage = photoStorage;

  Future<PresignedUpload> generatePresignedPhotoUrl(String userId, String contentType) async {
    final cleanType = contentType.trim().toLowerCase();
    final allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];

    if (!allowedTypes.contains(cleanType)) {
      throw ArgumentError(
        'Invalid contentType. Allowed types: image/jpeg, image/png, image/webp.',
      );
    }

    final presigned = await _photoStorage.createUploadUrl(userId, cleanType);

    // Track legitimate presigned upload objectKey in user_photos table for DB-backed IDOR verification
    final pool = Database.pool;
    await pool.execute(
      r'''
      INSERT INTO user_photos (user_id, object_key, public_url, position, is_primary)
      VALUES ($1, $2, $3, -1, FALSE)
      ''',
      parameters: [userId, presigned.objectKey, presigned.publicUrl],
    );

    return presigned;
  }
}
