import 'package:beitak_app/core/constants/color_x.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class AccountSettingsHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback? onRefresh;

  const AccountSettingsHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: top + SizeConfig.h(10)),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        boxShadow: [
          BoxShadow(
            color: Colors.black.o(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: SizeConfig.padding(horizontal: 14, vertical: 12),
        child: Row(
          // ✅ هذا أهم سطر: يخلي أول عنصر ينحط يمين
          textDirection: TextDirection.rtl,
          children: [
            // ✅ Back (يمين)
            _CircleIcon(
              icon: Icons.arrow_back_ios_new,
              onTap: onBack,
            ),

            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeConfig.ts(15.5),
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),

            // ✅ Refresh (يسار)
            _CircleIcon(
              icon: Icons.refresh_rounded,
              onTap: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleIcon({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: SizeConfig.w(40),
          height: SizeConfig.w(40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: SizeConfig.w(18),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
