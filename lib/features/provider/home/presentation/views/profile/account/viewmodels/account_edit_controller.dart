import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:beitak_app/core/error/exceptions.dart';

import 'account_edit_state.dart';

class AccountEditController extends StateNotifier<AsyncValue<AccountEditState>> {
  AccountEditController(this.ref) : super(const AsyncLoading()) {
    load();
  }

  final Ref ref;

  int _reqId = 0;

  // cache
  int? _cachedProviderId;
  Map<String, dynamic>? _cachedAuthUser;

  String _s(dynamic v) => (v ?? '').toString().trim();

  int _i(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  // ===================== Safe JSON =====================

  Map<String, dynamic> _expectMap(dynamic data, {String? fallback}) {
    if (data is Map) return Map<String, dynamic>.from(data);

    if (data is String) {
      final s = data.toLowerCase();
      if (s.contains('<html') || s.contains('cloudflare')) {
        throw const ServerException(
          message: 'يوجد عطل مؤقت في الخادم. حاول مرة أخرى بعد قليل.',
        );
      }
      throw ServerException(
        message: fallback ?? 'استجابة غير متوقعة من الخادم. حاول مرة أخرى.',
      );
    }

    throw ServerException(
      message: fallback ?? 'استجابة غير متوقعة من الخادم. حاول مرة أخرى.',
    );
  }

  Map<String, dynamic> _extractDataMap(Map<String, dynamic> root) {
    final d = root['data'];
    if (d is Map) return Map<String, dynamic>.from(d);
    return root;
  }

  // ===================== Auth + Provider =====================

  Future<Map<String, dynamic>> _fetchAuthUserCached() async {
    if (_cachedAuthUser != null) return _cachedAuthUser!;

    try {
      final res = await ApiClient.dio.get(ApiConstants.authProfile);

      final root = _expectMap(
        res.data,
        fallback: 'تعذر قراءة بيانات المستخدم من الخادم.',
      );
      final data = _extractDataMap(root);

      final userRaw = data['user'];
      final user = _expectMap(
        userRaw,
        fallback: 'تعذر قراءة بيانات المستخدم من الخادم.',
      );

      _cachedAuthUser = user;
      return user;
    } on DioException catch (e) {
      throw ServerException(
        message: _friendlyDio(e),
        statusCode: e.response?.statusCode,
      );
    } on ServerException {
      rethrow;
    } catch (_) {
      throw const ServerException(message: 'حدث خطأ غير متوقع. حاول مرة أخرى.');
    }
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
      throw const ServerException(message: 'تعذر تحديد رقم مزود الخدمة.');
    }

    _cachedProviderId = providerId;
    return providerId;
  }

  String _pickLocalized(String direct, String ar, String en) {
    if (direct.trim().isNotEmpty) return direct.trim();
    if (ar.trim().isNotEmpty) return ar.trim();
    if (en.trim().isNotEmpty) return en.trim();
    return '';
  }

