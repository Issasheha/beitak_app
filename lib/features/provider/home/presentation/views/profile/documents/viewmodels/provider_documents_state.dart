import 'package:flutter/foundation.dart';

/// أنواع الوثائق التي ندعمها
enum ProviderDocKind {
  idCard, // الهوية الشخصية
  workLicense, // الرخصة المهنية / السجل التجاري
  policeClearance, // شهادة عدم المحكومية
}

@immutable
class ProviderDocument {
  final ProviderDocKind kind;
  final String title;

  /// ✅ NEW: أكثر من ملف لنفس الوثيقة (وجه/ظهر مثلاً)
  final List<String> fileNames;

  final bool isVerified;
  final bool isRequired;
  final bool isRecommended;
  final bool isUploading;

  const ProviderDocument({
    required this.kind,
    required this.title,
    required this.fileNames,
    required this.isVerified,
    required this.isRequired,
    required this.isRecommended,
    required this.isUploading,
  });

  /// للحفاظ على توافق الكود القديم (لو بدك آخر ملف فقط)
  String? get fileName => fileNames.isEmpty ? null : fileNames.last;

  int get filesCount => fileNames.length;

  ProviderDocument copyWith({
    List<String>? fileNames,
    bool? isVerified,
    bool? isRequired,
    bool? isRecommended,
    bool? isUploading,
  }) {
    return ProviderDocument(
      kind: kind,
      title: title,
      fileNames: fileNames ?? this.fileNames,
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

  const ProviderDocumentsState({required this.docs});

  factory ProviderDocumentsState.initial() {
    return const ProviderDocumentsState(docs: []);
  }

  ProviderDocumentsState copyWith({List<ProviderDocument>? docs}) {
    return ProviderDocumentsState(docs: docs ?? this.docs);
  }
}
