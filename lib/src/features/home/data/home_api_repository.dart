import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/network/dio_provider.dart';

class HomeApiRepository {
  final Dio _dio;

  HomeApiRepository(this._dio);

  Future<List<Map<String, dynamic>>> getFeed({required int radiusKm}) async {
    double? lat;
    double? lng;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
          );
          lat = position.latitude;
          lng = position.longitude;
        }
      }
    } catch (e) {
      // Ignore and fallback to backend defaults if location cannot be accessed
    }

    final queryParams = <String, dynamic>{
      'radius': radiusKm,
    };
    if (lat != null && lng != null) {
      queryParams['lat'] = lat;
      queryParams['lng'] = lng;
    }

    final response = await _dio.get('/api/home/feed', queryParameters: queryParams);
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
