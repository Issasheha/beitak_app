import 'package:beitak_app/core/error/error_text.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/history/viewmodels/provider_history_providers.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/history/viewmodels/provider_history_state.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/history/widgets/history_booking_card.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/history/widgets/history_error_view.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/history/widgets/history_filter_chip.dart';
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
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
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
          error: (err, _) => HistoryErrorView(
            message: errorText(err),
            onRetry: () => ref.read(providerHistoryControllerProvider.notifier).refresh(),
          ),
          data: (state) {
            final controller = ref.read(providerHistoryControllerProvider.notifier);
            final items = state.visibleBookings;

            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: SizeConfig.padding(horizontal: 16, vertical: 8),
                    child: Text(
                      'عرض الخدمات الملغية والمكتملة وغير المكتملة',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.body14.copyWith(
                        fontSize: SizeConfig.ts(13),
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Padding(
                    padding: SizeConfig.padding(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: HistoryFilterChip(
                            label: 'مكتمل',
                            selected: state.activeTab == HistoryTab.completed,
                            onTap: () => controller.setTab(HistoryTab.completed),
                          ),
                        ),
                        SizeConfig.hSpace(8),
                        Expanded(
                          child: HistoryFilterChip(
                            label: 'غير مكتملة',
                            selected: state.activeTab == HistoryTab.incomplete,
                            onTap: () => controller.setTab(HistoryTab.incomplete),
                            selectedColor: const Color(0xFF6B7280),
                          ),
                        ),
                        SizeConfig.hSpace(8),
                        Expanded(
                          child: HistoryFilterChip(
                            label: 'ملغي',
                            selected: state.activeTab == HistoryTab.cancelled,
                            onTap: () => controller.setTab(HistoryTab.cancelled),
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
                        : NotificationListener<ScrollNotification>(
                            onNotification: (n) {
                              if (n.metrics.pixels >= n.metrics.maxScrollExtent - 220) {
                                ref.read(providerHistoryControllerProvider.notifier).loadMore();
                              }
                              return false;
                            },
                            child: ListView.separated(
                              padding: SizeConfig.padding(horizontal: 16, vertical: 8),
                              itemBuilder: (ctx, index) => HistoryBookingCard(item: items[index]),
                              separatorBuilder: (_, __) => SizeConfig.v(8),
                              itemCount: items.length,
                            ),
                          ),
                  ),

                  if (state.isLoadingMore)
                    Padding(
                      padding: SizeConfig.padding(horizontal: 16, vertical: 10),
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
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
