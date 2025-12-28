// lib/features/user/home/presentation/providers/ai_search_providers.dart

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beitak_app/features/user/home/presentation/data/ai_search_remote_datasource.dart';

/// ✅ Remote DS provider
final aiSearchRemoteDataSourceProvider = Provider<AiSearchRemoteDataSource>((ref) {
  return AiSearchRemoteDataSource();
});

/// ✅ Controller provider
final aiSearchControllerProvider = Provider.autoDispose<AiSearchController>((ref) {
  final ds = ref.read(aiSearchRemoteDataSourceProvider);
  return AiSearchController(ds);
});

class AiSearchController {
  AiSearchController(this._ds);

  final AiSearchRemoteDataSource _ds;

  /// ✅ إذا الثقة أقل من هيك → نعتبره غير موثوق ونرجع للبحث العادي
  static const double confidenceThreshold = 0.55;

  Future<AiSearchResult> predictText(String query) {
    return _ds.predictText(query: query);
  }

  Future<AiSearchResult> predictVoice(File audioFile) {
    return _ds.predictVoice(audioFile: audioFile);
  }

  bool shouldUseAiResult(AiSearchResult r) {
    final keyOk = r.categoryKey.trim().isNotEmpty;
    final serviceOk = r.service.trim().isNotEmpty && r.service.trim() != 'غير محدد';
    final confOk = r.confidence >= confidenceThreshold;

    return keyOk && serviceOk && confOk;
  }
}
