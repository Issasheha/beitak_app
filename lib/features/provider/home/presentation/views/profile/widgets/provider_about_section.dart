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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expLabel =
        state.experienceYears > 0 ? '${state.experienceYears} سنة' : '—';

    return ProviderProfileSectionCard(
      title: 'نبذة عنك',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // actions row (styled chips)
          Row(
            children: [
              Expanded(
                child: _ActionChip(
                  icon: Icons.edit,
                  label: 'تعديل النبذة',
                  onTap: () => _openEditBioSheet(context),
                ),
              ),
              SizeConfig.hSpace(10),
              Expanded(
                child: _ActionChip(
                  icon: Icons.badge_outlined,
                  label: 'الخبرة: $expLabel',
                  onTap: () => _openEditExperienceSheet(context),
                ),
              ),
            ],
          ),

          SizeConfig.v(10),
          Divider(color: AppColors.borderLight.withValues(alpha: 0.9)),
          SizeConfig.v(10),

          // bio
          Text(
            state.bio,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(13.5),
              color: AppColors.textPrimary,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== Bottom Sheets =====================

  void _openEditBioSheet(BuildContext context) {
    final c = TextEditingController(text: state.bio == '—' ? '' : state.bio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(SizeConfig.radius(22))),
      ),
      builder: (sheetCtx) {
        final bottomInset = MediaQuery.viewInsetsOf(sheetCtx).bottom;

        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: SizeConfig.w(16),
              right: SizeConfig.w(16),
              top: SizeConfig.h(14),
              bottom: bottomInset + SizeConfig.h(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: SizeConfig.w(48),
                  height: SizeConfig.h(5),
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                SizeConfig.v(14),
                Text(
                  'تعديل النبذة',
                  style: AppTextStyles.body16.copyWith(
                    fontSize: SizeConfig.ts(16),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizeConfig.v(12),

                // ✅ autoFocus + keyboard safe
                TextField(
                  controller: c,
                  autofocus: true,
                  maxLines: 6,
                  minLines: 4,
                  textInputAction: TextInputAction.newline,
                  style: AppTextStyles.body14.copyWith(
                    fontSize: SizeConfig.ts(13.5),
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'اكتب نبذة قصيرة عن خدماتك...',
                    hintStyle: AppTextStyles.body14.copyWith(
                      fontSize: SizeConfig.ts(13),
                      color: AppColors.textSecondary.withValues(alpha: 0.65),
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                      borderSide: BorderSide(
                        color: AppColors.borderLight.withValues(alpha: 0.7),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                      borderSide: const BorderSide(color: AppColors.lightGreen),
                    ),
                  ),
                ),

                SizeConfig.v(12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightGreen,
                      foregroundColor: Colors.white,
                      padding: SizeConfig.padding(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(SizeConfig.radius(14)),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(sheetCtx);

                      try {
                        await controller.updateBio(c.text);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم حفظ النبذة بنجاح')),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString().replaceFirst('Exception: ', ''),
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'حفظ',
                      style: AppTextStyles.body14.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizeConfig.v(6),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openEditExperienceSheet(BuildContext context) {
    final c = TextEditingController(
      text: state.experienceYears > 0 ? state.experienceYears.toString() : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(SizeConfig.radius(22))),
      ),
      builder: (sheetCtx) {
        final bottomInset = MediaQuery.viewInsetsOf(sheetCtx).bottom;

        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: SizeConfig.w(16),
              right: SizeConfig.w(16),
              top: SizeConfig.h(14),
              bottom: bottomInset + SizeConfig.h(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: SizeConfig.w(48),
                  height: SizeConfig.h(5),
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                SizeConfig.v(14),
                Text(
                  'تعديل سنوات الخبرة',
                  style: AppTextStyles.body16.copyWith(
                    fontSize: SizeConfig.ts(16),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizeConfig.v(12),

                // ✅ autoFocus
                TextField(
                  controller: c,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  style: AppTextStyles.body14.copyWith(
                    fontSize: SizeConfig.ts(14),
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'مثال: 7',
                    hintStyle: AppTextStyles.body14.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.65),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                      borderSide: BorderSide(
                        color: AppColors.borderLight.withValues(alpha: 0.7),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                      borderSide: const BorderSide(color: AppColors.lightGreen),
                    ),
                  ),
                ),

                SizeConfig.v(12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightGreen,
                      foregroundColor: Colors.white,
                      padding: SizeConfig.padding(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(SizeConfig.radius(14)),
                      ),
                    ),
                    onPressed: () async {
                      final parsed = int.tryParse(c.text.trim()) ?? 0;
                      Navigator.pop(sheetCtx);

                      try {
                        await controller.updateExperienceYears(parsed);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم حفظ سنوات الخبرة بنجاح'),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString().replaceFirst('Exception: ', ''),
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'حفظ',
                      style: AppTextStyles.body14.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizeConfig.v(6),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lightGreen.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        onTap: onTap,
        child: Padding(
          padding: SizeConfig.padding(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.lightGreen),
              SizeConfig.hSpace(8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body14.copyWith(
                    fontSize: SizeConfig.ts(13),
                    color: AppColors.lightGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
