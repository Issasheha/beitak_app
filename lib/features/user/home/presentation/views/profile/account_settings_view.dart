import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

import 'package:beitak_app/features/user/home/presentation/views/profile/viewmodels/profile_providers.dart';

import 'account_setting_widgets/account_profile_form_card.dart';
import 'account_setting_widgets/account_change_password_card.dart';
import 'account_setting_widgets/account_terms_section.dart';
import 'account_setting_widgets/account_danger_zone.dart';
import 'account_setting_widgets/account_notification_section.dart';

class AccountSettingsView extends ConsumerStatefulWidget {
  const AccountSettingsView({super.key});

  @override
  ConsumerState<AccountSettingsView> createState() => _AccountSettingsViewState();
}

class _AccountSettingsViewState extends ConsumerState<AccountSettingsView> {
  @override
  void initState() {
    super.initState();
    // ✅ نفس سلوك ProfileView القديم: أول ما تفتح الصفحة نعمل refresh
    Future.microtask(() => ref.read(profileControllerProvider.notifier).refresh());
  }

  void _smartBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<bool> _deleteAccountFlow() async {
    try {
      final repo = ref.read(profileRepositoryProvider);
      await repo.deleteAccount(); // DELETE /api/users/profile
      await ref.read(profileControllerProvider.notifier).logout();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final state = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.lightGreen,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'إعدادات الحساب',
            style: AppTextStyles.screenTitle.copyWith(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => _smartBack(context),
          ),
          actions: [
            IconButton(
              tooltip: 'تحديث',
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: state.isLoading ? null : controller.refresh,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => controller.refresh(),
          child: ListView(
            padding: SizeConfig.padding(horizontal: 16, vertical: 16),
            children: [
              if (state.errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: SizeConfig.padding(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
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
                SizedBox(height: SizeConfig.h(12)),
              ],

              // ✅ بيانات الحساب (الاسم الكامل / البريد / الهاتف)
              AccountProfileFormCard(profile: state.profile),

              SizedBox(height: SizeConfig.h(12)),

              // ✅ تغيير كلمة المرور (inline مثل الصورة)
              const AccountChangePasswordCard(),

              SizedBox(height: SizeConfig.h(12)),

              // ✅ الإشعارات
              const AccountNotificationSection(),

              SizedBox(height: SizeConfig.h(12)),

              // ✅ الشروط والمساعدة (Placeholders حالياً)
              const AccountTermsSection(),

              SizedBox(height: SizeConfig.h(14)),

              // ✅ منطقة الخطر (حذف الحساب)
              AccountDangerZone(
                onDeleteAccount: _deleteAccountFlow,
              ),

              SizedBox(height: SizeConfig.h(10)),

              Center(
                child: Text(
                  'نسخة التطبيق 1.0.0',
                  style: TextStyle(
                    fontSize: SizeConfig.ts(11),
                    color: AppColors.textSecondary.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w600,
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
