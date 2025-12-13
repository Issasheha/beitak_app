import 'package:flutter/material.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/constants/colors.dart';

class NotificationSettingsSection extends StatefulWidget {
  const NotificationSettingsSection({super.key});

  @override
  State<NotificationSettingsSection> createState() =>
      _NotificationSettingsSectionState();
}

class _NotificationSettingsSectionState
    extends State<NotificationSettingsSection> {
  bool email = true;
  bool sms = true;
  bool push = true;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: SizeConfig.padding(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إعدادات الإشعارات',
              style: TextStyle(
                fontSize: SizeConfig.ts(14),
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: SizeConfig.h(10)),
            _ToggleRow(
              title: 'إشعارات البريد الإلكتروني',
              value: email,
              onChanged: (v) => setState(() => email = v),
            ),
            SizedBox(height: SizeConfig.h(6)),
            _ToggleRow(
              title: 'إشعارات الرسائل (SMS)',
              value: sms,
              onChanged: (v) => setState(() => sms = v),
            ),
            SizedBox(height: SizeConfig.h(6)),
            _ToggleRow(
              title: 'إشعارات التطبيق (Push)',
              value: push,
              onChanged: (v) => setState(() => push = v),
            ),

            // ملاحظة صغيرة (اختياري)
            SizedBox(height: SizeConfig.h(8)),
            Text(
              'ملاحظة: سيتم ربط هذه الإعدادات مع الباك إند لاحقًا.',
              style: TextStyle(
                fontSize: SizeConfig.ts(11),
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.lightGreen,
        ),
      ],
    );
  }
}
