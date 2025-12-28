import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class SearchQueryField extends StatelessWidget {
  const SearchQueryField({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.onMicTap,
    this.micLoading = false,

    // ✅ NEW
    this.autofocus = true,
  });

  final TextEditingController controller;
  final void Function(String text) onSubmitted;

  final VoidCallback? onMicTap;
  final bool micLoading;

  // ✅ NEW
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final compact = h < 700;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.85),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Icon(Icons.search, color: AppColors.textSecondary),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                hintText: 'ماذا تحتاج مساعدة فيه؟',
                border: InputBorder.none,
                contentPadding: SizeConfig.padding(
                  horizontal: 12,
                  vertical: compact ? 14 : 16,
                ),
              ),
            ),
          ),
          if (onMicTap != null) ...[
            IconButton(
              onPressed: micLoading ? null : onMicTap,
              tooltip: 'بحث بالصوت',
              icon: micLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: AppColors.lightGreen,
                      ),
                    )
                  : const Icon(
                      Icons.mic_none_rounded,
                      color: AppColors.textSecondary,
                    ),
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

class SearchLocationChip extends StatelessWidget {
  const SearchLocationChip({
    super.key,
    required this.title,
    required this.onTap,
    required this.onClear,
  });

  final String title;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: SizeConfig.padding(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.borderLight.withValues(alpha: 0.75),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.textSecondary),
              SizeConfig.hSpace(8),
              Text(
                title,
                style: TextStyle(
                  fontSize: SizeConfig.ts(13),
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizeConfig.hSpace(8),
              const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
              if (onClear != null) ...[
                SizeConfig.hSpace(8),
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: onClear,
                  child: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
