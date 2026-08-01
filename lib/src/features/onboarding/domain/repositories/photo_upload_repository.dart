abstract class PhotoUploadRepository {
  /// Requests a presigned S3 PUT URL for uploading a photo per docs/05-photo-upload-approach.md.
  Future<Map<String, String>> requestUploadUrl({required String contentType});

  /// Uploads image bytes directly to S3 using the presigned PUT URL.
  Future<void> uploadToS3({
    required String uploadUrl,
    required List<int> bytes,
    required String contentType,
  });
}
