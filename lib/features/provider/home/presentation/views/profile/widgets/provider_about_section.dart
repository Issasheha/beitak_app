// lib/features/provider/home/presentation/views/profile/widgets/provider_about_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/viewmodels/provider_profile_controller.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/viewmodels/provider_profile_state.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/widgets/provider_profile_section_card.dart';

class ProviderAboutSection extends ConsumerWidget {
  final ProviderProfileState state;
  final ProviderProfileController controller;

  const ProviderAboutSection({
    super.key,
    required this.state,
    required this.controller,
  });

  static const int _maxAboutLength = 300; // عدّلها لو السيرفر عنده رقم مختلف

  String _sanitize(String input) {
    final noHtml = input.replaceAll(RegExp(r'<[^>]*>'), '');
    return noHtml.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderProfileSectionCard(
      title: 'النبذة',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            state.bio.trim().isEmpty ? '—' : state.bio.trim(),
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(13.6),
              color: AppColors.textPrimary,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizeConfig.v(10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => _openEditSheet(context),
              child: Text(
                'تعديل النبذة',
                style: AppTextStyles.body14.copyWith(
                  fontSize: SizeConfig.ts(13),
                  color: AppColors.lightGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openEditSheet(BuildContext context) {
    final ctrl = TextEditingController(text: state.bio == '—' ? '' : state.bio);
    final error = ValueNotifier<String?>(null);
    final counter = ValueNotifier<int>(_sanitize(ctrl.text).length);

    void validateNow() {
      final sanitized = _sanitize(ctrl.text);
      counter.value = sanitized.length;
      error.value = sanitized.length > _maxAboutLength ? 'النص طويل جداً.' : null;
    }

    ctrl.addListener(validateNow);
    validateNow();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(SizeConfig.radius(22))),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: SizeConfig.w(16),
            right: SizeConfig.w(16),
            top: SizeConfig.h(14),
            bottom: MediaQuery.of(context).viewInsets.bottom + SizeConfig.h(14),
          ),
          child: ValueListenableBuilder<String?>(
            valueListenable: error,
            builder: (context, err, __) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'تعديل النبذة',
                          style: AppTextStyles.body16.copyWith(
                            fontSize: SizeConfig.ts(16),
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  TextField(
                    controller: ctrl,
                    autofocus: true,
                    maxLines: 5,
                    minLines: 3,
                    decoration: InputDecoration(
                      hintText: 'اكتب نبذة قصيرة عن خدماتك...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                        borderSide: const BorderSide(color: AppColors.lightGreen, width: 1.6),
                      ),
                    ),
                  ),
                  SizeConfig.v(8),
                  Row(
                    children: [
                      Expanded(
                        child: err == null
                            ? const SizedBox.shrink()
                            : Text(
                                err,
                                style: AppTextStyles.caption11.copyWith(
                                  fontSize: SizeConfig.ts(12),
                                  color: Colors.red,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                      ValueListenableBuilder<int>(
                        valueListenable: counter,
                        builder: (_, n, __) {
                          final over = n > _maxAboutLength;
                          return Text(
                            '$n/$_maxAboutLength',
                            style: AppTextStyles.caption11.copyWith(
                              fontSize: SizeConfig.ts(12),
                              color: over ? Colors.red : AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizeConfig.v(12),
                  ElevatedButton(
                    onPressed: err != null
                        ? null
                        : () async {
                            final sanitized = _sanitize(ctrl.text);
                            if (sanitized.length > _maxAboutLength) return;
                            await controller.updateBio(sanitized);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم تحديث النبذة بنجاح')),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                      ),
                      padding: SizeConfig.padding(vertical: 12),
                    ),
                    child: Text(
                      'حفظ',
                      style: AppTextStyles.body14.copyWith(
                        fontSize: SizeConfig.ts(14),
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
