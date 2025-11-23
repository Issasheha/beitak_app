// تعريف الكلاس _Tab داخل AuthMethodTabs
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class AuthMethodTabs extends StatelessWidget {
  final bool isOtpSelected;
  final ValueChanged<bool> onTabChanged;
  final bool isSmallScreen;

  const AuthMethodTabs({
    super.key,
    required this.isOtpSelected,
    required this.onTabChanged,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final double fontSize = isSmallScreen
        ? SizeConfig.ts(12)
        : SizeConfig.ts(14.25);
    final double iconSize = isSmallScreen
        ? SizeConfig.w(15.75)
        : SizeConfig.w(18.75);

    return Row(
      children: [
        Expanded(
          child: _Tab(
            text: isSmallScreen ? 'إيميل وكلمة' : 'إيميل وكلمة مرور',
            icon: Icons.lock,
            selected: !isOtpSelected, // تم تعديل التحديد لعرض فقط خيار الإيميل
            onTap: () => onTabChanged(false),
            fontSize: fontSize,
            iconSize: iconSize,
            
          ),
        ),
      ],
    );
  }
}

// تعريف الـ _Tab داخل نفس الكلاس
class _Tab extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final double fontSize;
  final double iconSize;

  const _Tab({
    required this.text,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.fontSize,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final verticalPad = SizeConfig.h(11.37);
    final horizontalPad = SizeConfig.w(12);
    final radius = SizeConfig.w(30);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          vertical: verticalPad,
          horizontal: horizontalPad,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryGreen
              : AppColors.textSecondary,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.black87, size: iconSize),
              SizedBox(width: SizeConfig.w(7.5)),
              Text(
                text,
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
