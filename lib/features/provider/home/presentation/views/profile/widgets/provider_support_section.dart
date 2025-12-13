import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/profile_action_item.dart';
import 'package:go_router/go_router.dart';

class ProviderSupportSection extends StatelessWidget {
  const ProviderSupportSection({super.key});

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('قريبًا')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileActionItem(
          label: 'إعدادات الحساب',
          icon: Icons.settings_outlined,
          onTap: () => context.push(AppRoutes.provideraccountSettings),
        ),
        SizeConfig.v(6),
        ProfileActionItem(
          label: 'الشروط والأحكام',
          icon: Icons.description_outlined,
          onTap: () => context.push(AppRoutes.providerTerms),
        ),
        SizeConfig.v(6),
        ProfileActionItem(
          label: 'المساعدة والدعم',
          icon: Icons.help_outline,
          onTap: () => context.push(AppRoutes.providerHelpCenter),
        ),
        SizeConfig.v(6),
        ProfileActionItem(
          label: 'السجل',
          icon: Icons.history,
          onTap: () => context.push(AppRoutes.providerHistory),
        ),
      ],
    );
  }
}
