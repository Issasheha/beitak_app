import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/models/provider_service_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final providerMyServicesProvider = FutureProvider<List<ProviderServiceModel>>((ref) async {
  final res = await ApiClient.dio.get(ApiConstants.providerMyServices);

  final data = res.data;

  // دعم أكثر من شكل response
  final servicesJson = (data is Map && data['data'] is Map && data['data']['services'] is List)
      ? (data['data']['services'] as List)
      : (data is Map && data['services'] is List)
          ? (data['services'] as List)
          : (data is Map && data['data'] is List)
              ? (data['data'] as List)
              : (data is List)
                  ? data
                  : <dynamic>[];

  return servicesJson
      .map((e) => ProviderServiceModel.fromJson(Map<String, dynamic>.from(e)))
      .toList();
});
