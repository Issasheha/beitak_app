import 'package:flutter/foundation.dart';

/// أنواع الوثائق التي ندعمها
enum ProviderDocKind {
  idCard,          // الهوية الشخصية
  workLicense,     // الرخصة المهنية / السجل التجاري
  policeClearance, // شهادة عدم المحكومية
}

@immutable
class ProviderDocument {
  final ProviderDocKind kind;
  final String title;          // مثل: "بطاقة الهوية"
  final String? fileName;      // اسم الملف (إن وجد)
  final bool isVerified;       // موثّقة من الأدمن؟
  final bool isRequired;       // مطلوبة أم اختيارية؟
  final bool isRecommended;    // (مستحسنة) إن حبيت تستخدمها لاحقاً
  final bool isUploading;      // حالة رفع حالية

  const ProviderDocument({
    required this.kind,
    required this.title,
    required this.fileName,
    required this.isVerified,
    required this.isRequired,
    required this.isRecommended,
    required this.isUploading,
  });

  ProviderDocument copyWith({
    String? fileName,
    bool? isVerified,
    bool? isRequired,
    bool? isRecommended,
    bool? isUploading,
  }) {
    return ProviderDocument(
      kind: kind,
      title: title,
      fileName: fileName ?? this.fileName,
      isVerified: isVerified ?? this.isVerified,
      isRequired: isRequired ?? this.isRequired,
      isRecommended: isRecommended ?? this.isRecommended,
      isUploading: isUploading ?? this.isUploading,
    );
  }
}

@immutable
class ProviderDocumentsState {
  final List<ProviderDocument> docs;

  const ProviderDocumentsState({
    required this.docs,
  });

  factory ProviderDocumentsState.initial() {
    return const ProviderDocumentsState(docs: []);
  }

  ProviderDocumentsState copyWith({
    List<ProviderDocument>? docs,
  }) {
    return ProviderDocumentsState(
      docs: docs ?? this.docs,
    );
  }
}
