import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_config.dart';
import 'mock_interceptor.dart';

/// Provides a singleton, configured instance of Dio for the entire app.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
    ),
  );

  if (ApiConfig.isMockMode) {
    dio.interceptors.add(MockInterceptor());
  }

  // Add Auth Interceptor (Placeholder for full implementation)
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // TODO: Read secure token from storage and attach to header.
        // Example: 
        // final token = await secureStorage.read(key: 'jwt');
        // if (token != null) {
        //   options.headers['Authorization'] = 'Bearer $token';
        // }
        return handler.next(options); 
      },
      onError: (DioException e, handler) async {
        // TODO: Handle global 401 Unauthorized (e.g. refresh token or force logout)
        if (e.response?.statusCode == 401) {
          // Trigger logout or refresh
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
});
