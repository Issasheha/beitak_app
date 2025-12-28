// lib/features/user/home/presentation/views/home_view.dart

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/user/home/presentation/viewmodels/home_header_providers.dart';
import 'package:beitak_app/features/user/home/presentation/widgets/crystal_bottom_navigation_bar.dart';
import 'package:beitak_app/features/user/home/presentation/widgets/home_background_decoration.dart';
import 'package:beitak_app/features/user/home/presentation/widgets/home_green_header.dart';
import 'package:beitak_app/features/user/home/presentation/widgets/orbit_category_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);

    final headerState = ref.watch(homeHeaderControllerProvider);
    final displayName = headerState.displayName;

    // ✅ منع أي تأثير للكيبورد على الصفحة (حتى أثناء pop)
    final mq = MediaQuery.of(context);
    final frozenMq = mq.copyWith(viewInsets: EdgeInsets.zero);

    return MediaQuery(
      data: frozenMq,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          extendBody: true,
          backgroundColor: AppColors.background,

          // ✅ مهم: لا تعيد تحجيم الصفحة بسبب الكيبورد
          resizeToAvoidBottomInset: false,

          body: Stack(
            children: [
              const HomeBackgroundDecoration(),
              LayoutBuilder(
                builder: (context, constraints) {
                  final h = constraints.maxHeight;
                  final headerH = (h * 0.43).clamp(290.0, 380.0);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      HomeGreenHeader(
                        height: headerH,
                        displayName: displayName,
                        onProfileTap: () => context.push(AppRoutes.profile),
                        onNotificationsTap: () =>
                            context.push(AppRoutes.notifications),
                        onSearchTap: () => context.push(AppRoutes.search),

                        // ✅ لما يكبس مايك من الهوم:
                        onVoiceSearchTap: () =>
                            context.push('${AppRoutes.search}?auto_voice=1'),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(
                            top: SizeConfig.h(18),
                            bottom: SizeConfig.h(110),
                          ),
                          child: Padding(
                            padding:
                                SizeConfig.padding(horizontal: 18, vertical: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'تصفح حسب الفئة',
                                  style: AppTextStyles.sectionTitle.copyWith(
                                    fontSize: SizeConfig.ts(12.8),
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: SizeConfig.h(14)),
                                const OrbitCategoryWidget(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          bottomNavigationBar: const CrystalBottomNavigationBar(),
        ),
      ),
    );
  }
}
