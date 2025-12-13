import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RoleSelectionCard extends StatelessWidget {
  final bool isProvider;
  final ValueChanged<bool> onRoleChanged;
  final bool isSmallScreen;

  const RoleSelectionCard({
    super.key,
    required this.isProvider,
    required this.onRoleChanged,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSmallScreen) {
      return Column(
        children: [
          _RoleButton(
            title: 'مواطن',
            iconBuilder: PhosphorIcons.houseSimple,
            selected: !isProvider,
            onTap: () => onRoleChanged(false),
          ),
          SizedBox(height: SizeConfig.h(8.12)),
          _RoleButton(
            title: 'مزود خدمة',
            iconBuilder: PhosphorIcons.wrench,
            selected: isProvider,
            onTap: () => onRoleChanged(true),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _RoleButton(
            title: 'مستخدم',
            iconBuilder: PhosphorIcons.houseLine,
            selected: !isProvider,
            onTap: () => onRoleChanged(false),
          ),
        ),
        SizedBox(width: SizeConfig.w(11.25)),
        Expanded(
          child: _RoleButton(
            title: 'مزود خدمة',
            iconBuilder: PhosphorIcons.wrench,
            selected: isProvider,
            onTap: () => onRoleChanged(true),
          ),
        ),
      ],
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String title;
  final PhosphorIconData Function(PhosphorIconsStyle) iconBuilder;
  final bool selected;
  final VoidCallback onTap;

  const _RoleButton({
    required this.title,
    required this.iconBuilder,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style =
        selected ? PhosphorIconsStyle.bold : PhosphorIconsStyle.regular;
    final verticalPadding = SizeConfig.h(21.11);
    final radius = SizeConfig.w(15);
    SizeConfig.w(24.38); // تركتها زي ما هي (غير مستخدمة) عشان ما نغيّر سلوك/ملف
    final fontSize = SizeConfig.ts(14.25);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          decoration: BoxDecoration(
            color: selected ? AppColors.white : Colors.white,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: selected ? AppColors.lightGreen : Colors.brown,
              width: selected ? 2.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.lightGreen.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              PhosphorIcon(
                iconBuilder(style),
                size: 35,
                color:
                    selected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
              SizedBox(height: SizeConfig.h(7.31)),
              Text(
                title,
                style: AppTextStyles.body14.copyWith(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700, // كان bold
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
