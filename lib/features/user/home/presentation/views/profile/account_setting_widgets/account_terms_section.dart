import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

class AccountTermsSection extends StatelessWidget {
  const AccountTermsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          _Tile(
            title: 'الشروط والأحكام',
            icon: Icons.description_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('قريبًا: الشروط والأحكام')),
              );
            },
          ),
          _Divider(),
          _Tile(
            title: 'المساعدة والدعم',
            icon: Icons.support_agent,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('قريبًا: المساعدة والدعم')),
              );
            },
          ),
          _Divider(),
          _Tile(
            title: 'حول بيتك',
            icon: Icons.info_outline,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('قريبًا: حول بيتك')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: SizeConfig.h(14),
      color: Colors.grey.withValues(alpha: 0.18),
    );
  }
}

class _Tile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _Tile({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
      onTap: onTap,
      child: Padding(
        padding: SizeConfig.padding(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary),
            SizedBox(width: SizeConfig.w(10)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: SizeConfig.ts(13),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_left, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
