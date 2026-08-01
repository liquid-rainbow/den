import 'dart:async';
import 'package:dio/dio.dart';
import '../../domain/repositories/photo_upload_repository.dart';

/// Real HTTP implementation calling POST /api/uploads/photo-url
/// per docs/05-photo-upload-approach.md.
///
/// INTENTIONAL BEHAVIOR NOTE:
/// The Dart backend server does not exist in this phase.
/// Calling requestUploadUrl or uploadToS3 will throw/fail with an HTTP error
/// at runtime until the backend API is deployed. This is expected and correct;
/// do not add a mock fallback.
class PhotoUploadRepositoryImpl implements PhotoUploadRepository {
  final Dio _dio;

  PhotoUploadRepositoryImpl({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'http://localhost:5000',
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 5),
              ),
            );

  @override
  Future<Map<String, String>> requestUploadUrl({required String contentType}) async {
    // Contract per docs/05-photo-upload-approach.md
    final response = await _dio.post(
      '/api/uploads/photo-url',
      data: {'contentType': contentType},
    );

    return {
      'uploadUrl': response.data['uploadUrl'] as String,
      'objectKey': response.data['objectKey'] as String,
      'publicUrl': response.data['publicUrl'] as String,
    };
  }

  @override
  Future<void> uploadToS3({
    required String uploadUrl,
    required List<int> bytes,
    required String contentType,
  }) async {
    await _dio.put(
      uploadUrl,
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: {
          'Content-Type': contentType,
          'Content-Length': bytes.length,
        },
      ),
    );
  }
}
