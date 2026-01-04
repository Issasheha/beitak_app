import 'package:beitak_app/features/auth/presentation/viewmodels/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/core/error/error_text.dart';
import 'package:beitak_app/features/user/home/presentation/views/profile/account_setting_widgets/confirm_action_dialog.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/viewmodels/provider_profile_providers.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/provider_profile_header_card.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/provider_about_section.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/reviews/provider_reviews_section.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/provider_availability_section.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/provider_profile_section_card.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/provider_support_section.dart';

class ProviderProfileView extends ConsumerWidget {
  const ProviderProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);

    final async = ref.watch(providerProfileControllerProvider);
    final controller = ref.read(providerProfileControllerProvider.notifier);

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
            onPressed: () => context.go(AppRoutes.providerHome),
          ),
          title: Text(
            'الملف الشخصي',
            style: AppTextStyles.title18.copyWith(
              fontSize: SizeConfig.ts(18),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'تعديل الحساب',
              icon: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
              onPressed: () => context.push(AppRoutes.provideraccountEdit),
            ),
          ],
        ),
        body: SafeArea(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),

            // ✅ IMPORTANT: لا تستخدم e.toString() نهائياً
            error: (e, _) => _ErrorState(
              message: errorText(e),
              onRetry: () => controller.refresh(),
            ),

            data: (state) {
              return SingleChildScrollView(
                padding: SizeConfig.padding(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!state.isFullyVerified)
                      _VerificationBanner(
                        missing: state.missingRequiredDocs,
                        onTapDocs: () =>
                            context.push(AppRoutes.providerdocumentsView),
                      ),
                    ProviderProfileHeaderCard(state: state),
                    SizeConfig.v(14),
                    ProviderAboutSection(state: state, controller: controller),
                    SizeConfig.v(12),
                    ProviderReviewsSection(state: state),
                    SizeConfig.v(12),
                    const ProviderAvailabilitySection(),
                    SizeConfig.v(12),
                    const ProviderProfileSectionCard(
                      title: '',
                      child: ProviderSupportSection(),
                    ),
                    SizeConfig.v(18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          foregroundColor: Colors.white,
                          padding: SizeConfig.padding(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                          ),
                        ),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            barrierDismissible: true,
                            builder: (_) =>
                                const ConfirmActionDialog(mode: ConfirmMode.logout),
                          );

                          if (confirmed != true) return;

                          try {
                            await ref.read(authControllerProvider.notifier).logout();
                          } catch (_) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تعذر تسجيل الخروج، حاول مرة أخرى'),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'تسجيل الخروج',
                          style: AppTextStyles.body14.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizeConfig.v(10),
                    Center(
                      child: Text(
                        'نسخة تجريبية 1.0.0',
                        style: AppTextStyles.body14.copyWith(
                          fontSize: SizeConfig.ts(12),
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizeConfig.v(14),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _VerificationBanner extends StatelessWidget {
  final List<String> missing;
  final VoidCallback onTapDocs;

  const _VerificationBanner({
    required this.missing,
    required this.onTapDocs,
  });

  @override
  Widget build(BuildContext context) {
    final msg = missing.isEmpty
        ? 'يلزم توثيق الوثائق لإتاحة جميع الميزات.'
        : 'يلزم توثيق: ${missing.join('، ')}';

    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.h(12)),
      padding: SizeConfig.padding(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(
          color: const Color(0xFFFBC02D).withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFF57F17)),
          SizeConfig.hSpace(10),
          Expanded(
            child: Text(
              msg,
              style: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(13),
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
          TextButton(
            onPressed: onTapDocs,
            child: Text(
              'إدارة الوثائق',
              style: AppTextStyles.body14.copyWith(
                color: AppColors.lightGreen,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 44),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body14.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(
                'إعادة المحاولة',
                style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
