import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/viewmodels/provider_profile_providers.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/provider_profile_section_card.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/provider_account_activation_dialog.dart';

class ProviderAvailabilitySection extends ConsumerWidget {
  const ProviderAvailabilitySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = ref.watch(
      providerProfileControllerProvider.select(
        (a) => a.asData?.value.isAvailable ?? false,
      ),
    );

    final isUpdating = ref.watch(
      providerProfileControllerProvider.select(
        (a) => a.asData?.value.isUpdatingAvailability ?? false,
      ),
    );

    // ✅ تفعيل/تعطيل الحساب: لا تربطه بالتوثيق
    final canToggle = !isUpdating;

    return ProviderProfileSectionCard(
      title: 'حالة الحساب',
      child: Row(
        children: [
          Expanded(
            child: Text(
              isActive ? 'الحساب مفعل' : 'الحساب غير مفعل',
              style: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(13.5),
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (isUpdating)
            SizedBox(
              width: SizeConfig.w(18),
              height: SizeConfig.w(18),
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Switch(
              value: isActive,
              onChanged: !canToggle
                  ? null
                  : (v) async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        barrierDismissible: true,
                        builder: (_) => ProviderAccountActivationDialog(
                          mode: v
                              ? ProviderActivationMode.activate
                              : ProviderActivationMode.deactivate,
                        ),
                      );

                      if (confirmed != true) return;

                      final controller =
                          ref.read(providerProfileControllerProvider.notifier);

                      try {
                        await controller.updateAvailability(v);

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(v ? 'تم تفعيل الحساب' : 'تم تعطيل الحساب'),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString().replaceFirst('Exception: ', ''),
                            ),
                          ),
                        );
                      }
                    },
              activeTrackColor: AppColors.lightGreen,
              activeThumbColor: Colors.white,
            ),
        ],
      ),
    );
  }
}