  Future<Map<String, dynamic>> _fetchProviderById(int providerId) async {
    try {
      final res = await ApiClient.dio.get(ApiConstants.providerById(providerId));
      final root =
          _expectMap(res.data, fallback: 'تعذر قراءة بيانات مزود الخدمة.');
      final data = _extractDataMap(root);

      final provider = _expectMap(
        data['provider'],
        fallback: 'تعذر تحميل بيانات مزود الخدمة.',
      );

      return provider;
    } on DioException catch (e) {
      throw ServerException(
        message: _friendlyDio(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<AccountEditState> _fetchState() async {
    final user = await _fetchAuthUserCached();
    final providerId = await _resolveProviderId();
    final provider = await _fetchProviderById(providerId);

    final fullName = '${_s(user['first_name'])} ${_s(user['last_name'])}'.trim();
    final email = _s(user['email']);
    final phone = _s(user['phone']);

    final isEmailVerified =
        user['email_verified'] == true || user['email_verified_at'] != null;
    final isPhoneVerified =
        user['phone_verified'] == true || user['phone_verified_at'] != null;

    final businessName = _pickLocalized(
      _s(provider['business_name']),
      _s(provider['business_name_ar']),
      _s(provider['business_name_en']),
    );

    final bio = _pickLocalized(
      _s(provider['bio']),
      _s(provider['bio_ar']),
      _s(provider['bio_en']),
    );

    final exp = _i(provider['experience_years']);

    return AccountEditState(
      fullName: fullName,
      email: email,
      phone: phone,
      isEmailVerified: isEmailVerified,
      isPhoneVerified: isPhoneVerified,
      isSavingProfile: false,
      isChangingPassword: false,
      providerId: providerId,
      businessName: businessName,
      bio: bio,
      experienceYears: exp,
    );
  }

  // ===================== Load / Refresh =====================

  Future<void> load() async {
    final id = ++_reqId;
    state = const AsyncLoading();

    try {
      final st = await _fetchState();
      if (id != _reqId) return;
      state = AsyncData(st);
    } on DioException catch (e, st) {
      if (id != _reqId) return;
      state = AsyncError(e, st);
    } on ServerException catch (e, st) {
      if (id != _reqId) return;
      state = AsyncError(e, st);
    } catch (e, st) {
      if (id != _reqId) return;
      state = AsyncError(e, st);
    }
  }

  Future<void> _refreshSilently({
    bool keepSavingProfile = false,
    bool keepChangingPassword = false,
  }) async {
    try {
      final current = state.asData?.value;
      final fresh = await _fetchState();

      state = AsyncData(
        fresh.copyWith(
          isSavingProfile:
              keepSavingProfile ? (current?.isSavingProfile ?? false) : false,
          isChangingPassword: keepChangingPassword
              ? (current?.isChangingPassword ?? false)
              : false,
        ),
      );
    } catch (_) {
      // تجاهل
    }
  }

  // ===================== Profile Save =====================

  Future<String?> saveProfile({
    required String fullName,
    required String email,
    String? phone, // UI only
  }) async {
    final current = state.asData?.value;
    if (current == null) return 'تعذر حفظ البيانات حالياً';

    state = AsyncData(current.copyWith(isSavingProfile: true));

    try {
      final parts = fullName.trim().split(RegExp(r'\s+'));
      final firstName = parts.isNotEmpty ? parts.first : '';
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      final businessName = current.businessName.trim();
      final bio = current.bio.trim();

      if (businessName.isEmpty || bio.isEmpty) {
        state = AsyncData(current.copyWith(isSavingProfile: false));
        return 'لا يمكن الحفظ لأن اسم النشاط أو النبذة غير متوفرين. افتح صفحة الملف الشخصي للمزود ثم ارجع وجرب.';
      }

      await ApiClient.dio.patch(
        ApiConstants.providerProfilePatch,
        data: {
          'email': email.trim(),
          'first_name': firstName,
          'last_name': lastName,
          'business_name': businessName,
          'bio': bio,
          'experience_years': current.experienceYears,
        },
      );

      await _refreshSilently(keepSavingProfile: true);

      final now = state.asData?.value ?? current;
      state = AsyncData(now.copyWith(isSavingProfile: false));
      return null;
    } on DioException catch (e) {
      state = AsyncData(current.copyWith(isSavingProfile: false));
      return _friendlyDio(e);
    } catch (_) {
      state = AsyncData(current.copyWith(isSavingProfile: false));
      return 'تعذر حفظ البيانات حالياً';
    }
  }

  // ===================== Password (NEW endpoint + QA messages) =====================

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
    String? confirmPassword, // UI only
  }) async {
    final current = state.asData?.value;
    if (current == null) return 'تعذر تحديث كلمة المرور';

    state = AsyncData(current.copyWith(isChangingPassword: true));

    try {
      await ApiClient.dio.patch(
        ApiConstants.userProfilePassword, // ✅ /users/profile/password
        data: {
          'oldPassword': currentPassword.trim(),
          'newPassword': newPassword.trim(),
        },
      );

      final now = state.asData?.value ?? current;
      state = AsyncData(now.copyWith(isChangingPassword: false));
      return null; // ✅ نجاح
    } on DioException catch (e) {
      state = AsyncData(current.copyWith(isChangingPassword: false));
      // ✅ رسالة عربية واضحة حسب QA
      return _friendlyPasswordDio(e);
    } catch (_) {
      state = AsyncData(current.copyWith(isChangingPassword: false));
      return 'تعذر تحديث كلمة المرور';
    }
  }

  // ===================== Phone OTP =====================

  Future<String?> requestPhoneOtp(String phone) async {
    try {
      await ApiClient.dio.post(
        ApiConstants.providerRequestPhoneOtp,
        data: {'phone': phone},
      );
      return null;
    } on DioException catch (e) {
      return _friendlyDio(e);
    } catch (_) {
      return 'تعذر إرسال رمز التحقق حالياً';
    }
  }

  Future<String?> verifyPhoneOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      await ApiClient.dio.post(
        ApiConstants.providerVerifyPhoneOtp,
        data: {'phone': phone, 'otp': otp},
      );

      // بعد نجاح التحقق: حدّث ال state.phone
      _cachedAuthUser = null;
      await _refreshSilently();
      return null;
    } on DioException catch (e) {
      return _friendlyDio(e);
    } catch (_) {
      return 'تعذر تأكيد الرقم حالياً';
    }
  }

  // ===================== Friendly error mapping (General) =====================

