import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
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
          // ✅ سهم رجوع RTL صحيح + على اليمين (لأن leading = start و start في RTL = يمين)
          leading: IconButton(
            icon: const BackButtonIcon(), // ✅ يعكس تلقائياً حسب RTL
            color: AppColors.textPrimary,
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.providerHome);
              }
            },
          ),
          // title: const Text(
          //   'خدماتي',
          //   style: TextStyle(fontWeight: FontWeight.bold),
          // ),
        ),
        body: Stack(
          children: [
            const ProviderMyServicesBackground(),
            Column(
              children: [
                // ✅ الهيدر (لوغو + عنوان + وصف)
                const ProviderMyServiceHeader(),

                Expanded(
                  child: Padding(
                    padding: SizeConfig.padding(horizontal: 16, vertical: 8),
                    child: async.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(
                        child: Text(
                          'حدث خطأ:\n$e',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      data: (services) {
                        if (services.isEmpty) {
                          return const ProviderEmptyServicesState(
                            message: 'لا توجد خدمات منشورة حالياً',
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async => ref.invalidate(providerMyServicesProvider),
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: services.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (_, i) => ProviderServiceCard(service: services[i]),
                          ),
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

