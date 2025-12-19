import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/providers/provider_my_services_provider.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/widgets/provider_empty_services_state.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/widgets/provider_my_service_background_decoration.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/widgets/provider_my_service_card.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/widgets/provider_my_service_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProviderMyServiceView extends ConsumerWidget {
  const ProviderMyServiceView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);
    final async = ref.watch(providerMyServicesProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const BackButtonIcon(),
            color: AppColors.textPrimary,
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.providerHome);
              }
            },
          ),
        ),
        body: Stack(
          children: [
            const ProviderMyServicesBackground(),
            Column(
              children: [
                const ProviderMyServiceHeader(),

                Expanded(
                  child: Padding(
                    padding: SizeConfig.padding(horizontal: 16, vertical: 8),
                    child: async.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) => Center(
                        child: Text(
                          'تعذر تحميل الخدمات حالياً.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body14.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      data: (services) {
                        if (services.isEmpty) {
                          return const ProviderEmptyServicesState(
                            message: 'لا توجد خدمات منشورة حالياً',
                          );
                        }

                        // ✅ Sort: active first, inactive last (stable)
                        final originalIndex = <int, int>{
                          for (int i = 0; i < services.length; i++)
                            services[i].id: i,
                        };

                        final sortedServices = [...services]..sort((a, b) {
                            final aKey = a.isActive ? 0 : 1; // 0 active, 1 inactive
                            final bKey = b.isActive ? 0 : 1;
                            if (aKey != bKey) return aKey - bKey;
                            return (originalIndex[a.id] ?? 0)
                                .compareTo(originalIndex[b.id] ?? 0);
                          });

                        return Column(
                          children: [
                            // ✅ Count + small add button (nice + compact)
                            Row(
                              children: [
                                Text(
                                  'الخدمات (${sortedServices.length})',
                                  style: AppTextStyles.body14.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const Spacer(),
                                InkWell(
                                  borderRadius: BorderRadius.circular(999),
                                  onTap: () => context.push(AppRoutes.providerAddService),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightGreen
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: AppColors.lightGreen
                                            .withValues(alpha: 0.35),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.add,
                                          size: 18,
                                          color: AppColors.lightGreen,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'إضافة خدمة',
                                          style: AppTextStyles.body14.copyWith(
                                            fontSize: SizeConfig.ts(12.5),
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.lightGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizeConfig.v(10),

                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () async =>
                                    ref.invalidate(providerMyServicesProvider),
                                child: ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: sortedServices.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 14),
                                  itemBuilder: (_, i) => ProviderServiceCard(
                                    service: sortedServices[i],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
