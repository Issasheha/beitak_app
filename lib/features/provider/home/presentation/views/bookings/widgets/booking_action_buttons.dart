import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

class BookingActionButtons extends StatelessWidget {
  const BookingActionButtons({
    super.key,
    required this.isPending,
    required this.busy,
    required this.onAccept,
    required this.onCancel,
    required this.onComplete,
  });

  final bool isPending;
  final bool busy;

  final VoidCallback? onAccept;
  final VoidCallback? onCancel;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    if (isPending) {
      return Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: _PrimaryBtn(
              label: 'قبول',
              isLoading: busy,
              onTap: (busy || onAccept == null) ? null : onAccept,
            ),
          ),
          SizedBox(width: SizeConfig.w(10)),
          Expanded(
            child: _DangerBtn(
              label: 'إلغاء',
              onTap: (busy || onCancel == null) ? null : onCancel,
            ),
          ),
        ],
      );
    }

    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Expanded(
          child: _PrimaryBtn(
            label: 'إنهاء الخدمة',
            isLoading: busy,
            onTap: (busy || onComplete == null) ? null : onComplete,
          ),
        ),
        SizedBox(width: SizeConfig.w(10)),
        Expanded(
          child: _DangerBtn(
            label: 'إلغاء الخدمة',
            onTap: (busy || onCancel == null) ? null : onCancel,
          ),
        ),
      ],
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  const _PrimaryBtn({
    required this.label,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightGreen,
        elevation: 0,
        padding: SizeConfig.padding(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: SizeConfig.w(18),
              height: SizeConfig.w(18),
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              label,
              style: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(13),
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
    );
  }
}

class _DangerBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _DangerBtn({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: SizeConfig.padding(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.body14.copyWith(
          fontSize: SizeConfig.ts(13),
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}
