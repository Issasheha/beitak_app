// lib/features/user/home/presentation/views/request_service/viewmodels/service_request_draft.dart

import 'dart:io';

const _sentinel = Object();

class ServiceRequestDraft {
  final String name;
  final String phone;

  final int categoryId;
  final int cityId;
  final int? areaId;

  final String description;
  final double? budget;

  /// yyyy-MM-dd
  final String serviceDateIso;

  /// today / tomorrow / day_after / other
  final String serviceDateType;

  /// "HH:00"
  final String serviceTimeHour;

  final bool sharePhoneWithProvider;

  /// ملفات فعلية (مستخدمة للإرسال)
  final List<File> files;

  /// OTP للضيف فقط (لا ننصح نخزنه بالكاش)
  final String? otp;

  /// هل الطلب ضيف؟
  final bool isGuest;

  const ServiceRequestDraft({
    required this.name,
    required this.phone,
    required this.categoryId,
    required this.cityId,
    required this.description,
    required this.serviceDateIso,
    required this.serviceDateType,
    required this.serviceTimeHour,
    required this.sharePhoneWithProvider,
    required this.isGuest,
    this.areaId,
    this.budget,
    this.files = const [],
    this.otp,
  });

  /// ✅ الباك عندك لما other بقرأ service_date_value
  /// لذلك نجهزها هنا بدون ما نكرر تخزين قيمة ثانية
  String? get serviceDateValueForApi =>
      serviceDateType == 'other' ? serviceDateIso : null;

  ServiceRequestDraft copyWith({
    Object? name = _sentinel,
    Object? phone = _sentinel,
    Object? categoryId = _sentinel,
    Object? cityId = _sentinel,
    Object? areaId = _sentinel,
    Object? description = _sentinel,
    Object? budget = _sentinel,
    Object? serviceDateIso = _sentinel,
    Object? serviceDateType = _sentinel,
    Object? serviceTimeHour = _sentinel,
    Object? sharePhoneWithProvider = _sentinel,
    Object? files = _sentinel,
    Object? otp = _sentinel,
    Object? isGuest = _sentinel,
  }) {
    return ServiceRequestDraft(
      name: name == _sentinel ? this.name : name as String,
      phone: phone == _sentinel ? this.phone : phone as String,
      categoryId: categoryId == _sentinel ? this.categoryId : categoryId as int,
      cityId: cityId == _sentinel ? this.cityId : cityId as int,
      areaId: areaId == _sentinel ? this.areaId : areaId as int?,
      description:
          description == _sentinel ? this.description : description as String,
      budget: budget == _sentinel ? this.budget : budget as double?,
      serviceDateIso: serviceDateIso == _sentinel
          ? this.serviceDateIso
          : serviceDateIso as String,
      serviceDateType: serviceDateType == _sentinel
          ? this.serviceDateType
          : _normalizeDateType(serviceDateType as String),
      serviceTimeHour: serviceTimeHour == _sentinel
          ? this.serviceTimeHour
          : serviceTimeHour as String,
      sharePhoneWithProvider: sharePhoneWithProvider == _sentinel
          ? this.sharePhoneWithProvider
          : sharePhoneWithProvider as bool,
      files: files == _sentinel ? this.files : (files as List<File>),
      otp: otp == _sentinel ? this.otp : otp as String?,
      isGuest: isGuest == _sentinel ? this.isGuest : isGuest as bool,
    );
  }

  /// ✅ للكاش: نخزن كل شيء ما عدا otp (حسّاس ومؤقت)
  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'categoryId': categoryId,
        'cityId': cityId,
        'areaId': areaId,
        'description': description,
        'budget': budget,
        'serviceDateIso': serviceDateIso,
        'serviceDateType': serviceDateType,

        // ✅ للتوافق/الوضوح: نخزّنها فقط لو other (نفس iso)
        if (serviceDateType == 'other') 'serviceDateValue': serviceDateIso,

        'serviceTimeHour': serviceTimeHour,
        'sharePhoneWithProvider': sharePhoneWithProvider,
        'isGuest': isGuest,
        'files': files.map((f) => f.path).toList(), // نخزن المسارات فقط
      };

  /// ✅ من الكاش + يدعم الداتا القديمة
  static ServiceRequestDraft? fromJson(Map<String, dynamic> json) {
    try {
      // --- Backward compatibility ---
      final name = _s(json['name']) ?? _s(json['fullName']) ?? '';
      final phone = _s(json['phone']) ?? '';

      final categoryId = _i(json['categoryId']) ?? _i(json['category_id']) ?? 0;
      final cityId = _i(json['cityId']) ?? _i(json['city_id']) ?? 0;
      final areaId = _i(json['areaId']) ?? _i(json['area_id']);

      final description = _s(json['description']) ?? '';

      final budget = _d(json['budget']);

      var dateType = _s(json['serviceDateType']) ??
          _s(json['service_date_type']) ??
          'today';
      dateType = _normalizeDateType(dateType);

      // iso: جديد serviceDateIso أو قديم serviceDateValue
      final iso = (_s(json['serviceDateIso']) ??
              _s(json['serviceDateValue']) ??
              _s(json['service_date'])) ??
          '';
      if (iso.trim().isEmpty) return null;

      // time: جديد serviceTimeHour أو قديم hour24
      String? time = _s(json['serviceTimeHour']) ?? _s(json['service_time']);
      final oldHour24 = _i(json['hour24']);
      if ((time == null || time.trim().isEmpty) &&
          oldHour24 != null &&
          oldHour24 >= 0 &&
          oldHour24 <= 23) {
        final hh = oldHour24.toString().padLeft(2, '0');
        time = '$hh:00';
      }
      time ??= '00:00';

      final share =
          _b(json['sharePhoneWithProvider']) ?? _b(json['share_phone']) ?? true;

      final isGuest = _b(json['isGuest']) ?? true;

      // files: نخزن مسارات → نرجعهم File
      final filePaths = _listStr(json['files']) ?? const <String>[];
      final files = filePaths.map((p) => File(p)).toList();

      return ServiceRequestDraft(
        name: name,
        phone: phone,
        categoryId: categoryId,
        cityId: cityId,
        areaId: areaId,
        description: description,
        budget: budget,
        serviceDateIso: iso.trim(),
        serviceDateType: dateType,
        serviceTimeHour: time.trim(),
        sharePhoneWithProvider: share,
        isGuest: isGuest,
        files: files,
        otp: null,
      );
    } catch (_) {
      return null;
    }
  }

  // -------- helpers --------

  static String? _s(dynamic v) {
    final s = v?.toString();
    if (s == null) return null;
    final t = s.trim();
    return t.isEmpty ? null : t;
  }

  static int? _i(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static double? _d(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

  static bool? _b(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v.toString().trim().toLowerCase();
    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
    return null;
  }

  static List<String>? _listStr(dynamic v) {
    if (v == null) return null;
    if (v is List) return v.map((e) => e.toString()).toList();
    return null;
  }

  static String _normalizeDateType(String raw) {
    final t = raw.trim();
    if (t == 'dayAfter') return 'day_after';
    if (t == 'day_after') return 'day_after';
    if (t == 'tomorrow') return 'tomorrow';
    if (t == 'today') return 'today';
    if (t == 'other') return 'other';
    return 'today';
  }
}
