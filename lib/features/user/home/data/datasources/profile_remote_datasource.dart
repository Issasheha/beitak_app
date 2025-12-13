import 'dart:io';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:dio/dio.dart';

import '../models/user_profile_model.dart';

class ProfileRemoteDataSource {
  final Dio dio;
  const ProfileRemoteDataSource(this.dio);

  Future<UserProfileModel> getProfile() async {
    final res = await dio.get(ApiConstants.authProfile);
    return UserProfileModel.fromAny(res.data);
  }

  Future<UserProfileModel> updateProfile(Map<String, dynamic> payload) async {
    // ✅ backend صار PATCH حسب كلامك، لو أنت مخلّيه PUT غيّره لـ patch
    final res = await dio.patch(ApiConstants.userProfile, data: payload);
    return UserProfileModel.fromAny(res.data);
  }

  Future<UserProfileModel> uploadProfileImage(String filePath) async {
    final file = File(filePath);
    final form = FormData.fromMap({
      'image': await MultipartFile.fromFile(file.path),
    });

    final res = await dio.post(ApiConstants.userProfileImage, data: form);
    return UserProfileModel.fromAny(res.data);
  }

  Future<void> changePassword(Map<String, dynamic> payload) async {
    // ✅ endpoint عندك POST حسب Postman (مش PUT)
    await dio.post(ApiConstants.changePassword, data: payload);
  }

  Future<void> deleteAccount() async {
    await dio.delete(ApiConstants.userProfile); // DELETE /api/users/profile
  }

  /// ✅ New: Recent Activity من endpoint الرسمي
  Future<List<Map<String, dynamic>>> getRecentActivityRaw({int limit = 10}) async {
    final res = await dio.get(
      ApiConstants.userProfileActivity,
      queryParameters: {'limit': limit},
    );

    final root = res.data;
    if (root is Map<String, dynamic>) {
      final data = root['data'];
      if (data is Map<String, dynamic>) {
        final acts = data['activities'];
        if (acts is List) {
          return acts
              .whereType<Map>()
              .map((e) => e.cast<String, dynamic>())
              .toList();
        }
      }
    }

    throw const FormatException('Invalid activity response format');
  }

  /// (اختياري) لو بدك تبقيه للمستقبل أو fallback
  Future<List<Map<String, dynamic>>> getMyBookings({int limit = 10}) async {
    final res = await dio.get(
      ApiConstants.userBookings,
      queryParameters: {'per_page': limit},
    );

    final root = res.data;
    if (root is Map<String, dynamic>) {
      final d = root['data'];
      if (d is Map<String, dynamic>) {
        final bookings = d['bookings'];
        if (bookings is List) {
          return bookings
              .whereType<Map>()
              .map((e) => e.cast<String, dynamic>())
              .toList();
        }
      }
    }

    throw const FormatException('Invalid bookings response format');
  }
}
