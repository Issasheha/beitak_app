// lib/features/provider/home/presentation/views/profile/documents/viewmodels/provider_documents_controller.dart

import 'dart:async';
import 'dart:io';

import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provider_documents_state.dart';

class ProviderDocumentsController extends AsyncNotifier<ProviderDocumentsState> {
  static const int _maxBytesPerFile = 5 * 1024 * 1024; // 5MB

  static const Set<String> _allowedExt = {
    'jpg',
    'jpeg',
    'png',
    'pdf',
    'webp',
  };

  int? _cachedProviderId;

  @override
  FutureOr<ProviderDocumentsState> build() async {
    return _loadFromApi();
  }

  // ---------------- helpers ----------------

  int _maxFilesForKind(ProviderDocKind kind) {
    // QA: الهوية فقط ملفين، غيرها ملف واحد
    return kind == ProviderDocKind.idCard ? 2 : 1;
  }

  Future<int> _resolveProviderId() async {
    if (_cachedProviderId != null) return _cachedProviderId!;

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

    _cachedProviderId = providerId;
    return providerId;
  }

  bool _b(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) return v.toLowerCase() == 'true';
    return false;
  }

  /// ✅ يدعم String أو List<String>
  List<String> _files(dynamic v) {
    if (v == null) return <String>[];
    if (v is List) {
      return v
          .map((e) => (e ?? '').toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    final s = v.toString().trim();
    if (s.isEmpty) return <String>[];
    return <String>[s];
  }

  String _extOfPath(String path) {
    final p = path.toLowerCase();
    final i = p.lastIndexOf('.');
    if (i == -1 || i == p.length - 1) return '';
    return p.substring(i + 1);
  }

  String _docTitle(ProviderDocKind kind) {
    switch (kind) {
      case ProviderDocKind.idCard:
        return 'بطاقة الهوية';
      case ProviderDocKind.workLicense:
        return 'رخصة العمل / الترخيص المهني';
      case ProviderDocKind.policeClearance:
        return 'شهادة عدم المحكومية';
    }
  }

  // ---------------- load ----------------

  Future<ProviderDocumentsState> _loadFromApi() async {
    final providerId = await _resolveProviderId();

    final res = await ApiClient.dio.get(ApiConstants.providerById(providerId));
    final data = res.data ?? {};
    final provider = (data['data'] ?? {})['provider'] ?? {};

    final docs = <ProviderDocument>[
      ProviderDocument(
        kind: ProviderDocKind.idCard,
        title: 'بطاقة الهوية',
        fileNames: _files(provider['id_verified_image']),
        isVerified: _b(provider['is_id_verified']),
        isRequired: true,
        isRecommended: false,
        isUploading: false,
      ),
      ProviderDocument(
        kind: ProviderDocKind.workLicense,
        title: 'رخصة العمل / الترخيص المهني',
        fileNames: _files(provider['vocational_license_image']),
        isVerified: _b(provider['is_license_verified']),
        isRequired: true,
        isRecommended: false,
        isUploading: false,
      ),
      ProviderDocument(
        kind: ProviderDocKind.policeClearance,
        title: 'شهادة عدم المحكومية',
        fileNames: _files(provider['police_clearance_image']),
        isVerified: _b(provider['is_police_clearance_verified']),
        isRequired: true,

        // ✅ IMPORTANT: كل الوثائق مطلوبة (لا يوجد اختياري/مستحسن)
        isRecommended: false,

        isUploading: false,
      ),
    ];

    return ProviderDocumentsState(docs: docs);
  }

  Future<void> refresh() async {
    final prev = state.asData?.value;
    if (prev == null) {
      state = const AsyncLoading();
    }

    try {
      final newState = await _loadFromApi();
      state = AsyncData(newState);
    } catch (e, st) {
      if (prev != null) {
        state = AsyncData(prev);
      } else {
        state = AsyncError(e, st);
      }
    }
  }

  // ---------------- upload ----------------

  Future<String?> uploadDocument({
    required ProviderDocKind kind,
    required List<File> files,
  }) async {
    final current = state.asData?.value;
    if (current == null) return 'لم يتم تحميل البيانات بعد';

    final doc = current.docs.firstWhere((d) => d.kind == kind);

    final maxFiles = _maxFilesForKind(kind);

    // ✅ avoid sync IO
    final cleanFiles = <File>[];
    for (final f in files) {
      try {
        if (await f.exists()) cleanFiles.add(f);
      } catch (_) {}
    }

    if (cleanFiles.isEmpty) return 'لم يتم اختيار أي ملف';

    if (cleanFiles.length > maxFiles) {
      return kind == ProviderDocKind.idCard
          ? 'الهوية فقط: يمكنك رفع ملفين كحد أقصى (أمامي + خلفي) أو PDF.'
          : 'يمكنك رفع ملف واحد فقط لهذه الوثيقة (صورة أو PDF).';
    }

    final existingCount = doc.fileNames.length;
    if (existingCount + cleanFiles.length > maxFiles) {
      final remaining = (maxFiles - existingCount).clamp(0, maxFiles);

      if (remaining == 0) {
        return kind == ProviderDocKind.idCard
            ? 'لديك بالفعل ملفين للهوية. (حالياً لا يوجد استبدال/حذف من التطبيق)'
            : 'لديك بالفعل ملف لهذه الوثيقة. (حالياً لا يوجد استبدال/حذف من التطبيق)';
      }

      return kind == ProviderDocKind.idCard
          ? 'يمكنك رفع $remaining ملف/ملفات إضافية فقط للهوية'
          : 'يمكنك رفع ملف إضافي واحد فقط لهذه الوثيقة';
    }

    // ✅ type + size validations (async)
    for (final f in cleanFiles) {
      final ext = _extOfPath(f.path);
      if (!_allowedExt.contains(ext)) {
        return 'نوع الملف غير مدعوم. الصيغ المدعومة: PDF, JPG, PNG, WEBP';
      }
      try {
        final bytes = await f.length();
        if (bytes > _maxBytesPerFile) {
          return 'حجم الملف كبير. الحد الأقصى 5MB لكل ملف';
        }
      } catch (_) {
        return 'تعذر قراءة الملف، حاول اختيار ملف آخر';
      }
    }

    // loading state
    final docsLoading = current.docs
        .map((d) => d.kind == kind ? d.copyWith(isUploading: true) : d)
        .toList();
    state = AsyncData(current.copyWith(docs: docsLoading));

    try {
      final fieldName = _fieldNameForKind(kind);

      final formData = FormData();
      for (final f in cleanFiles) {
        formData.files.add(
          MapEntry(
            fieldName,
            await MultipartFile.fromFile(
              f.path,
              filename: f.uri.pathSegments.isNotEmpty
                  ? f.uri.pathSegments.last
                  : 'document_$fieldName',
            ),
          ),
        );
      }

      final res = await ApiClient.dio.post(
        ApiConstants.providerCompleteProfile,
        data: formData,
      );

      final data = res.data ?? {};
      final provider = (data['data'] ?? {})['provider'] ?? {};

      final updatedDocs = current.docs.map((d) {
        if (d.kind == ProviderDocKind.idCard) {
          return d.copyWith(
            fileNames: _files(provider['id_verified_image']),
            isVerified: _b(provider['is_id_verified']),
            isUploading: false,
          );
        }
        if (d.kind == ProviderDocKind.workLicense) {
          return d.copyWith(
            fileNames: _files(provider['vocational_license_image']),
            isVerified: _b(provider['is_license_verified']),
            isUploading: false,
          );
        }
        if (d.kind == ProviderDocKind.policeClearance) {
          return d.copyWith(
            fileNames: _files(provider['police_clearance_image']),
            isVerified: _b(provider['is_police_clearance_verified']),
            isUploading: false,
          );
        }
        return d;
      }).toList();

      state = AsyncData(current.copyWith(docs: updatedDocs));
      return null;
    } on DioException catch (e) {
      final rollbackDocs = current.docs
          .map((d) => d.kind == kind ? d.copyWith(isUploading: false) : d)
          .toList();
      state = AsyncData(current.copyWith(docs: rollbackDocs));
      return _friendlyDio(e, fallbackDoc: _docTitle(kind));
    } catch (_) {
      final rollbackDocs = current.docs
          .map((d) => d.kind == kind ? d.copyWith(isUploading: false) : d)
          .toList();
      state = AsyncData(current.copyWith(docs: rollbackDocs));
      return 'فشل رفع ${_docTitle(kind)}، حاول مرة أخرى';
    }
  }

  String _fieldNameForKind(ProviderDocKind kind) {
    switch (kind) {
      case ProviderDocKind.idCard:
        return 'id_verified_image';
      case ProviderDocKind.workLicense:
        return 'vocational_license_image';
      case ProviderDocKind.policeClearance:
        return 'police_clearance_image';
    }
  }

  String _friendlyDio(DioException e, {String? fallbackDoc}) {
    final code = e.response?.statusCode;
    final data = e.response?.data;

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
    if (data is Map) {
      msg = (data['message'] ?? data['error'] ?? '').toString().trim();
    } else if (data is String) {
      msg = data.trim();
    }

    if (code == 400) {
      return msg.isNotEmpty ? msg : 'بيانات غير صحيحة';
    }
    if (code == 401) return 'انتهت الجلسة، أعد تسجيل الدخول';
    if (code == 403) return 'ليس لديك صلاحية';
    if (code == 404) return 'المسار غير موجود على الخادم';
    if (msg.isNotEmpty) return msg;

    return fallbackDoc == null
        ? 'خطأ بالشبكة، حاول مرة أخرى'
        : 'تعذر رفع $fallbackDoc حالياً، حاول مرة أخرى';
  }
}
