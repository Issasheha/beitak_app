import '../../domain/entities/recent_activity_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;
  const ProfileRepositoryImpl(this.remote);

  @override
  Future<UserProfileEntity> getProfile() async {
    final m = await remote.getProfile();
    return m;
  }

  @override
  Future<UserProfileEntity> updateProfile(UpdateProfileParams params) async {
    final m = await remote.updateProfile(params.toJson());
    return m;
  }

  @override
  Future<UserProfileEntity> uploadProfileImage(String filePath) async {
    final m = await remote.uploadProfileImage(filePath);
    return m;
  }

  @override
  Future<void> changePassword(ChangePasswordParams params) async {
    await remote.changePassword(params.toJson());
  }

  @override
  Future<void> deleteAccount() async {
    await remote.deleteAccount();
  }

  DateTime _parseTime(Map<String, dynamic> json) {
    final s = json['createdAt'] ?? json['created_at'];
    if (s is String) return DateTime.tryParse(s) ?? DateTime.now();
    return DateTime.now();
  }

  RecentActivityEntity _mapActivity(Map<String, dynamic> a) {
    final typeRaw = (a['type']?.toString() ?? '').trim();
    final type = typeRaw.toLowerCase();

    final status = (a['status']?.toString() ?? '').toLowerCase();
    final description = (a['description']?.toString() ?? '').trim();

    if (type.contains('profile')) {
      return RecentActivityEntity(
        type: RecentActivityType.profileUpdated,
        title: 'تحديث الملف الشخصي',
        subtitle: description.isNotEmpty ? _arabizeDescription(description) : 'تم بنجاح',
        time: _parseTime(a),
      );
    }

    if (type.contains('cancel') || status.contains('cancel')) {
      return RecentActivityEntity(
        type: RecentActivityType.cancelledRequest,
        title: 'تم إلغاء طلب',
        subtitle: description.isNotEmpty ? _arabizeDescription(description) : 'تم الإلغاء',
        time: _parseTime(a),
      );
    }

    if (type.contains('review')) {
      return RecentActivityEntity(
        type: RecentActivityType.reviewSubmitted,
        title: 'تم إرسال تقييم',
        subtitle: description.isNotEmpty ? _arabizeDescription(description) : 'تم النشر',
        time: _parseTime(a),
      );
    }

    return RecentActivityEntity(
      type: RecentActivityType.serviceCompleted,
      title: 'آخر طلب',
      subtitle: _arabizeStatusOrDesc(status, description),
      time: _parseTime(a),
    );
  }

  String _arabizeDescription(String d) {
    final t = d.toLowerCase();
    if (t.contains('completed')) return 'تم بنجاح';
    if (t.contains('published')) return 'تم النشر';
    return d;
  }

  String _arabizeStatusOrDesc(String status, String desc) {
    if (status.contains('complete')) return 'تم إنجاز الخدمة';
    if (status.contains('pending')) return 'قيد المعالجة';
    if (status.contains('in_progress')) return 'قيد التنفيذ';
    if (desc.isNotEmpty) return _arabizeDescription(desc);
    return 'تم';
  }

  List<RecentActivityEntity> _dedupe(List<RecentActivityEntity> items) {
    final seen = <String>{};
    final out = <RecentActivityEntity>[];

    for (final x in items) {
      // Dedup على النوع + الوقت (دقيقة) + العنوان
      final minute = DateTime(x.time.year, x.time.month, x.time.day, x.time.hour, x.time.minute);
      final key = '${x.type.name}|${minute.toIso8601String()}|${x.title}';
      if (seen.add(key)) out.add(x);
    }

    return out;
  }

  @override
  Future<List<RecentActivityEntity>> getRecentActivity({int limit = 10}) async {
    final raw = await remote.getRecentActivityRaw(limit: limit);

    final mapped = raw.map(_mapActivity).toList();
    final cleaned = _dedupe(mapped)..sort((a, b) => b.time.compareTo(a.time));

    if (cleaned.length > limit) return cleaned.take(limit).toList();
    return cleaned;
  }
}
