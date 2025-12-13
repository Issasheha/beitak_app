import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/history/provider_history_providers.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/history/provider_history_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProviderHistoryView extends ConsumerWidget {
  const ProviderHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);
    final asyncState = ref.watch(providerHistoryControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'السجل',
            style: AppTextStyles.title18.copyWith(
              fontSize: SizeConfig.ts(18),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: asyncState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => _ErrorView(
            message: err.toString(),
            onRetry: () =>
                ref.read(providerHistoryControllerProvider.notifier).refresh(),
          ),
          data: (state) {
            final controller = ref.read(
              providerHistoryControllerProvider.notifier,
            );

            List<BookingHistoryItem> items;
            switch (state.activeTab) {
              case HistoryTab.completed:
                items = state.completed;
                break;
              case HistoryTab.notCompleted:
                items = state.notCompleted;
                break;
              case HistoryTab.cancelled:
                items = state.cancelled;
                break;
            }

            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: SizeConfig.padding(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'عرض الخدمات الملغية والمكتملة',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.body14.copyWith(
                        fontSize: SizeConfig.ts(13),
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Padding(
                    padding: SizeConfig.padding(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _FilterChip(
                            label: 'مكتمل',
                            selected: state.activeTab == HistoryTab.completed,
                            onTap: () =>
                                controller.setTab(HistoryTab.completed),
                          ),
                        ),
                        SizeConfig.hSpace(8),
                        Expanded(
                          child: _FilterChip(
                            label: 'غير مكتمل',
                            selected:
                                state.activeTab == HistoryTab.notCompleted,
                            onTap: () =>
                                controller.setTab(HistoryTab.notCompleted),
                          ),
                        ),
                        SizeConfig.hSpace(8),
                        Expanded(
                          child: _FilterChip(
                            label: 'ملغي',
                            selected: state.activeTab == HistoryTab.cancelled,
                            onTap: () =>
                                controller.setTab(HistoryTab.cancelled),
                            selectedColor: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizeConfig.v(8),
                  Expanded(
                    child: items.isEmpty
                        ? Center(
                            child: Text(
                              'لا يوجد حجوزات في هذا القسم حالياً',
                              style: AppTextStyles.body14.copyWith(
                                fontSize: SizeConfig.ts(13),
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: SizeConfig.padding(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemBuilder: (ctx, index) {
                              final item = items[index];
                              return _BookingCard(item: item);
                            },
                            separatorBuilder: (_, __) => SizeConfig.v(8),
                            itemCount: items.length,
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ===================== Widgets مساعدة =====================

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? selectedColor;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg =
        selected ? (selectedColor ?? AppColors.lightGreen) : Colors.white;
    final borderColor = selected
        ? (selectedColor ?? AppColors.lightGreen)
        : AppColors.borderLight.withValues(alpha: 0.9);
    final textColor = selected ? Colors.white : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SizeConfig.radius(20)),
      child: Container(
        height: SizeConfig.h(38),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(SizeConfig.radius(20)),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: AppTextStyles.body14.copyWith(
            fontSize: SizeConfig.ts(13),
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingHistoryItem item;

  const _BookingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;

    if (item.isCancelled) {
      statusColor = Colors.redAccent;
      statusLabel = 'ملغي';
    } else if (item.isCompleted) {
      statusColor = AppColors.lightGreen;
      statusLabel = 'مكتمل';
    } else {
      statusColor = const Color(0xFFFFB300); // أصفر/برتقالي
      statusLabel = 'غير مكتمل';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.8),
        ),
      ),
      child: Padding(
        padding: SizeConfig.padding(
          horizontal: 12,
          vertical: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // السطر الأول: حالة صغيرة + عنوان الخدمة
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.w(10),
                    vertical: SizeConfig.h(4),
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(
                      SizeConfig.radius(20),
                    ),
                  ),
                  child: Text(
                    statusLabel,
                    style: AppTextStyles.caption11.copyWith(
                      fontSize: SizeConfig.ts(11.5),
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
                SizeConfig.hSpace(8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.serviceTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body14.copyWith(
                          fontSize: SizeConfig.ts(14),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizeConfig.v(2),
                      Text(
                        item.customerName,
                        style: AppTextStyles.body14.copyWith(
                          fontSize: SizeConfig.ts(12),
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizeConfig.v(8),

            // السطر الثاني: التاريخ + الوقت + العنوان
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.dateLabel} في ${item.timeLabel}',
                        style: AppTextStyles.caption11.copyWith(
                          fontSize: SizeConfig.ts(11.5),
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizeConfig.v(2),
                      Text(
                        _buildAddress(),
                        style: AppTextStyles.caption11.copyWith(
                          fontSize: SizeConfig.ts(11.5),
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${item.totalPrice.toStringAsFixed(2)} د.أ',
                  style: AppTextStyles.body14.copyWith(
                    fontSize: SizeConfig.ts(13),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            if (item.cancellationReason != null &&
                item.cancellationReason!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(
                  top: SizeConfig.h(8),
                ),
                child: Container(
                  padding: SizeConfig.padding(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(
                      SizeConfig.radius(12),
                    ),
                  ),
                  child: Text(
                    'سبب الإلغاء: ${item.cancellationReason}',
                    style: AppTextStyles.caption11.copyWith(
                      fontSize: SizeConfig.ts(11.5),
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _buildAddress() {
    if (item.area == null || item.area!.trim().isEmpty) {
      return item.city;
    }
    return '${item.city}، ${item.area}';
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(13),
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizeConfig.v(12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightGreen,
              ),
              child: Text(
                'إعادة المحاولة',
                style: AppTextStyles.body14.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
