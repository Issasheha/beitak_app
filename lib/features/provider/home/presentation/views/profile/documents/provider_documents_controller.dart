import 'dart:async';
import 'dart:io';

import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provider_documents_state.dart';

class ProviderDocumentsController extends AsyncNotifier<ProviderDocumentsState> {
  @override
  FutureOr<ProviderDocumentsState> build() async {
    return _loadFromApi();
  }

  // ---------------- helpers ----------------

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

  bool _b(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) return v.toLowerCase() == 'true';
    return false;
  }

  /// ✅ NEW: يدعم String أو List<String>
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

  // ---------------- load ----------------

  Future<ProviderDocumentsState> _loadFromApi() async {
    final providerId = await _resolveProviderId();

    // ✅ GET /api/providers/:id
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
        isRequired: false,
        isRecommended: true,
        isUploading: false,
      ),
    ];

    return ProviderDocumentsState(docs: docs);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final newState = await _loadFromApi();
      state = AsyncData(newState);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // ---------------- upload (multi files) ----------------

  Future<String?> uploadDocument({
    required ProviderDocKind kind,
    required List<File> files,
  }) async {
    final current = state.asData?.value;
    if (current == null) return 'لم يتم تحميل البيانات بعد';

    final cleanFiles = files.where((f) => f.existsSync()).toList();
    if (cleanFiles.isEmpty) return 'لم يتم اختيار أي ملف';

    // loading state
    final docsLoading = current.docs
        .map((d) => d.kind == kind ? d.copyWith(isUploading: true) : d)
        .toList();
    state = AsyncData(current.copyWith(docs: docsLoading));

    try {
      final fieldName = _fieldNameForKind(kind);

      final formData = FormData();

      // ✅ أهم نقطة: نضيف نفس المفتاح أكثر من مرة (multi upload لنفس الحقل)
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

      // نفس endpoint اللي يدعم الملفات
      final res = await ApiClient.dio.post(
        ApiConstants.providerCompleteProfile,
        data: formData,
      );

      final data = res.data ?? {};
      final provider = (data['data'] ?? {})['provider'] ?? {};

      // تحديث الدوكز من الرد
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
    } on DioException catch (_) {
      // rollback loading flag
      final rollbackDocs = current.docs
          .map((d) => d.kind == kind ? d.copyWith(isUploading: false) : d)
          .toList();
      state = AsyncData(current.copyWith(docs: rollbackDocs));
      return 'فشل رفع الوثيقة، حاول مرة أخرى';
    } catch (_) {
      final rollbackDocs = current.docs
          .map((d) => d.kind == kind ? d.copyWith(isUploading: false) : d)
          .toList();
      state = AsyncData(current.copyWith(docs: rollbackDocs));
      return 'فشل رفع الوثيقة، حاول مرة أخرى';
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
}
