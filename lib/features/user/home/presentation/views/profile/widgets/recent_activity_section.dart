import 'package:beitak_app/features/user/home/domain/entities/recent_activity_entity.dart';
import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

class RecentActivitySection extends StatelessWidget {
  final List<RecentActivityEntity> items;
  const RecentActivitySection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final deduped = _dedup(items).take(10).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'آخر الأنشطة',
            style: TextStyle(
              fontSize: SizeConfig.ts(16),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: SizeConfig.h(10)),
          if (deduped.isEmpty)
            Container(
              width: double.infinity,
              padding: SizeConfig.padding(all: 14),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
              ),
              child: Text(
                'لا يوجد نشاطات بعد.',
                style: TextStyle(
                  fontSize: SizeConfig.ts(13),
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
                child: Column(
                  children: [
                    for (int i = 0; i < deduped.length; i++)
                      _ActivityRow(
                        a: deduped[i],
                        isLast: i == deduped.length - 1,
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<RecentActivityEntity> _dedup(List<RecentActivityEntity> input) {
    final seen = <String>{};
    final out = <RecentActivityEntity>[];

    for (final a in input) {
      // Dedup على النوع + الوقت (دقيقة) + العنوان
      final minute = DateTime(a.time.year, a.time.month, a.time.day, a.time.hour, a.time.minute);
      final key = '${a.type.name}|${minute.toIso8601String()}|${a.title}';
      if (seen.add(key)) out.add(a);
    }

    out.sort((a, b) => b.time.compareTo(a.time));
    return out;
  }
}

class _ActivityRow extends StatelessWidget {
  final RecentActivityEntity a;
  final bool isLast;

  const _ActivityRow({required this.a, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(a.type);

    final title = (a.title.trim().isNotEmpty) ? a.title.trim() : _fallbackTitle(a.type);
    final subtitle = (a.subtitle.trim().isNotEmpty) ? a.subtitle.trim() : _fallbackSubtitle(a.type);

    return Container(
      decoration: BoxDecoration(
        color: style.bg,
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: Colors.grey.withValues(alpha: 0.18)),
        ),
      ),
      padding: SizeConfig.padding(horizontal: 14, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(style.icon, color: style.iconColor),
          SizedBox(width: SizeConfig.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: SizeConfig.ts(14),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: SizeConfig.h(2)),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: SizeConfig.ts(12),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: SizeConfig.h(8)),
                Text(
                  _timeAgoAr(a.time),
                  style: TextStyle(
                    fontSize: SizeConfig.ts(11),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fallbackTitle(RecentActivityType type) {
    switch (type) {
      case RecentActivityType.profileUpdated:
        return 'تحديث الملف الشخصي';
      case RecentActivityType.serviceCompleted:
        return 'آخر طلب';
      case RecentActivityType.cancelledRequest:
        return 'تم إلغاء طلب';
      case RecentActivityType.reviewSubmitted:
        return 'تم إرسال تقييم';
    }
  }

  String _fallbackSubtitle(RecentActivityType type) {
    switch (type) {
      case RecentActivityType.profileUpdated:
        return 'تم بنجاح';
      case RecentActivityType.serviceCompleted:
        return 'اكتملت الخدمة';
      case RecentActivityType.cancelledRequest:
        return 'تم الإلغاء';
      case RecentActivityType.reviewSubmitted:
        return 'تم النشر';
    }
  }

  String _timeAgoAr(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inSeconds < 60) return 'الآن';
    if (d.inMinutes < 60) return 'منذ ${d.inMinutes} دقيقة';
    if (d.inHours < 24) return 'منذ ${d.inHours} ساعة';

    final days = d.inDays;
    if (days == 1) return 'منذ يوم';
    if (days == 2) return 'منذ يومين';
    if (days >= 3 && days <= 10) return 'منذ $days أيام';
    return 'منذ $days يوم';
  }

  _ActivityStyle _styleFor(RecentActivityType type) {
    switch (type) {
      case RecentActivityType.profileUpdated:
        return _ActivityStyle(
          icon: Icons.person_outline,
          iconColor: AppColors.textPrimary,
          bg: Colors.grey.withValues(alpha: 0.08),
        );
      case RecentActivityType.serviceCompleted:
        return _ActivityStyle(
          icon: Icons.check_circle_outline,
          iconColor: AppColors.lightGreen,
          bg: AppColors.lightGreen.withValues(alpha: 0.12),
        );
      case RecentActivityType.reviewSubmitted:
        return _ActivityStyle(
          icon: Icons.star_border,
          iconColor: Colors.amber.shade700,
          bg: Colors.amber.withValues(alpha: 0.18),
        );
      case RecentActivityType.cancelledRequest:
        return _ActivityStyle(
          icon: Icons.close_rounded,
          iconColor: Colors.redAccent,
          bg: Colors.red.withValues(alpha: 0.10),
        );
    }
  }
}

class _ActivityStyle {
  final IconData icon;
  final Color iconColor;
  final Color bg;

  _ActivityStyle({
    required this.icon,
    required this.iconColor,
    required this.bg,
  });
}
