import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'provider_profile_state.dart';

class ProviderProfileController
    extends StateNotifier<AsyncValue<ProviderProfileState>> {
  ProviderProfileController() : super(const AsyncLoading()) {
    load();
  }

  // ---------- helpers ----------
  String _s(dynamic v) => (v ?? '').toString().trim();

  double _d(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  int _i(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  DocStatus _docStatus({required bool verified, required bool hasFile}) {
    if (verified) return DocStatus.verified;
    if (hasFile) return DocStatus.inReview;
    return DocStatus.required;
  }

  String _memberSinceLabelFromIso(String iso) {
    // بالصورة: Member since 2022
    if (iso.isEmpty) return 'Member since —';
    final year = iso.length >= 4 ? iso.substring(0, 4) : '';
    return year.isEmpty ? 'Member since —' : 'Member since $year';
  }

  // ---------- load / refresh ----------
  Future<void> load() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      // ✅ Fetch provider via PUT /providers/profile (hack) - بدون /api
      final providerRes = await ApiClient.dio.put(
        ApiConstants.providerProfile, // لازم يكون موجود عندك
        data: const <String, dynamic>{},
      );

      final providerData =
          (providerRes.data?['data']?['provider'] ?? <String, dynamic>{})
              as Map<String, dynamic>;

      // fallback stats from provider
      int totalBookings = _i(providerData['total_bookings']);
      int completedBookings = 0;
      double rating = _d(providerData['rating_avg']);
      int ratingCount = _i(providerData['rating_count']);

      // try dashboard stats
      try {
        final statsRes =
            await ApiClient.dio.get(ApiConstants.providerDashboardStats);
        final stats = statsRes.data?['data']?['statistics'] ?? {};

        totalBookings = _i(stats['total_bookings']);
        completedBookings = _i(stats['completed_bookings']);
        rating = _d(stats['rating']);
        ratingCount = _i(stats['rating_count']);
      } catch (_) {
        // keep fallback
      }

      // display name
      final user = providerData['user'];
      final first = _s(user is Map ? user['first_name'] : null);
      final last = _s(user is Map ? user['last_name'] : null);

      final displayName = (first.isNotEmpty || last.isNotEmpty)
          ? ('$first $last').trim()
          : (_s(providerData['business_name']).isNotEmpty
              ? _s(providerData['business_name'])
              : 'مزود خدمة');

      // category label
      String categoryLabel = 'خدمات';
      final cat = providerData['category'];
      final catAr = _s(cat is Map ? cat['name_ar'] : null);
      final catName = _s(cat is Map ? cat['name'] : null);

      if (catAr.isNotEmpty) {
        categoryLabel = catAr;
      } else if (catName.isNotEmpty) {
        categoryLabel = catName;
      } else {
        // fallback قريب من الصورة
        categoryLabel = 'خدمات تنظيف';
      }

      // member since
      final memberSinceLabel =
          _memberSinceLabelFromIso(_s(providerData['created_at']));

      // bio
      final bio = _s(providerData['bio']).isNotEmpty ? _s(providerData['bio']) : '—';

      // availability (نستخدم instant_booking كسويتش التوفر)
      final isAvailable = providerData['instant_booking'] == true;

      // location label
      String locationLabel = 'عمان، الأردن';
      if (user is Map) {
        final city = user['city'];
        final area = user['area'];

        final cityAr = _s(city is Map ? city['name_ar'] : null);
        final areaAr = _s(area is Map ? area['name_ar'] : null);

        if (cityAr.isNotEmpty && areaAr.isNotEmpty) {
          locationLabel = '$areaAr، $cityAr';
        } else if (cityAr.isNotEmpty) {
          locationLabel = cityAr;
        }
      }

      // documents
      final hasIdFile = _s(providerData['id_verified_image']).isNotEmpty;
      final hasLicenseFile =
          _s(providerData['vocational_license_image']).isNotEmpty;
      final hasPoliceFile =
          _s(providerData['police_clearance_image']).isNotEmpty;

      final certs = providerData['certifications'];
      final hasCert = (certs is List && certs.isNotEmpty);

      final docs = <ProviderDocumentItem>[
        ProviderDocumentItem(
          title: 'الهوية الوطنية',
          status: _docStatus(
            verified: providerData['is_id_verified'] == true,
            hasFile: hasIdFile,
          ),
        ),
        ProviderDocumentItem(
          title: 'الرخصة التجارية',
          status: _docStatus(
            verified: providerData['is_license_verified'] == true,
            hasFile: hasLicenseFile,
          ),
        ),
        ProviderDocumentItem(
          title: 'الشهادة المهنية',
          status: _docStatus(
            verified: false, // ما في flag حالياً
            hasFile: hasCert,
          ),
        ),
        ProviderDocumentItem(
          title: 'فحص السجل الجنائي',
          status: _docStatus(
            verified: providerData['is_police_clearance_verified'] == true,
            hasFile: hasPoliceFile,
          ),
        ),
      ];

      return ProviderProfileState(
        provider: providerData,
        totalBookings: totalBookings,
        rating: rating,
        ratingCount: ratingCount,
        completedBookings: completedBookings,
        displayName: displayName,
        categoryLabel: categoryLabel,
        memberSinceLabel: memberSinceLabel,
        bio: bio,
        isAvailable: isAvailable,
        locationLabel: locationLabel,
        documents: docs,
      );
    });
  }

  Future<void> refresh() => load();

  // ---------- updates ----------
  Future<void> updateAvailability(bool value) async {
    final current = state.asData?.value;

    if (current == null) return;

    // optimistic
    state = AsyncData(current.copyWith(isAvailable: value));

    try {
      await ApiClient.dio.put(
        ApiConstants.providerProfile,
        data: <String, dynamic>{'instant_booking': value},
      );
    } on DioException catch (e) {
      // rollback
      state = AsyncData(current);
      throw Exception(_friendlyDioError(e));
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    }
  }

  Future<void> updateBio(String newBio) async {
    final current = state.asData?.value;

    if (current == null) return;

    final trimmed = newBio.trim();
    final nextBio = trimmed.isEmpty ? '—' : trimmed;

    state = AsyncData(current.copyWith(bio: nextBio));

    try {
      await ApiClient.dio.put(
        ApiConstants.providerProfile,
        data: <String, dynamic>{'bio': trimmed},
      );
    } on DioException catch (e) {
      state = AsyncData(current);
      throw Exception(_friendlyDioError(e));
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    }
  }

  // ---------- error helper ----------
  String _friendlyDioError(DioException e) {
    final code = e.response?.statusCode;
    final msg = _s(e.response?.data?['message']);
    if (code == 401) return 'غير مصرح. تأكد أنك مسجل دخول.';
    if (code == 403) return 'ليس لديك صلاحية.';
    if (code == 404) return 'المسار غير موجود على السيرفر.';
    if (msg.isNotEmpty) return msg;
    return 'حدث خطأ بالشبكة، حاول مرة أخرى.';
  }
}
