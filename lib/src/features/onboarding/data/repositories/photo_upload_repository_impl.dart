import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../domain/repositories/photo_upload_repository.dart';

class PhotoUploadRepositoryImpl implements PhotoUploadRepository {
  final Dio _dio;

  PhotoUploadRepositoryImpl(this._dio);

  @override
  Future<Map<String, String>> requestUploadUrl({required String contentType}) async {
    final response = await _dio.post(
      '/api/uploads/photo-url',
      data: {'contentType': contentType},
    );
    
    return {
      'uploadUrl': response.data['uploadUrl'] as String,
      'photoId': response.data['photoId'] as String,
      'downloadUrl': response.data['downloadUrl'] as String,
    };
  }

  @override
  Future<void> uploadToS3({
    required String uploadUrl,
    required List<int> bytes,
    required String contentType,
  }) async {
    final s3Dio = Dio();
    
    await s3Dio.put(
      uploadUrl,
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: {
          'Content-Type': contentType,
          'Content-Length': bytes.length.toString(),
        },
      ),
    );
  }

  Future<void> markUploadComplete({
    required String photoId,
    required String contentType,
  }) async {
    await _dio.post(
      '/api/uploads/complete',
      data: {
        'photoId': photoId,
        'contentType': contentType,
      },
    );
  }
}

final photoUploadRepositoryProvider = Provider<PhotoUploadRepositoryImpl>((ref) {
  return PhotoUploadRepositoryImpl(ref.watch(dioProvider));
});
