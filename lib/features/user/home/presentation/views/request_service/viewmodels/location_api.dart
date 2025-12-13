// import 'package:beitak_app/core/network/api_client.dart';
// import 'package:dio/dio.dart';

// import '../models/location_models.dart';

// class LocationApi {
//   final Dio _dio;
//   LocationApi({Dio? dio}) : _dio = dio ?? ApiClient.dio;

//   Future<List<CityModel>> fetchCities() async {
//     final res = await _dio.get('/locations/cities');
//     final data = res.data;
//     if (data is Map && data['data'] is Map && (data['data']['cities'] is List)) {
//       final list = (data['data']['cities'] as List)
//           .whereType<Map>()
//           .map((e) => CityModel.fromJson(e.cast<String, dynamic>()))
//           .toList();
//       return list;
//     }
//     return const [];
//   }

//   Future<List<AreaModel>> fetchAreasByCitySlug(String citySlug) async {
//     final res = await _dio.get('/locations/areas/$citySlug');
//     final data = res.data;

//     // متوقع: { success, data: { areas: [...] } } أو شيء قريب
//     if (data is Map && data['data'] is Map) {
//       final d = data['data'] as Map;

//       final rawAreas = d['areas'];
//       if (rawAreas is List) {
//         return rawAreas
//             .whereType<Map>()
//             .map((e) => AreaModel.fromJson(e.cast<String, dynamic>()))
//             .toList();
//       }
//     }
//     return const [];
//   }
// } 