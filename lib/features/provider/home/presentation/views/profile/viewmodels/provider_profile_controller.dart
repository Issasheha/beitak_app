// lib/features/provider/home/presentation/views/profile/viewmodels/provider_profile_controller.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';

import 'provider_profile_state.dart';

class ProviderProfileController
    extends StateNotifier<AsyncValue<ProviderProfileState>> {
  ProviderProfileController(this.ref) : super(const AsyncLoading()) {
    load();
  }

  final Ref ref;

  // ---------- cache ----------
  final Map<int, Map<String, dynamic>> _categoriesById = {};
  int? _cachedProviderId;
  Map<String, dynamic>? _cachedAuthUser;

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

  bool _b(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) return v.toLowerCase() == 'true';
    return false;
  }

  DocStatus _docStatus({
    required bool verified,
    required bool hasFile,
    required bool requiredDoc,
  }) {
    if (verified) return DocStatus.verified;
    if (hasFile) return DocStatus.inReview;
    return requiredDoc ? DocStatus.required : DocStatus.recommended;
  }

  String _memberSinceLabelFromIso(String iso) {
    if (iso.isEmpty) return 'عضو منذ —';
    final year = iso.length >= 4 ? iso.substring(0, 4) : '';
    return year.isEmpty ? 'عضو منذ —' : 'عضو منذ $year';
  }

  Future<Map<String, dynamic>> _fetchAuthUserCached() async {
    if (_cachedAuthUser != null) return _cachedAuthUser!;

    final res = await ApiClient.dio.get(ApiConstants.authProfile);
    final u = (res.data?['data']?['user'] ?? <String, dynamic>{})
        as Map<String, dynamic>;

    _cachedAuthUser = u;
    return u;
  }

  Future<int> _resolveProviderId() async {
    if (_cachedProviderId != null && _cachedProviderId! > 0) {
      return _cachedProviderId!;
    }

    final u = await _fetchAuthUserCached();
    final pp = u['provider_profile'];
    final id = (pp is Map) ? pp['id'] : null;

    final providerId =
        (id is num) ? id.toInt() : int.tryParse(id?.toString() ?? '');
    if (providerId == null || providerId <= 0) {
      throw Exception('تعذر تحديد رقم مزود الخدمة (providerId).');
    }

    _cachedProviderId = providerId;
    return providerId;
  }

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

  // ===================== Categories =====================

  Future<void> _ensureCategoriesLoaded() async {
    if (_categoriesById.isNotEmpty) return;

    final res = await ApiClient.dio.get(ApiConstants.categories);
    final data = res.data;

    final list = (data is Map)
        ? (data['data']?['categories'] ??
            data['data']?['items'] ??
            data['categories'] ??
            data['items'])
        : null;

    if (list is List) {
      for (final item in list) {
        if (item is Map) {
          final id = _i(item['id']);
          if (id > 0) {
            _categoriesById[id] = Map<String, dynamic>.from(item);
          }
        }
      }
    }
  }

  String _categoryLabelFromCategoryMap(Map<String, dynamic> cat) {
    final ar = _s(cat['name_ar']);
    if (ar.isNotEmpty) return ar;

    final name = _s(cat['name']);
    if (name.isNotEmpty) return name;

    final en = _s(cat['name_en']);
    if (en.isNotEmpty) return en;

    return '—';
  }

  Future<String> _resolveCategoryLabel(Map<String, dynamic> providerData) async {
    final cat = providerData['category'];
    if (cat is Map) {
      final lbl = _categoryLabelFromCategoryMap(Map<String, dynamic>.from(cat));
      if (lbl.trim().isNotEmpty && lbl != '—') return lbl;
    }

    final categoryId = _i(providerData['category_id']);
    if (categoryId <= 0) return '—';

    await _ensureCategoriesLoaded();

    final mapped = _categoriesById[categoryId];
    if (mapped == null) return '—';

    final lbl = _categoryLabelFromCategoryMap(mapped);
    return (lbl.trim().isEmpty) ? '—' : lbl;
  }

  // ✅ server بده email (وأحيانًا غيره) موجودين دائمًا في PATCH (bio/experience etc.)
  Future<Map<String, dynamic>> _enrichPatchPayload(
    Map<String, dynamic> payload,
  ) async {
    final enriched = Map<String, dynamic>.from(payload);

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

    if (email.isEmpty || firstName.isEmpty || lastName.isEmpty || phone.isEmpty) {
      try {
        final u = await _fetchAuthUserCached();
        email = email.isEmpty ? _s(u['email']) : email;
        phone = phone.isEmpty ? _s(u['phone']) : phone;
        firstName = firstName.isEmpty ? _s(u['first_name']) : firstName;
        lastName = lastName.isEmpty ? _s(u['last_name']) : lastName;
      } catch (_) {}
    }

    void putIfMissing(String key, String value) {
      if (!enriched.containsKey(key) && value.trim().isNotEmpty) {
        enriched[key] = value.trim();
      }
    }

    putIfMissing('email', email);
    putIfMissing('phone', phone);
    putIfMissing('first_name', firstName);
    putIfMissing('last_name', lastName);

    if (_s(enriched['email']).isEmpty) {
      throw Exception('تعذر تحديث البروفايل: البريد الإلكتروني غير متوفر محلياً.');
    }

    return enriched;
  }

  /// ✅ قراءة is_active من:
  /// 1) providerData.user.is_active
  /// 2) auth cache user.is_active
  /// 3) fallback قديم: providerData.instant_booking
  bool _resolveIsActive(Map<String, dynamic> providerData) {
    final u1 = providerData['user'];
    if (u1 is Map && u1.containsKey('is_active')) {
      return _b(u1['is_active']);
    }

    final auth = _cachedAuthUser;
    if (auth != null && auth.containsKey('is_active')) {
      return _b(auth['is_active']);
    }

    return providerData['instant_booking'] == true;
  }

  ProviderProfileState _buildStateFromProviderSync({
    required Map<String, dynamic> providerData,
    required int totalBookings,
    required int completedBookings,
    required double rating,
    required int ratingCount,
    required String categoryLabel,
  }) {
    final user = providerData['user'];
    final first = _s(user is Map ? user['first_name'] : null);
    final last = _s(user is Map ? user['last_name'] : null);

    final displayName = (first.isNotEmpty || last.isNotEmpty)
        ? ('$first $last').trim()
        : (_s(providerData['business_name']).isNotEmpty
            ? _s(providerData['business_name'])
            : 'مزود خدمة');

    final memberSinceLabel =
        _memberSinceLabelFromIso(_s(providerData['created_at']));

    final bio = _extractBio(providerData);

    // ✅ يعتمد على is_active
    final isAvailable = _resolveIsActive(providerData);

    final experienceYears = _i(providerData['experience_years']);

    String locationLabel = '';
    if (user is Map) {
      final city = user['city'];
      final cityAr = _s(city is Map ? city['name_ar'] : null);
      final cityName = _s(city is Map ? city['name'] : null);
      final cityEn = _s(city is Map ? city['name_en'] : null);

      if (cityAr.isNotEmpty) {
        locationLabel = cityAr;
      } else if (cityName.isNotEmpty) {
        locationLabel = cityName;
      } else if (cityEn.isNotEmpty) {
        locationLabel = cityEn;
      }
    }

    final hasIdFile = _s(providerData['id_verified_image']).isNotEmpty;
    final hasLicenseFile = _s(providerData['vocational_license_image']).isNotEmpty;
    final hasPoliceFile = _s(providerData['police_clearance_image']).isNotEmpty;

    final idVerified = _b(providerData['is_id_verified']);
    final licenseVerified = _b(providerData['is_license_verified']);
    final policeVerified = _b(providerData['is_police_clearance_verified']);

    // ✅ حسب كلامك: المطلوب للتفعيل = هوية + رخصة فقط
    final isFullyVerified = idVerified && licenseVerified;

    final missingRequiredDocs = <String>[];
    if (!idVerified) missingRequiredDocs.add('بطاقة الهوية');
    if (!licenseVerified) missingRequiredDocs.add('الرخصة المهنية');

    final docs = <ProviderDocumentItem>[
      ProviderDocumentItem(
        title: 'الهوية الوطنية',
        status: _docStatus(
          verified: idVerified,
          hasFile: hasIdFile,
          requiredDoc: true,
        ),
      ),
      ProviderDocumentItem(
        title: 'الرخصة التجارية',
        status: _docStatus(
          verified: licenseVerified,
          hasFile: hasLicenseFile,
          requiredDoc: true,
        ),
      ),
      ProviderDocumentItem(
        title: 'فحص السجل الجنائي',
        status: _docStatus(
          verified: policeVerified,
          hasFile: hasPoliceFile,
          requiredDoc: false,
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
      isFullyVerified: isFullyVerified,
      missingRequiredDocs: missingRequiredDocs,
      isUpdatingAvailability: false,
    );
  }

  // ---------- load / refresh ----------
  Future<void> load() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _fetchAuthUserCached();

      final providerId = await _resolveProviderId();

      final providerFuture = ApiClient.dio.get(ApiConstants.providerById(providerId));
      final statsFuture = ApiClient.dio
          .get(ApiConstants.providerDashboardStats)
          .catchError((_) => null);

      final providerRes = await providerFuture;
      final providerData =
          (providerRes.data?['data']?['provider'] ?? <String, dynamic>{})
              as Map<String, dynamic>;

      int totalBookings = _i(providerData['total_bookings']);
      int completedBookings = 0;
      double rating = _d(providerData['rating_avg']);
      int ratingCount = _i(providerData['rating_count']);

      final statsRes = await statsFuture;
      if (statsRes != null) {
        final stats = statsRes.data?['data']?['statistics'] ?? {};
        totalBookings = _i(stats['total_bookings']);
        completedBookings = _i(stats['completed_bookings']);
        rating = _d(stats['rating']);
        ratingCount = _i(stats['rating_count']);
      }

      final categoryLabel = await _resolveCategoryLabel(providerData);

      return _buildStateFromProviderSync(
        providerData: providerData,
        totalBookings: totalBookings,
        completedBookings: completedBookings,
        rating: rating,
        ratingCount: ratingCount,
        categoryLabel: categoryLabel,
      );
    });
  }

  Future<void> refresh() => load();

  Future<Map<String, dynamic>> _patchProviderProfile(
    Map<String, dynamic> payload,
  ) async {
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

  /// ✅ NEW: تفعيل/تعطيل الحساب عبر endpoints الجديدة
  /// - نأخذ is_active مباشرة من response (حل مشكلة "رجع غير مفعل")
  Future<void> updateAvailability(bool value) async {
    final current = state.asData?.value;
    if (current == null) return;

    state = AsyncData(current.copyWith(isUpdatingAvailability: true));

    try {
      final endpoint =
          value ? ApiConstants.providerActivate : ApiConstants.providerDeactivate;

      final res = await ApiClient.dio.patch(endpoint);

      // ✅ اقرأ مباشرة من response
      final serverActiveRaw = res.data?['data']?['user']?['is_active'];
      final finalActive = (serverActiveRaw == null) ? value : _b(serverActiveRaw);

      // ✅ حدث provider.user.is_active داخل state
      final updatedProvider = Map<String, dynamic>.from(current.provider);
      final user = (updatedProvider['user'] is Map)
          ? Map<String, dynamic>.from(updatedProvider['user'] as Map)
          : <String, dynamic>{};

      user['is_active'] = finalActive;
      updatedProvider['user'] = user;

      // ✅ صفّر الكاش حتى الجلب القادم يكون نظيف
      _cachedAuthUser = null;

      state = AsyncData(
        current.copyWith(
          isUpdatingAvailability: false,
          isAvailable: finalActive,
          provider: updatedProvider,
        ),
      );
    } on DioException catch (e) {
      state = AsyncData(current.copyWith(isUpdatingAvailability: false));
      throw Exception(_friendlyDioError(e));
    } catch (e) {
      state = AsyncData(current.copyWith(isUpdatingAvailability: false));
      throw Exception(e.toString());
    }
  }

  Future<void> updateBio(String newBio) async {
    final current = state.asData?.value;
    if (current == null) return;

    final trimmed = newBio.trim();
    final optimisticBio = trimmed.isEmpty ? '—' : trimmed;

    state = AsyncData(current.copyWith(bio: optimisticBio));

    try {
      final provider = await _patchProviderProfile({'bio': trimmed});
      final categoryLabel = await _resolveCategoryLabel(provider);

      state = AsyncData(_buildStateFromProviderSync(
        providerData: provider,
        totalBookings: current.totalBookings,
        completedBookings: current.completedBookings,
        rating: current.rating,
        ratingCount: current.ratingCount,
        categoryLabel: categoryLabel,
      ));
    } on DioException catch (e) {
      state = AsyncData(current);
      throw Exception(_friendlyDioError(e));
    } catch (e) {
      state = AsyncData(current);
      throw Exception(e.toString());
    }
  }

  Future<void> updateExperienceYears(int years) async {
    final current = state.asData?.value;
    if (current == null) return;

    final safe = years < 0 ? 0 : years;
    state = AsyncData(current.copyWith(experienceYears: safe));

    try {
      final provider = await _patchProviderProfile({'experience_years': safe});
      final categoryLabel = await _resolveCategoryLabel(provider);

      state = AsyncData(_buildStateFromProviderSync(
        providerData: provider,
        totalBookings: current.totalBookings,
        completedBookings: current.completedBookings,
        rating: current.rating,
        ratingCount: current.ratingCount,
        categoryLabel: categoryLabel,
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
    if (code == 401) return 'انتهت الجلسة. أعد تسجيل الدخول.';
    if (code == 403) return 'ليس لديك صلاحية.';
    if (code == 404) return 'المسار غير موجود على السيرفر.';
    if (msg.isNotEmpty) {
      // ✅ رسائل activate/deactivate
      if (msg == 'account_activated') return 'تم تفعيل الحساب';
      return msg;
    }
    return 'حدث خطأ بالشبكة، حاول مرة أخرى.';
  }
}
