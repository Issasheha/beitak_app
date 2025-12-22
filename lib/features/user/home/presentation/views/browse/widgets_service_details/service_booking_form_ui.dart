import 'package:flutter/material.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

enum InlineMsgType { info, error, success }

class AmPmChip extends StatelessWidget {
  const AmPmChip({
    super.key,
    required this.text,
    required this.selected,
  });

  final String text; // ص / م
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.lightGreen.withValues(alpha: 0.16)
            : AppColors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected
              ? AppColors.lightGreen.withValues(alpha: 0.35)
              : AppColors.borderLight,
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(
          fontSize: SizeConfig.ts(11.5),
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          height: 1.0,
        ),
      ),
    );
  }
}

class InlineBanner extends StatelessWidget {
  const InlineBanner({
    super.key,
    required this.message,
    required this.type,
    required this.onClose,
  });

  final String message;
  final InlineMsgType type;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    IconData icon;

    switch (type) {
      case InlineMsgType.success:
        bg = AppColors.lightGreen.withValues(alpha: 0.10);
        border = AppColors.lightGreen.withValues(alpha: 0.35);
        icon = Icons.check_circle_rounded;
        break;

      case InlineMsgType.info:
        bg = AppColors.cardBackground;
        border = AppColors.borderLight;
        icon = Icons.info_outline_rounded;
        break;

      case InlineMsgType.error:
        bg = Colors.redAccent.withValues(alpha: 0.08);
        border = Colors.redAccent.withValues(alpha: 0.35);
        icon = Icons.error_outline_rounded;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: type == InlineMsgType.error ? Colors.redAccent : AppColors.lightGreen,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontSize: SizeConfig.ts(12.8),
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (onClose != null) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: onClose,
              child: const Icon(
                Icons.close,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SheetError extends StatelessWidget {
  const SheetError({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 120),
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightGreen,
                ),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
