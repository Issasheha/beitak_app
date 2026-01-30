// lib/features/user/home/presentation/providers/user_profile_provider.dart
// P1: Provider to fetch user profile data, replacing direct Dio access in views

import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fetches the user's city ID from their profile.
/// Returns null if not logged in or city not set.
final userProfileCityIdProvider = FutureProvider.autoDispose<int?>((ref) async {
  return UserProfileService.fetchCityId();
});

/// Service class for user profile operations.
/// Encapsulates API calls to keep views clean.
class UserProfileService {
  UserProfileService._();

  /// Fetch the user's city_id from their profile.
  /// Tries both auth/profile and user/profile endpoints.
  static Future<int?> fetchCityId() async {
    // Try auth profile endpoint first
    int? cityId = await _tryFetchCityFromEndpoint(ApiConstants.authProfile);
    if (cityId != null) return cityId;

    // Fallback to user profile endpoint
    cityId = await _tryFetchCityFromEndpoint(ApiConstants.userProfile);
    return cityId;
  }

  static Future<int?> _tryFetchCityFromEndpoint(String endpoint) async {
    try {
      final res = await ApiClient.dio.get(endpoint);
      final root = res.data;

      if (root is Map) {
        final data = root['data'];
        if (data is Map) {
          final user = data['user'] ?? data;
          if (user is Map) {
            final v = user['city_id'];
            if (v is num) return v.toInt();
            return int.tryParse(v?.toString() ?? '');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('UserProfileService.fetchCityId error: $e');
      }
    }
    return null;
  }
}
