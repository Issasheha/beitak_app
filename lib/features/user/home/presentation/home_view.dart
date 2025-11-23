import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/features/user/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:beitak_app/features/user/home/presentation/widgets/browse_request_row.dart';
import 'package:beitak_app/features/user/home/presentation/widgets/crystal_bottom_navigation_bar.dart';
import 'package:beitak_app/features/user/home/presentation/widgets/glass_container.dart';
import 'package:beitak_app/features/user/home/presentation/widgets/holographic_service_card.dart';
import 'package:beitak_app/features/user/home/presentation/widgets/orbit_category_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  // ViewModel واحد مشترك لـ HomeView
  static final HomeViewModel _viewModel = HomeViewModel();

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final greeting = _viewModel.greeting;
    final featuredProviders = _viewModel.featuredProviders;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            greeting,
            style: TextStyle(
              fontSize: SizeConfig.ts(24),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            Padding(
              padding: SizeConfig.padding(horizontal: 16),
              child: Badge.count(
                count: 3, // TODO: ربط لاحقًا بعد بناء NotificationsViewModel
                backgroundColor: AppColors.buttonBackground,
                textColor: Colors.white,
                largeSize: 24,
                child: IconButton(
                  onPressed: () {
                    context.push(AppRoutes.notifications);
                  },
                  icon: Icon(
                    Icons.notifications_outlined,
                    size: SizeConfig.w(28),
                    color: AppColors.lightGreen,
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: SizeConfig.padding(all: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // الترحيب
                  Text(
                    greeting,
                    style: TextStyle(
                      fontSize: SizeConfig.ts(24),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizeConfig.v(16),

                  // شريط البحث مع اقتراحات
                  const BrowseRequestRow(),
                  SizeConfig.v(24),

                  // القسم الترويجي
                  GlassContainer(
                    child: Column(
                      children: [
                        Text(
                          'اكتشف سوق خدمات منزلك',
                          style: TextStyle(
                            fontSize: SizeConfig.ts(20),
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizeConfig.v(8),
                        Text(
                          'محترفون موثوقون لكل احتياجاتك – من التنظيف إلى الإصلاحات وأكثر!',
                          style: TextStyle(
                            fontSize: SizeConfig.ts(16),
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizeConfig.v(24),

                  // الفئات في grid
                  const OrbitCategoryWidget(),
                  SizeConfig.v(24),

                  // مقدمو الخدمات
                  Text(
                    'مقدمو الخدمات المميزون',
                    style: TextStyle(
                      fontSize: SizeConfig.ts(20),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizeConfig.v(8),
                  Column(
                    children: featuredProviders
                        .map(
                          (provider) => HolographicServiceCard(
                            provider: provider.toMap(),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: const CrystalBottomNavigationBar(),
      ),
    );
  }
}
