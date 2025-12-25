// lib/features/provider/home/presentation/views/profile/account/widgets/provider_account_password_card.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/account/viewmodels/account_edit_state.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/account/widgets/account_field_label.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/account/widgets/account_password_input.dart';
import 'package:flutter/material.dart';

class ProviderAccountPasswordCard extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final AccountEditState state;

  final TextEditingController currentCtrl;
  final TextEditingController newCtrl;
  final TextEditingController confirmCtrl;

  final Listenable listenable;
  final Future<void> Function() onSave;

  const ProviderAccountPasswordCard({
    super.key,
    required this.formKey,
    required this.state,
    required this.currentCtrl,
    required this.newCtrl,
    required this.confirmCtrl,
    required this.listenable,
    required this.onSave,
  });

  @override
  State<ProviderAccountPasswordCard> createState() =>
      _ProviderAccountPasswordCardState();
}

class _ProviderAccountPasswordCardState extends State<ProviderAccountPasswordCard> {
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  bool _isPasswordDirty() {
    return widget.currentCtrl.text.trim().isNotEmpty ||
        widget.newCtrl.text.trim().isNotEmpty ||
        widget.confirmCtrl.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.listenable,
      builder: (_, __) {
        final isPasswordDirty = _isPasswordDirty();

        return Form(
          key: widget.formKey,
          child: Container(
            padding: SizeConfig.padding(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
              border: Border.all(
                color: AppColors.lightGreen.withValues(alpha: 0.7),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'تغيير كلمة المرور',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.body14.copyWith(
                    fontSize: SizeConfig.ts(14.5),
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizeConfig.v(12),

                const AccountFieldLabel(text: 'كلمة المرور الحالية', requiredStar: false),
                SizeConfig.v(6),
                AccountPasswordInput(
                  controller: widget.currentCtrl,
                  hint: 'أدخل كلمة المرور الحالية',
                  obscure: !_showCurrent,
                  onToggleVisibility: () =>
                      setState(() => _showCurrent = !_showCurrent),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return 'كلمة المرور الحالية مطلوبة';
                    return null;
                  },
                ),
                SizeConfig.v(12),

                const AccountFieldLabel(text: 'كلمة المرور الجديدة', requiredStar: false),
                SizeConfig.v(6),
                AccountPasswordInput(
                  controller: widget.newCtrl,
                  hint: 'أدخل كلمة المرور الجديدة',
                  obscure: !_showNew,
                  onToggleVisibility: () => setState(() => _showNew = !_showNew),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return 'كلمة المرور الجديدة مطلوبة';
                    if (s.length < 8) return 'يجب أن تحتوي على 8 أحرف على الأقل';
                    return null;
                  },
                ),
                SizeConfig.v(4),
                Text(
                  'يجب أن تحتوي على 8 أحرف على الأقل',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.caption11.copyWith(
                    fontSize: SizeConfig.ts(11.5),
                    color: AppColors.textSecondary,
                  ),
                ),
                SizeConfig.v(12),

                const AccountFieldLabel(text: 'تأكيد كلمة المرور', requiredStar: false),
                SizeConfig.v(6),
                AccountPasswordInput(
                  controller: widget.confirmCtrl,
                  hint: 'أعد إدخال كلمة المرور الجديدة',
                  obscure: !_showConfirm,
                  onToggleVisibility: () =>
                      setState(() => _showConfirm = !_showConfirm),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return 'تأكيد كلمة المرور مطلوب';
                    if (s != widget.newCtrl.text.trim()) {
                      return 'كلمتا المرور غير متطابقتين';
                    }
                    return null;
                  },
                ),

                SizeConfig.v(16),

                SizedBox(
                  height: SizeConfig.h(46),
                  child: ElevatedButton(
                    onPressed: (widget.state.isChangingPassword || !isPasswordDirty)
                        ? null
                        : () async => widget.onSave(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textPrimary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.textPrimary.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
                      ),
                    ),
                    child: widget.state.isChangingPassword
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'تحديث كلمة المرور',
                            style: AppTextStyles.body14.copyWith(
                              fontSize: SizeConfig.ts(14),
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
