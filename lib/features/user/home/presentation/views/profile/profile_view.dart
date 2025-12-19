import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

import 'package:beitak_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:beitak_app/features/user/home/presentation/views/profile/viewmodels/profile_providers.dart';

import 'package:beitak_app/features/user/home/presentation/views/profile/widgets/recent_activity_section.dart';

import 'account_settings_view.dart';
import 'account_setting_widgets/account_settings_header.dart';
import 'account_setting_widgets/account_user_card.dart';
import 'account_setting_widgets/account_settings_tile.dart';
import 'account_setting_widgets/account_support_buttons.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(profileControllerProvider.notifier).refresh();
    });
  }

  void _smartBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }
  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final state = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop) _smartBack(context);
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              AccountSettingsHeader(
                title: 'الملف الشخصي',
                onBack: () => _smartBack(context),
                onRefresh: state.isLoading ? null : controller.refresh,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.refresh(),
                  child: ListView(
                    padding: SizeConfig.padding(horizontal: 16, vertical: 14),
                    children: [
                      // ✅ الكرت الرئيسي (الاسم + ايميل + هاتف + City فقط + Member since)
                      AccountUserCard(profile: state.profile),

                      SizedBox(height: SizeConfig.h(12)),

                      if (state.errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding:
                              SizeConfig.padding(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.06),
                            borderRadius:
                                BorderRadius.circular(SizeConfig.radius(14)),
                            border: Border.all(
                                color: Colors.red.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            state.errorMessage!,
                            style: AppTextStyles.semiBold.copyWith(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w700,
                              fontSize: SizeConfig.ts(13),
                            ),
                          ),
                        ),
                        SizedBox(height: SizeConfig.h(10)),
                      ],

                      // ✅ آخر الأنشطة (عندك جاهز)
                      RecentActivitySection(items: state.activities),

                      SizedBox(height: SizeConfig.h(12)),
                      // ✅ Tile: الإعدادات (تفتح صفحة AccountSettingsView)
                      AccountSettingsTile(
                        title: 'إعدادات الحساب',
                        subtitle: 'البيانات، كلمة المرور والإشعارات',
                        icon: Icons.settings,
                        onTap: () {
                          // لو بدك بدلها: context.push(AppRoutes.accountSettings);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const AccountSettingsView()),
                          );
                        },
                      ),

                      SizedBox(height: SizeConfig.h(12)),                      
                      AccountSupportButtons(
                        onLogout: () async {
                          await ref
                              .read(authControllerProvider.notifier)
                              .logout();
                        },
                      ),

                      SizedBox(height: SizeConfig.h(16)),

                      Center(
                        child: Text(
                          'نسخة التطبيق 1.0.0\nجميع الحقوق محفوظة © 2024 BAITAK',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: SizeConfig.ts(11.5),
                            color:
                                AppColors.textSecondary.withValues(alpha: 0.75),
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ),
                      SizedBox(height: SizeConfig.h(8)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
