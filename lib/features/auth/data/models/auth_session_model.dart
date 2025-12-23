import '../../domain/entities/auth_session_entity.dart';
import 'user_model.dart';

class AuthSessionModel {
  final String? token; // نخزنه خام بدون Bearer
  final UserModel? user;
  final bool isGuest;
  final bool isNewUser;
  final DateTime? expiresAt;

  const AuthSessionModel({
    this.token,
    this.user,
    this.isGuest = false,
    this.isNewUser = false,
    this.expiresAt,
  });

  AuthSessionModel copyWith({
    String? token,
    UserModel? user,
    bool? isGuest,
    bool? isNewUser,
    DateTime? expiresAt,
  }) {
    return AuthSessionModel(
      token: token ?? this.token,
      user: user ?? this.user,
      isGuest: isGuest ?? this.isGuest,
      isNewUser: isNewUser ?? this.isNewUser,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  factory AuthSessionModel.guest() {
    return const AuthSessionModel(
      token: null,
      user: null,
      isGuest: true,
      isNewUser: false,
    );
  }

  // ===== helpers (robust) =====

  static String _normalizeToken(String raw) {
    var t = raw.trim();
    if (t.toLowerCase().startsWith('bearer ')) {
      t = t.substring(7).trim();
    }
    return t;
  }

  static String? _deepFindStringByKeys(dynamic node, Set<String> keys) {
    if (node is Map) {
      for (final k in node.keys) {
        final key = k.toString();
        final value = node[k];

        if (keys.contains(key)) {
          final s = (value ?? '').toString().trim();
          if (s.isNotEmpty) return s;
        }

        final found = _deepFindStringByKeys(value, keys);
        if (found != null && found.trim().isNotEmpty) return found;
      }
    } else if (node is List) {
      for (final item in node) {
        final found = _deepFindStringByKeys(item, keys);
        if (found != null && found.trim().isNotEmpty) return found;
      }
    }
    return null;
  }

  static Map<String, dynamic>? _deepFindUserMap(dynamic node) {
    bool looksLikeUser(Map m) {
      final hasId = m.containsKey('id');
      final hasFirst = m.containsKey('first_name') || m.containsKey('firstName');
      final hasLast = m.containsKey('last_name') || m.containsKey('lastName');
      return hasId && (hasFirst || hasLast);
    }

    if (node is Map) {
      final u = node['user'];
      if (u is Map && looksLikeUser(u)) return Map<String, dynamic>.from(u);

      for (final v in node.values) {
        if (v is Map && looksLikeUser(v)) return Map<String, dynamic>.from(v);
        final found = _deepFindUserMap(v);
        if (found != null) return found;
      }
    } else if (node is List) {
      for (final item in node) {
        final found = _deepFindUserMap(item);
        if (found != null) return found;
      }
    }
    return null;
  }

  static bool _deepFindBool(dynamic node, String key) {
    if (node is Map) {
      if (node.containsKey(key)) {
        final v = node[key];
        if (v is bool) return v;
        final s = v?.toString().toLowerCase().trim();
        if (s == 'true') return true;
        if (s == 'false') return false;
      }
      for (final v in node.values) {
        final r = _deepFindBool(v, key);
        if (r == true) return true;
      }
    } else if (node is List) {
      for (final item in node) {
        final r = _deepFindBool(item, key);
        if (r == true) return true;
      }
    }
    return false;
  }

  static DateTime? _deepFindDateTime(dynamic node, String key) {
    if (node is Map) {
      if (node.containsKey(key)) {
        final v = node[key];
        return v != null ? DateTime.tryParse(v.toString()) : null;
      }
      for (final v in node.values) {
        final d = _deepFindDateTime(v, key);
        if (d != null) return d;
      }
    } else if (node is List) {
      for (final item in node) {
        final d = _deepFindDateTime(item, key);
        if (d != null) return d;
      }
    }
    return null;
  }

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final rawToken = _deepFindStringByKeys(
      json,
      {'token', 'access_token', 'auth_token', 'jwt'},
    );
    final token = (rawToken == null) ? null : _normalizeToken(rawToken);

    final userMap = _deepFindUserMap(json);
    final user = userMap != null ? UserModel.fromJson(userMap) : null;

    final isNewUser = _deepFindBool(json, 'is_new_user');
    final expiresAt = _deepFindDateTime(json, 'expires_at');

    final isGuest = token == null || token.isEmpty;

    return AuthSessionModel(
      token: isGuest ? null : token,
      user: user,
      isGuest: isGuest,
      isNewUser: isNewUser,
      expiresAt: expiresAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user?.toJson(),
      'is_guest': isGuest,
      'is_new_user': isNewUser,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  AuthSessionEntity toEntity() {
    return AuthSessionEntity(
      token: token,
      user: user?.toEntity(),
      isGuest: isGuest,
      expiresAt: expiresAt,
    );
  }
}
