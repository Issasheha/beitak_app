import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

import 'package:beitak_app/features/user/home/domain/entities/user_profile_entity.dart';
import 'package:beitak_app/features/user/home/presentation/views/profile/viewmodels/profile_providers.dart';

import 'package:beitak_app/features/user/home/presentation/views/profile/widgets/profile_edit_sheet.dart';
import 'package:beitak_app/features/user/home/presentation/views/profile/widgets/recent_activity_section.dart';
import 'package:beitak_app/features/user/home/presentation/views/profile/widgets/support_section.dart';
import 'package:beitak_app/features/user/home/presentation/views/profile/widgets/notification_settings_section.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  @override
  void initState() {
    super.initState();
    // أول ما تفتح شاشة البروفايل نعمل refresh
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

  Future<bool> _deleteAccountFlow(BuildContext context, WidgetRef ref) async {
    try {
      final repo = ref.read(profileRepositoryProvider);
      await repo.deleteAccount(); // DELETE /users/profile
      await ref.read(profileControllerProvider.notifier).logout();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);

    SizeConfig.init(context);

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop && !context.canPop()) {
          context.go(AppRoutes.home);
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'الملف الشخصي',
              style: AppTextStyles.screenTitle.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _smartBack(context),
            ),
            actions: [
              IconButton(
                tooltip: 'تحديث',
                icon: const Icon(Icons.refresh),
                onPressed: state.isLoading ? null : controller.refresh,
              ),
              IconButton(
                tooltip: 'تعديل',
                icon: const Icon(Icons.edit),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: false,
                    builder: (_) => const Directionality(
                      textDirection: TextDirection.rtl,
                      // مبدئياً، ProfileEditSheet ما زال يستقبل vm قديم
                      // في الخطوة الجاية رح نحدّثه ليتعامل مباشرة مع Riverpod.
                      child: ProfileEditSheet(), // رح نعدّله لاحقاً
                    ),
                  );
                },
              ),
            ],
          ),
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            onRefresh: () => controller.refresh(),
            child: ListView(
              padding: SizeConfig.padding(
                horizontal: 16,
                vertical: 16,
              ),
              children: [
                _ProfileHeaderCard(profile: state.profile),

                SizedBox(height: SizeConfig.h(12)),

                if (state.errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: SizeConfig.padding(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.25),
                      ),
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

                RecentActivitySection(items: state.activities),

                SizedBox(height: SizeConfig.h(12)),
                const NotificationSettingsSection(),
                SizedBox(height: SizeConfig.h(18)),

                SupportSection(
                  // رح نعدّل SupportSection لاحقاً ليستغني عن vm
                  onDeleteAccount: () => _deleteAccountFlow(context, ref),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final UserProfileEntity? profile;

  const _ProfileHeaderCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final name = (profile?.name ?? '').trim();
    final email = (profile?.email ?? '').trim();
    final phone = (profile?.phone ?? '').trim();

    final safeName = name.isNotEmpty ? name : 'ضيف عزيز';
    final safeEmail = email.isNotEmpty ? email : '—';
    final safePhone = phone.isNotEmpty ? phone : '—';

    return Container(
      padding: SizeConfig.padding(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.18),
        ),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Container(
            width: SizeConfig.w(52),
            height: SizeConfig.w(52),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lightGreen.withValues(alpha: 0.15),
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(width: SizeConfig.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  safeName,
                  style: AppTextStyles.semiBold.copyWith(
                    fontSize: SizeConfig.ts(16),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: SizeConfig.h(4)),
                // Email LTR
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      safeEmail,
                      textAlign: TextAlign.left,
                      style: AppTextStyles.semiBold.copyWith(
                        fontSize: SizeConfig.ts(13),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: SizeConfig.h(4)),
                Text(
                  'الهاتف: $safePhone',
                  style: AppTextStyles.semiBold.copyWith(
                    fontSize: SizeConfig.ts(13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
