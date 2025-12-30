import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';

import 'status_ui.dart';

class ServiceStatusMapper {
  ServiceStatusMapper._();

  static StatusUi ui(String status) {
    final s = status.trim();

    final isCancelled = s == 'cancelled' || s == 'refunded';
    final isCompleted = s == 'completed';
    final isIncomplete = s == 'incomplete';
    final isPending = s == 'pending_provider_accept' || s == 'pending';

    final isUpcoming = const {
      'confirmed',
      'provider_on_way',
      'provider_arrived',
      'in_progress',
    }.contains(s);

    if (isCancelled) {
      return StatusUi(
        label: 'ملغاة',
        color: Colors.red.shade700,
        bg: Colors.red.withValues(alpha: 0.10),
        border: Colors.red.withValues(alpha: 0.35),
        footerText: 'تم إلغاء هذا الحجز ولن يتم تنفيذه.',
      );
    }
    if (isCompleted) {
      return StatusUi(
        label: 'مكتمل',
        color: Colors.blue.shade700,
        bg: Colors.blue.withValues(alpha: 0.10),
        border: Colors.blue.withValues(alpha: 0.35),
        footerText: 'تم تنفيذ الخدمة بنجاح.',
      );
    }
    if (isPending) {
      return StatusUi(
        label: 'قيد الانتظار',
        color: Colors.orange.shade800,
        bg: Colors.orange.withValues(alpha: 0.10),
        border: Colors.orange.withValues(alpha: 0.35),
        footerText: 'بانتظار موافقة مزود الخدمة على طلبك.',
      );
    }
    if (isUpcoming) {
      return StatusUi(
        label: 'قادمة',
        color: AppColors.lightGreen,
        bg: AppColors.lightGreen.withValues(alpha: 0.12),
        border: AppColors.lightGreen.withValues(alpha: 0.35),
        footerText: 'تمت الموافقة على طلبك وسيتم تنفيذ الخدمة حسب الموعد.',
      );
    }
    if (isIncomplete) {
      return StatusUi(
        label: 'غير مكتملة',
        color: Colors.grey.shade700,
        bg: Colors.grey.withValues(alpha: 0.10),
        border: Colors.grey.withValues(alpha: 0.35),
        footerText:
            'لم يتم تنفيذ الخدمة ضمن الوقت المحدد وتم تحويلها إلى "غير مكتملة".',
      );
    }

    return StatusUi(
      label: 'حالة الطلب',
      color: Colors.orange.shade800,
      bg: Colors.orange.withValues(alpha: 0.10),
      border: Colors.orange.withValues(alpha: 0.35),
      footerText: 'بانتظار تحديث حالة الطلب.',
    );
  }
}
