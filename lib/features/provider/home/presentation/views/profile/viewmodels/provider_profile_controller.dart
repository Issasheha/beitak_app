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
    if (iso.isEmpty) return 'Member since —';
    final year = iso.length >= 4 ? iso.substring(0, 4) : '';
    return year.isEmpty ? 'Member since —' : 'Member since $year';
  }

  Future<int> _resolveProviderId() async {
    final res = await ApiClient.dio.get(ApiConstants.authProfile);
    final data = res.data ?? {};
    final u = data['data']?['user'];
    final pp = (u is Map) ? u['provider_profile'] : null;
    final id = (pp is Map) ? pp['id'] : null;

    final providerId =
        (id is num) ? id.toInt() : int.tryParse(id?.toString() ?? '');
    if (providerId == null || providerId <= 0) {
      throw Exception('تعذر تحديد رقم مزود الخدمة (providerId).');
    }
    return providerId;
  }

  /// ✅ bio ممكن يكون بمكانين حسب backend
  String _extractBio(Map<String, dynamic> providerData) {
    final direct = _s(providerData['bio']);
    if (direct.isNotEmpty) return direct;

    final user = providerData['user'];
    if (user is Map) {
      final fromUser = _s(user['bio']);
      if (fromUser.isNotEmpty) return fromUser;
    }
    return '—';
  }

  /// ✅ server بده email (وأحيانًا غيره) موجودين دائمًا في PATCH
  Future<Map<String, dynamic>> _enrichPatchPayload(
      Map<String, dynamic> payload) async {
    final enriched = Map<String, dynamic>.from(payload);

    // 1) حاول من state الحالي (provider.user)
    final current = state.asData?.value;
    Map? user;
    if (current != null) {
      final p = current.provider;
      user = (p['user'] is Map) ? (p['user'] as Map) : null;
    }

    String email = user != null ? _s(user['email']) : '';
    String phone = user != null ? _s(user['phone']) : '';
    String firstName = user != null ? _s(user['first_name']) : '';
    String lastName = user != null ? _s(user['last_name']) : '';

    // 2) fallback من /auth/profile لو ناقص
    if (email.isEmpty || firstName.isEmpty || lastName.isEmpty || phone.isEmpty) {
      try {
        final res = await ApiClient.dio.get(ApiConstants.authProfile);
        final u = (res.data?['data']?['user'] ?? {}) as Map<String, dynamic>;
        email = email.isEmpty ? _s(u['email']) : email;
        phone = phone.isEmpty ? _s(u['phone']) : phone;
        firstName = firstName.isEmpty ? _s(u['first_name']) : firstName;
        lastName = lastName.isEmpty ? _s(u['last_name']) : lastName;
      } catch (_) {
        // ignore: نحاول قدر الإمكان
      }
    }

    // 3) ضيفهم إذا مش موجودين بالـ payload (وغير فاضيين)
    void putIfMissing(String key, String value) {
      if (!enriched.containsKey(key) && value.trim().isNotEmpty) {
        enriched[key] = value.trim();
      }
    }

    putIfMissing('email', email);
    putIfMissing('phone', phone);
    putIfMissing('first_name', firstName);
    putIfMissing('last_name', lastName);

    // آخر حماية
    if (_s(enriched['email']).isEmpty) {
      throw Exception('تعذر تحديث البروفايل: البريد الإلكتروني غير متوفر محلياً.');
    }

    return enriched;
  }

  ProviderProfileState _buildStateFromProvider({
    required Map<String, dynamic> providerData,
    required int totalBookings,
    required int completedBookings,
    required double rating,
    required int ratingCount,
  }) {
    final user = providerData['user'];
    final first = _s(user is Map ? user['first_name'] : null);
    final last = _s(user is Map ? user['last_name'] : null);

    final displayName = (first.isNotEmpty || last.isNotEmpty)
        ? ('$first $last').trim()
        : (_s(providerData['business_name']).isNotEmpty
            ? _s(providerData['business_name'])
            : 'مزود خدمة');

    String categoryLabel = 'خدمات';
    final cat = providerData['category'];
    final catAr = _s(cat is Map ? cat['name_ar'] : null);
    final catName = _s(cat is Map ? cat['name'] : null);
    if (catAr.isNotEmpty) {
      categoryLabel = catAr;
    } else if (catName.isNotEmpty) {
      categoryLabel = catName;
    }

    final memberSinceLabel =
        _memberSinceLabelFromIso(_s(providerData['created_at']));

    final bio = _extractBio(providerData);
    final isAvailable = providerData['instant_booking'] == true;
    final experienceYears = _i(providerData['experience_years']);

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
          verified: false,
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
      experienceYears: experienceYears,
      displayName: displayName,
      categoryLabel: categoryLabel,
      memberSinceLabel: memberSinceLabel,
      bio: bio,
      isAvailable: isAvailable,
      locationLabel: locationLabel,
      documents: docs,
    );
  }

  // ---------- load / refresh ----------
  Future<void> load() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final providerId = await _resolveProviderId();

      final providerRes =
          await ApiClient.dio.get(ApiConstants.providerById(providerId));
      final providerData =
          (providerRes.data?['data']?['provider'] ?? <String, dynamic>{})
              as Map<String, dynamic>;

      int totalBookings = _i(providerData['total_bookings']);
      int completedBookings = 0;
      double rating = _d(providerData['rating_avg']);
      int ratingCount = _i(providerData['rating_count']);

      try {
        final statsRes =
            await ApiClient.dio.get(ApiConstants.providerDashboardStats);
        final stats = statsRes.data?['data']?['statistics'] ?? {};

        totalBookings = _i(stats['total_bookings']);
        completedBookings = _i(stats['completed_bookings']);
        rating = _d(stats['rating']);
        ratingCount = _i(stats['rating_count']);
      } catch (_) {}

      return _buildStateFromProvider(
        providerData: providerData,
        totalBookings: totalBookings,
        completedBookings: completedBookings,
        rating: rating,
        ratingCount: ratingCount,
      );
    });
  }

  Future<void> refresh() => load();

  Future<Map<String, dynamic>> _patchProviderProfile(
      Map<String, dynamic> payload) async {
    final enriched = await _enrichPatchPayload(payload);

    final res = await ApiClient.dio.patch(
      ApiConstants.providerProfilePatch,
      data: enriched,
    );

    final provider =
        (res.data?['data']?['provider'] ?? <String, dynamic>{})
            as Map<String, dynamic>;

    if (provider.isEmpty) {
      throw Exception('فشل تحديث البروفايل: الرد لا يحتوي provider');
    }
    return provider;
  }

  // ---------- updates ----------
  Future<void> updateAvailability(bool value) async {
    final current = state.asData?.value;
    if (current == null) return;

    try {
      final provider = await _patchProviderProfile({'instant_booking': value});
      state = AsyncData(_buildStateFromProvider(
        providerData: provider,
        totalBookings: current.totalBookings,
        completedBookings: current.completedBookings,
        rating: current.rating,
        ratingCount: current.ratingCount,
      ));
    } on DioException catch (e) {
      throw Exception(_friendlyDioError(e));
    }
  }

  /// ✅ bio تحفظ من أول مرة + ما عاد يطلع email empty
  Future<void> updateBio(String newBio) async {
    final current = state.asData?.value;
    if (current == null) return;

    final trimmed = newBio.trim();
    final optimisticBio = trimmed.isEmpty ? '—' : trimmed;

    state = AsyncData(current.copyWith(bio: optimisticBio));

    try {
      final provider = await _patchProviderProfile({'bio': trimmed});
      state = AsyncData(_buildStateFromProvider(
        providerData: provider,
        totalBookings: current.totalBookings,
        completedBookings: current.completedBookings,
        rating: current.rating,
        ratingCount: current.ratingCount,
      ));
    } on DioException catch (e) {
      state = AsyncData(current);
      throw Exception(_friendlyDioError(e));
    } catch (e) {
      state = AsyncData(current);
      throw Exception(e.toString());
    }
  }

  /// ✅ تحديث سنوات الخبرة
  Future<void> updateExperienceYears(int years) async {
    final current = state.asData?.value;
    if (current == null) return;

    final safe = years < 0 ? 0 : years;
    state = AsyncData(current.copyWith(experienceYears: safe));

    try {
      final provider =
          await _patchProviderProfile({'experience_years': safe});
      state = AsyncData(_buildStateFromProvider(
        providerData: provider,
        totalBookings: current.totalBookings,
        completedBookings: current.completedBookings,
        rating: current.rating,
        ratingCount: current.ratingCount,
      ));
    } on DioException catch (e) {
      state = AsyncData(current);
      throw Exception(_friendlyDioError(e));
    } catch (e) {
      state = AsyncData(current);
      throw Exception(e.toString());
    }
  }

  String _friendlyDioError(DioException e) {
    final code = e.response?.statusCode;
    final msg = _s(e.response?.data?['message']);

    if (code == 400 && msg == 'email_cannot_be_empty') {
      return 'السيرفر يتطلب إرسال البريد الإلكتروني مع أي تعديل. (تمت معالجة ذلك، جرّب مرة ثانية)';
    }
    if (code == 401) return 'غير مصرح. تأكد أنك مسجل دخول.';
    if (code == 403) return 'ليس لديك صلاحية.';
    if (code == 404) return 'المسار غير موجود على السيرفر.';
    if (msg.isNotEmpty) return msg;
    return 'حدث خطأ بالشبكة، حاول مرة أخرى.';
  }
}
