// lib/features/user/home/presentation/views/request_service/utils/request_service_draft_cache.dart

import 'dart:convert';

import 'package:beitak_app/features/user/home/presentation/views/request_service/viewmodels/request_service_draft.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestServiceDraftCache {
  static const String _key = 'draft_request_service';

  static Future<void> save(ServiceRequestDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(draft.toJson()));
  }

  static Future<ServiceRequestDraft?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);

      if (decoded is Map<String, dynamic>) {
        return ServiceRequestDraft.fromJson(decoded);
      }
      if (decoded is Map) {
        return ServiceRequestDraft.fromJson(
          decoded.map((k, v) => MapEntry(k.toString(), v)),
        );
      }
      return null;
    } catch (_) {
      await clear();
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
