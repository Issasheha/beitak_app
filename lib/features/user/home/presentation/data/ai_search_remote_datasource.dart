// lib/features/user/home/presentation/data/ai_search_remote_datasource.dart

import 'dart:io';

import 'package:beitak_app/core/network/ai_api_client.dart';
import 'package:dio/dio.dart';

class AiSearchResult {
  final String service;         // "صيانة عامة"
  final String categoryKey;     // "home_maintenance"
  final double confidence;      // 0.92
  final String method;          // "Enhanced ML"
  final String? recognizedText; // للصوت

  const AiSearchResult({
    required this.service,
    required this.categoryKey,
    required this.confidence,
    required this.method,
    this.recognizedText,
  });

  factory AiSearchResult.fromJson(Map<String, dynamic> json) {
    final fp = (json['final_prediction'] is Map)
        ? Map<String, dynamic>.from(json['final_prediction'] as Map)
        : <String, dynamic>{};

    final service =
        (fp['service'] ?? json['detected_service'] ?? 'غير محدد').toString();

    final categoryKeyRaw = json['category_key'];
    final categoryKey = (categoryKeyRaw == null || categoryKeyRaw.toString().trim().isEmpty)
        ? 'home_maintenance' // ✅ fallback آمن
        : categoryKeyRaw.toString().trim();

    final confidence = _toDouble(fp['confidence'] ?? json['confidence']);

    final method = (fp['method'] ??
            json['method_used'] ??
            json['method'] ??
            'Enhanced ML')
        .toString();

    return AiSearchResult(
      service: service,
      categoryKey: categoryKey,
      confidence: confidence,
      method: method,
      recognizedText: json['recognized_text']?.toString(),
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

class AiSearchRemoteDataSource {
  AiSearchRemoteDataSource({
    Dio? dio,
  }) : _dio = dio ?? AiApiClient.dio;

  final Dio _dio;

  /// ✅ نص: POST /api/enhanced-predict
  Future<AiSearchResult> predictText({
    required String query,
  }) async {
    final q = query.trim();
    if (q.isEmpty) throw Exception('query_empty');

    final res = await _dio.post(
      '/api/enhanced-predict',
      data: {'query': q},
      options: Options(
        headers: const {
          'Content-Type': 'application/json',
        },
      ),
    );

    final data = res.data;
    if (data is! Map) throw Exception('invalid_ai_response');
    final map = Map<String, dynamic>.from(data);

    final status = (map['status'] ?? 'success').toString();
    if (status != 'success') {
      throw Exception((map['message'] ?? 'ai_predict_failed').toString());
    }

    return AiSearchResult.fromJson(map);
  }

  /// ✅ صوت: POST /api/enhanced-voice-predict (multipart)
  /// لازم نبعث ملف صوت تحت اسم audio_file
  Future<AiSearchResult> predictVoice({
    required File audioFile,
  }) async {
    if (!await audioFile.exists()) throw Exception('audio_file_not_found');

    final form = FormData.fromMap({
      'audio_file': await MultipartFile.fromFile(
        audioFile.path,
        filename: audioFile.path.split(Platform.pathSeparator).last,
      ),
    });

    final res = await _dio.post(
      '/api/enhanced-voice-predict',
      data: form,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    final data = res.data;
    if (data is! Map) throw Exception('invalid_ai_response');
    final map = Map<String, dynamic>.from(data);

    final status = (map['status'] ?? 'success').toString();
    if (status != 'success') {
      throw Exception((map['message'] ?? 'ai_voice_failed').toString());
    }

    return AiSearchResult.fromJson(map);
  }
}