  String _friendlyDio(DioException e) {
    final code = e.response?.statusCode;
    final data = e.response?.data;

    // HTML/Cloudflare
    if (data is String) {
      final lower = data.toLowerCase();
      if (lower.contains('<html') || lower.contains('cloudflare')) {
        return 'يوجد عطل مؤقت في الخادم. حاول مرة أخرى بعد قليل.';
      }
    }

    // Validation errors array
    if (data is Map && data['errors'] is List) {
      final errs = (data['errors'] as List)
          .whereType<Map>()
          .map((m) => (m['message'] ?? '').toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (errs.isNotEmpty) return errs.join('\n');
    }

    String msg = '';
    if (data is Map) msg = (data['message'] ?? data['error'] ?? '').toString().trim();
    if (data is String) msg = data.trim();

    // OTP
    if (msg == 'otp_invalid' || msg == 'invalid_otp') return 'رمز التحقق غير صحيح';
    if (msg == 'otp_expired') return 'انتهت صلاحية الرمز، اطلب رمز جديد';
    if (msg == 'phone_already_used') return 'هذا الرقم مستخدم مسبقاً';

    if (code == 401) return 'انتهت الجلسة، أعد تسجيل الدخول';
    if (code == 403) return 'ليس لديك صلاحية';
    if (code == 404) return 'المسار غير موجود على الخادم';

    if (code == 400) return msg.isNotEmpty ? msg : 'بيانات غير صحيحة';
    if (msg.isNotEmpty) return msg;

    return 'خطأ بالشبكة، حاول مرة أخرى';
  }

  // ===================== Friendly error mapping (Password - QA) =====================

  String _friendlyPasswordDio(DioException e) {
    final code = e.response?.statusCode;
    final data = e.response?.data;

    // استخراج message/errors
    String msg = '';
    List<String> errors = [];

    if (data is Map) {
      msg = (data['message'] ?? data['error'] ?? '').toString().trim();

      if (data['errors'] is List) {
        errors = (data['errors'] as List)
            .whereType<Map>()
            .map((m) => (m['message'] ?? '').toString().trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
    } else if (data is String) {
      msg = data.trim();
    }

    // لو في errors واضحة من السيرفر
    final combined = errors.join(' ').toLowerCase();

    // ✅ توضيح السبب (old wrong vs policy)
    if (combined.contains('old') && combined.contains('incorrect')) {
      return 'كلمة المرور الحالية غير صحيحة.';
    }
    if (combined.contains('current') && combined.contains('incorrect')) {
      return 'كلمة المرور الحالية غير صحيحة.';
    }
    if (combined.contains('weak') || combined.contains('must') || combined.contains('at least')) {
      return 'كلمة المرور الجديدة لا تحقق الشروط المطلوبة.';
    }
    if (combined.contains('password') && combined.contains('requirements')) {
      return 'كلمة المرور الجديدة لا تحقق الشروط المطلوبة.';
    }

    // mapping codes شائعة (لو السيرفر برجع codes)
    final m = msg.toLowerCase();
    if (m == 'old_password_incorrect' || m == 'incorrect_old_password') {
      return 'كلمة المرور الحالية غير صحيحة.';
    }
    if (m == 'password_weak' || m == 'weak_password') {
      return 'كلمة المرور الجديدة لا تحقق الشروط المطلوبة.';
    }
    if (m.contains('validation') && errors.isNotEmpty) {
      // ما نعرض إنجليزي: أعطِ رسالة عربية عامة
      return 'يرجى التأكد من كلمة المرور الجديدة وأنها تحقق الشروط المطلوبة.';
    }

    // لو server رجّع errors نصوص إنجليزية فقط -> نخفيها برسالة عربية واضحة
    if (errors.isNotEmpty) {
      // حاول استنتاج:
      final anyOld = combined.contains('old') || combined.contains('current');
      final anyPolicy = combined.contains('uppercase') ||
          combined.contains('lowercase') ||
          combined.contains('number') ||
          combined.contains('special') ||
          combined.contains('length') ||
          combined.contains('at least');

      if (anyOld) return 'كلمة المرور الحالية غير صحيحة.';
      if (anyPolicy) return 'كلمة المرور الجديدة لا تحقق الشروط المطلوبة.';
      return 'تعذر تغيير كلمة المرور. يرجى مراجعة البيانات والمحاولة مرة أخرى.';
    }

    if (code == 400) {
      // بدون تفاصيل: رجّع عربي واضح بدل "Validation error"
      return 'تعذر تغيير كلمة المرور. تأكد من كلمة المرور الحالية ومن أن الجديدة تحقق الشروط.';
    }

    if (code == 401) return 'انتهت الجلسة، أعد تسجيل الدخول';
    if (code == 403) return 'ليس لديك صلاحية';

    return 'تعذر تغيير كلمة المرور حالياً. حاول مرة أخرى لاحقاً.';
  }
}
