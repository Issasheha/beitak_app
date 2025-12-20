import 'dart:async';
import 'dart:io';

import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provider_documents_state.dart';

/// AsyncNotifier لأننا بناخد الداتا من الـ API
class ProviderDocumentsController
    extends AsyncNotifier<ProviderDocumentsState> {
  @override
  FutureOr<ProviderDocumentsState> build() async {
    return _loadFromApi();
  }

  /// تحميل حالة الوثائق من الـ profile
  Future<ProviderDocumentsState> _loadFromApi() async {
    final res = await ApiClient.dio.get(ApiConstants.authProfile);

    final data = res.data;
    final provider = (data['data'] ?? {})['provider'] ?? {};
    // لو الـ backend مختلف شوي، بس عدّل الوصول لهون.

    String? s(dynamic v) =>
        (v == null || (v is String && v.isEmpty)) ? null : v.toString();

    bool b(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) return v.toLowerCase() == 'true';
      return false;
    }

    final docs = <ProviderDocument>[
      ProviderDocument(
        kind: ProviderDocKind.idCard,
        title: 'بطاقة الهوية',
        fileName: s(provider['id_verified_image']),
        isVerified: b(provider['is_id_verified']),
        isRequired: true,
        isRecommended: false,
        isUploading: false,
      ),
      ProviderDocument(
        kind: ProviderDocKind.workLicense,
        title: 'رخصة العمل / الترخيص المهني',
        fileName: s(provider['vocational_license_image']),
        isVerified: b(provider['is_license_verified']),
        isRequired: true,
        isRecommended: false,
        isUploading: false,
      ),
      ProviderDocument(
        kind: ProviderDocKind.policeClearance,
        title: 'شهادة عدم المحكومية',
        fileName: s(provider['police_clearance_image']),
        isVerified: b(provider['is_police_clearance_verified']),
        isRequired: false,
        isRecommended: true,
        isUploading: false,
      ),
    ];

    return ProviderDocumentsState(docs: docs);
  }

  /// إعادة تحميل من السيرفر (لو بدك زر تحديث مستقبلاً)
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final newState = await _loadFromApi();
      state = AsyncData(newState);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// رفع / تحديث وثيقة معيّنة
  ///
  /// ترجع null لو كل شيء تمام، أو رسالة خطأ نعرضها في SnackBar.
  Future<String?> uploadDocument({
    required ProviderDocKind kind,
    required File file,
  }) async {
    final current = state.asData?.value;
    if (current == null) return 'لم يتم تحميل البيانات بعد';

    // حدّث حالة الكارد (isUploading = true)
    final docsLoading = current.docs
        .map((d) =>
            d.kind == kind ? d.copyWith(isUploading: true) : d)
        .toList();
    state = AsyncData(current.copyWith(docs: docsLoading));

    try {
      final fieldName = _fieldNameForKind(kind);

      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(
          file.path,
          filename: file.uri.pathSegments.isNotEmpty
              ? file.uri.pathSegments.last
              : 'document_$fieldName',
        ),
      });

      // نستخدم نفس endpoint تبع استكمال الملف (يدعم الملفات)
      final res = await ApiClient.dio.post(
        ApiConstants.providerCompleteProfile,
        data: formData,
      );

      final data = res.data;
      final provider = (data['data'] ?? {})['provider'] ?? {};

      String? s(dynamic v) =>
          (v == null || (v is String && v.isEmpty)) ? null : v.toString();

      bool b(dynamic v) {
        if (v is bool) return v;
        if (v is num) return v != 0;
        if (v is String) return v.toLowerCase() == 'true';
        return false;
      }

      // نبني docs جديدة بناءً على الرد بعد التحديث
      final updatedDocs = current.docs.map((d) {
        if (d.kind == ProviderDocKind.idCard) {
          return d.copyWith(
            fileName: s(provider['id_verified_image']),
            isVerified: b(provider['is_id_verified']),
            isUploading: false,
          );
        }
        if (d.kind == ProviderDocKind.workLicense) {
          return d.copyWith(
            fileName: s(provider['vocational_license_image']),
            isVerified: b(provider['is_license_verified']),
            isUploading: false,
          );
        }
        if (d.kind == ProviderDocKind.policeClearance) {
          return d.copyWith(
            fileName: s(provider['police_clearance_image']),
            isVerified: b(provider['is_police_clearance_verified']),
            isUploading: false,
          );
        }
        return d;
      }).toList();

      state = AsyncData(
        current.copyWith(docs: updatedDocs),
      );

      return null;
    } catch (e, st) {
      // رجّع حالة isUploading = false
      final rollbackDocs = current.docs
          .map((d) =>
              d.kind == kind ? d.copyWith(isUploading: false) : d)
          .toList();
      state = AsyncError(e, st);
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
