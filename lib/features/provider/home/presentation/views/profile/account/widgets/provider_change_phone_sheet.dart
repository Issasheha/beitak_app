// lib/features/provider/home/presentation/views/profile/account/widgets/provider_change_phone_sheet.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/profile/account/widgets/account_phone_utils.dart';
import 'package:flutter/material.dart';

class ProviderChangePhoneSheet extends StatefulWidget {
  final String currentPhone;

  /// ترجع error string أو null
  final Future<String?> Function(String phone) onRequestOtp;

  const ProviderChangePhoneSheet({
    super.key,
    required this.currentPhone,
    required this.onRequestOtp,
  });

  @override
  State<ProviderChangePhoneSheet> createState() =>
      _ProviderChangePhoneSheetState();
}

class _ProviderChangePhoneSheetState extends State<ProviderChangePhoneSheet> {
  late final TextEditingController _phoneC;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _phoneC = TextEditingController(text: widget.currentPhone);
  }

  @override
  void dispose() {
    _phoneC.dispose();
    super.dispose();
  }

  Future<void> _runWithLoading(Future<void> Function() action) async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleSubmit() async {
    final raw = _phoneC.text.trim();
    final normalized = AccountPhoneUtils.normalizeJordanPhone(raw);

    if (normalized == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'رقم غير صحيح. لازم يكون أردني ويبدأ 077/078/079',
          ),
        ),
      );
      return;
    }

    final currentNormalized =
        AccountPhoneUtils.normalizeJordanPhone(widget.currentPhone) ??
            widget.currentPhone.trim().replaceAll(' ', '');

    if (normalized == currentNormalized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرقم الجديد نفس الرقم الحالي'),
        ),
      );
      return;
    }

    try {
      await _runWithLoading(() async {
        final err = await widget.onRequestOtp(normalized);
        if (err != null) {
          throw Exception(err);
        }
      });

      if (!mounted) return;
      // ✅ رجّع الرقم للـView
      Navigator.pop(context, normalized);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', '').trim(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 120),
        padding: EdgeInsets.only(
          left: SizeConfig.w(16),
          right: SizeConfig.w(16),
          top: SizeConfig.h(14),
          bottom: MediaQuery.of(context).viewInsets.bottom + SizeConfig.h(14),
        ),
        child: SingleChildScrollView(
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
                'تغيير رقم الهاتف',
                style: AppTextStyles.body16.copyWith(
                  fontSize: SizeConfig.ts(16),
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              SizeConfig.v(10),
              TextField(
                controller: _phoneC,
                autofocus: true,
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'مثال: 0771234567 أو 962771234567',
                  hintStyle: AppTextStyles.body14.copyWith(
                    fontSize: SizeConfig.ts(13),
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      SizeConfig.padding(horizontal: 14, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
                    borderSide: BorderSide(
                      color: AppColors.borderLight.withValues(alpha: 0.8),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
                    borderSide: const BorderSide(
                      color: AppColors.lightGreen,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
              SizeConfig.v(10),
              SizedBox(
                width: double.infinity,
                height: SizeConfig.h(46),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
                    ),
                  ),
                  onPressed: _loading ? null : _handleSubmit,
                  child: _loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'إرسال رمز التحقق',
                          style: AppTextStyles.body14.copyWith(
                            fontSize: SizeConfig.ts(14),
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              SizeConfig.v(8),
            ],
          ),
        ),
      ),
    );
  }
}
