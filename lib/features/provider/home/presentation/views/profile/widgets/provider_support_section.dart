import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/profile_action_item.dart';
import 'package:go_router/go_router.dart';

class ProviderSupportSection extends StatelessWidget {
  const ProviderSupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileActionGroupCard(
      children: [
        ProfileActionItem(
          label: 'إعدادات الحساب',
          icon: Icons.settings_outlined,
          onTap: () => context.push(AppRoutes.provideraccountSettings),
          showDivider: true,
        ),
        ProfileActionItem(
          label: 'الشروط والأحكام',
          icon: Icons.description_outlined,
          onTap: () => context.push(AppRoutes.providerTerms),
          showDivider: true,
        ),
        ProfileActionItem(
          label: 'المساعدة والدعم',
          icon: Icons.help_outline,
          onTap: () => context.push(AppRoutes.providerHelpCenter),
          showDivider: true,
        ),
        ProfileActionItem(
          label: 'حول بيتك',
          icon: Icons.info_outline,
          onTap: () => context.push(AppRoutes.providerAboutView),
          showDivider: true,
        ),
        ProfileActionItem(
          label: 'السجل',
          icon: Icons.history,
          onTap: () => context.push(AppRoutes.providerHistory),
          showDivider: false,
        ),
      ],
    );
  }
}
