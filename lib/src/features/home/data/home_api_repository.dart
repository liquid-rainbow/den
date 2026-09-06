import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';

class HomeApiRepository {
  final Dio _dio;

  HomeApiRepository(this._dio);

  Future<List<Map<String, dynamic>>> getFeed({required int radiusKm}) async {
    final response = await _dio.get('/api/home/feed', queryParameters: {
      'radius': radiusKm,
    });
    return List<Map<String, dynamic>>.from(response.data['events']);
  }
}

final homeApiRepositoryProvider = Provider<HomeApiRepository>((ref) {
  return HomeApiRepository(ref.watch(dioProvider));
});

final homeFeedProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, radiusKm) {
  final repo = ref.watch(homeApiRepositoryProvider);
  return repo.getFeed(radiusKm: radiusKm);
});
