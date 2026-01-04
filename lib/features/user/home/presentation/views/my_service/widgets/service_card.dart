import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

import 'package:beitak_app/features/user/home/presentation/views/my_service/models/booking_list_item.dart';
import 'package:beitak_app/features/user/home/presentation/views/my_service/service_details_view.dart';

class ServiceCard extends ConsumerWidget {
  final BookingListItem item;
  final VoidCallback onChanged;

  const ServiceCard({
    super.key,
    required this.item,
    required this.onChanged,
  });

  _CardStatusUi _statusUi(String status) {
    final s = status.trim();

    final isCancelled = s == 'cancelled' || s == 'refunded';
    final isCompleted = s == 'completed';
    final isIncomplete = s == 'incomplete'; // ✅ NEW
    final isPending = s == 'pending_provider_accept' || s == 'pending';
    final isUpcoming = const {
      'confirmed',
      'provider_on_way',
      'provider_arrived',
      'in_progress',
      'upcoming',
    }.contains(s);

    if (isCancelled) {
      return _CardStatusUi(
        label: 'ملغية',
        color: Colors.red.shade700,
        icon: Icons.cancel_rounded,
      );
    }
    if (isCompleted) {
      return _CardStatusUi(
        label: 'مكتملة',
        color: Colors.blue.shade700,
        icon: Icons.verified_rounded,
      );
    }
    if (isPending) {
      return _CardStatusUi(
        label: 'قيد الانتظار',
        color: Colors.orange.shade700,
        icon: Icons.info_outline_rounded,
      );
    }
    if (isUpcoming) {
      return const _CardStatusUi(
        label: 'قادمة',
        color: AppColors.lightGreen,
        icon: Icons.schedule_rounded,
      );
    }

    // ✅ NEW
    if (isIncomplete) {
      return _CardStatusUi(
        label: 'غير مكتملة',
        color: Colors.grey.shade700,
        icon: Icons.error_outline_rounded,
      );
    }

    return const _CardStatusUi(
      label: 'حالة الطلب',
      color: AppColors.textSecondary,
      icon: Icons.info_outline_rounded,
    );
  }

  Future<void> _openDetails(BuildContext context) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ServiceDetailsView(initialItem: item),
      ),
    );

    if (changed == true) onChanged();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ui = _statusUi(item.status);

    final bookingNo = (item.bookingNumber).trim();
    final title = (item.serviceName).trim();
    final date = (item.date).trim();
    final time = (item.time).trim();
    final loc = (item.location).trim();

    return Padding(
      padding: SizeConfig.padding(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _openDetails(context),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              PositionedDirectional(
                start: 0,
                top: 10,
                bottom: 10,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: ui.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Padding(
                padding: SizeConfig.padding(all: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _StatusPill(ui: ui),
                        const Spacer(),
                        Text(
                          bookingNo.isEmpty ? '—' : bookingNo,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: SizeConfig.ts(14),
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizeConfig.v(12),
                    Text(
                      title.isEmpty ? '—' : title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: SizeConfig.ts(22),
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizeConfig.v(14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _MiniInfoTextThenIcon(
                          text: date.isEmpty ? '—' : date,
                          icon: Icons.calendar_today_rounded,
                        ),
                        const SizedBox(width: 18),
                        _MiniInfoTextThenIcon(
                          text: time.isEmpty ? '—' : time,
                          icon: Icons.access_time_rounded,
                        ),
                      ],
                    ),
                    SizeConfig.v(12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            loc.isEmpty ? '—' : loc,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: SizeConfig.ts(14),
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.location_on_rounded,
                          size: 20,
                          color: Colors.red.shade600,
                        ),
                      ],
                    ),
                    SizeConfig.v(16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () => _openDetails(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lightGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'عرض التفاصيل',
                                style: TextStyle(
                                  fontSize: SizeConfig.ts(14),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardStatusUi {
  final String label;
  final Color color;
  final IconData icon;

  const _CardStatusUi({
    required this.label,
    required this.color,
    required this.icon,
  });
}

class _StatusPill extends StatelessWidget {
  final _CardStatusUi ui;

  const _StatusPill({required this.ui});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: ui.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: ui.color.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            ui.label,
            style: TextStyle(
              fontSize: SizeConfig.ts(14),
              fontWeight: FontWeight.w900,
              color: ui.color,
            ),
          ),
          const SizedBox(width: 8),
          Icon(ui.icon, size: 18, color: ui.color),
        ],
      ),
    );
  }
}

class _MiniInfoTextThenIcon extends StatelessWidget {
  final String text;
  final IconData icon;

  const _MiniInfoTextThenIcon({
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: SizeConfig.ts(14),
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 20, color: AppColors.textSecondary),
      ],
    );
  }
}
