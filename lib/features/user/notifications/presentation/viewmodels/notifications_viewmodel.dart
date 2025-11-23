// lib/features/user/notifications/presentation/viewmodels/notifications_viewmodel.dart

import 'package:flutter/material.dart';

/// نموذج بسيط لعنصر إشعار واحد في الواجهة.
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String timeLabel;
  final IconData icon;
  final Color color;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.icon,
    required this.color,
    this.isRead = false,
  });

  NotificationItem copyWith({
    String? timeLabel,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      timeLabel: timeLabel ?? this.timeLabel,
      icon: icon,
      color: color,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// ViewModel لشاشة "الإشعارات".
///
/// حالياً:
/// - يستخدم بيانات وهمية (dummy).
/// - يدعم حذف الإشعار واعتباره مقروءًا.
class NotificationsViewModel {
  final List<NotificationItem> _items;

  NotificationsViewModel() : _items = _initialDummyNotifications();

  List<NotificationItem> get notifications => List.unmodifiable(_items);

  bool get hasNotifications => _items.isNotEmpty;

  void removeAt(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
  }

  void markAsRead(int index) {
    if (index < 0 || index >= _items.length) return;
    final current = _items[index];
    _items[index] = current.copyWith(isRead: true);
  }

  // ================= Helpers =================

  static List<NotificationItem> _initialDummyNotifications() {
    return [
      const NotificationItem(
        id: 'accepted_request',
        title: 'تم قبول طلبك!',
        body: 'تم قبول طلبك لخدمة تنظيف منزلي من قبل أحمد محمد.',
        timeLabel: 'منذ 5 دقائق',
        icon: Icons.check_circle,
        color: Colors.green,
      ),
      const NotificationItem(
        id: 'upcoming_reminder',
        title: 'تذكير بموعد قريب',
        body: 'لديك موعد تنظيف منزلي غدًا الساعة 9:00 ص في عبدون.',
        timeLabel: 'منذ ساعة واحدة',
        icon: Icons.access_time,
        color: Colors.orange,
      ),
      const NotificationItem(
        id: 'special_offer',
        title: 'عرض خاص لك!',
        body: 'احصل على خصم 20% على أي خدمة تنظيف خلال هذا الأسبوع.',
        timeLabel: 'منذ 3 ساعات',
        icon: Icons.local_offer,
        color: Colors.blue,
      ),
    ];
  }
}
