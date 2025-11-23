import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/provider_profile_section_card.dart';
import 'package:flutter/material.dart';

class ProviderNotificationPrefsSection extends StatelessWidget {
  final bool notifyNewBookings;
  final bool notifyBookingUpdates;
  final bool notifyMessages;
  final bool notifyReviews;

  final ValueChanged<bool> onNewBookingsChanged;
  final ValueChanged<bool> onBookingUpdatesChanged;
  final ValueChanged<bool> onMessagesChanged;
  final ValueChanged<bool> onReviewsChanged;

  const ProviderNotificationPrefsSection({
    super.key,
    required this.notifyNewBookings,
    required this.notifyBookingUpdates,
    required this.notifyMessages,
    required this.notifyReviews,
    required this.onNewBookingsChanged,
    required this.onBookingUpdatesChanged,
    required this.onMessagesChanged,
    required this.onReviewsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderProfileSectionCard(
      title: 'تفضيلات الإشعارات',
      child: Column(
        children: [
          _NotificationTile(
            title: 'الطلبات الجديدة',
            subtitle: 'عند استلام طلب حجز جديد',
            value: notifyNewBookings,
            onChanged: onNewBookingsChanged,
          ),
          _divider(),
          _NotificationTile(
            title: 'تحديثات الطلبات',
            subtitle: 'عند تعديل أو تغيير حالة حجز',
            value: notifyBookingUpdates,
            onChanged: onBookingUpdatesChanged,
          ),
          _divider(),
          _NotificationTile(
            title: 'الرسائل',
            subtitle: 'عند استلام رسالة من عميل',
            value: notifyMessages,
            onChanged: onMessagesChanged,
          ),
          _divider(),
          _NotificationTile(
            title: 'التقييمات',
            subtitle: 'عند حصولك على تقييم جديد',
            value: notifyReviews,
            onChanged: onReviewsChanged,
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: SizeConfig.h(10)),
      child: Divider(
        height: 1,
        color: AppColors.borderLight.withValues(alpha: 0.5),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          _iconForNotification(title),
          color: AppColors.lightGreen,
          size: SizeConfig.ts(20),
        ),
        SizeConfig.hSpace(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: SizeConfig.ts(14),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizeConfig.v(2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: SizeConfig.ts(12),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: AppColors.lightGreen,
        ),
      ],
    );
  }

  IconData _iconForNotification(String title) {
    if (title.contains('الطلبات') && !title.contains('تحديثات')) {
      return Icons.notifications_active_outlined;
    }
    if (title.contains('تحديثات')) {
      return Icons.update_outlined;
    }
    if (title.contains('الرسائل')) {
      return Icons.mail_outline;
    }
    if (title.contains('التقييمات')) {
      return Icons.star_border_rounded;
    }
    return Icons.notifications_outlined;
  }
}
