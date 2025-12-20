import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

class AccountNotificationSection extends StatefulWidget {
  const AccountNotificationSection({super.key});

  @override
  State<AccountNotificationSection> createState() => _AccountNotificationSectionState();
}

class _AccountNotificationSectionState extends State<AccountNotificationSection> {
  bool email = true;
  bool sms = true;
  bool push = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_none, color: AppColors.textSecondary),
              SizedBox(width: SizeConfig.w(8)),
              Text(
                'الإشعارات',
                style: TextStyle(
                  fontSize: SizeConfig.ts(13),
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.h(10)),
          _ToggleRow(
            title: 'إشعارات البريد الإلكتروني',
            value: email,
            icon: Icons.notifications,
            onChanged: (v) => setState(() => email = v),
          ),
          SizedBox(height: SizeConfig.h(6)),
          _ToggleRow(
            title: 'إشعارات الرسائل النصية',
            value: sms,
            icon: Icons.notifications,
            onChanged: (v) => setState(() => sms = v),
          ),
          SizedBox(height: SizeConfig.h(6)),
          _ToggleRow(
            title: 'الإشعارات الفورية',
            value: push,
            icon: Icons.notifications,
            onChanged: (v) => setState(() => push = v),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final bool value;
  final IconData icon;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.title,
    required this.value,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.lightGreen),
        SizedBox(width: SizeConfig.w(10)),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: SizeConfig.ts(12.5),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.lightGreen,
        ),
      ],
    );
  }
}
