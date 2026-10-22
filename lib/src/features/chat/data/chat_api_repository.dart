import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/config/api_config.dart';

final chatApiProvider = Provider.autoDispose<ChatApiRepository>((ref) {
  final token = ref.watch(authStateProvider.select((s) => s.sessionToken));
  final api = ChatApiRepository(token);
  ref.onDispose(api.close);
  return api;
});

class ChatApiRepository {
  final Dio _dio;
  ChatApiRepository(String? token)
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          headers: {'Authorization': 'Bearer ${token ?? ''}'},
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
  void close() => _dio.close(force: true);

  Future<List<Map<String, dynamic>>> conversations() async {
    final response = await _dio.get('/api/chat/conversations');
    return (response.data['conversations'] as List)
        .map((v) => Map<String, dynamic>.from(v as Map))
        .toList();
  }

  Future<Map<String, dynamic>> like(String username) async {
    final response = await _dio.post(
      '/api/chat/likes',
      data: {'username': username},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<Map<String, dynamic>>> messages(
    String id, {
    String? before,
  }) async {
    final response = await _dio.get(
      '/api/chat/conversations/$id/messages',
      queryParameters: {'before': ?before},
    );
    return (response.data['messages'] as List)
        .map((v) => Map<String, dynamic>.from(v as Map))
        .toList();
  }

  Future<void> send(String id, String text) async {
    await _dio.post(
      '/api/chat/conversations/$id/messages',
      data: {'text': text},
    );
  }
}

String chatError(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
  }
  return 'Could not connect. Check your connection and try again.';
}
