import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class OtpVerifyDialog extends StatefulWidget {
  const OtpVerifyDialog({
    super.key,
    required this.phone,
    required this.onResend,
    required this.onVerify,
  });

  final String phone;
  final Future<void> Function() onResend;
  final Future<void> Function(String otp) onVerify;

  @override
  State<OtpVerifyDialog> createState() => _OtpVerifyDialogState();
}

class _OtpVerifyDialogState extends State<OtpVerifyDialog> {
  final _otpCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final otp = _otpCtrl.text.trim();

    if (otp.length < 4) {
      setState(() => _error = 'أدخل رمز صحيح');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.onVerify(otp);

      if (!mounted) return;
      // ✅ رجّع الـ OTP (مش bool)
      Navigator.of(context).pop(otp);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '').trim();
        if (_error!.isEmpty) _error = 'فشل التحقق من الرمز';
      });
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _handleResend() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.onResend();
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '').trim();
        if (_error!.isEmpty) _error = 'فشل إعادة الإرسال';
      });
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'تأكيد رقم الهاتف',
          style: AppTextStyles.cardTitle.copyWith(
            fontSize: SizeConfig.ts(14),
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أدخل رمز التحقق المرسل إلى:',
              style: AppTextStyles.helper.copyWith(
                fontSize: SizeConfig.ts(12),
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: SizeConfig.h(6)),
            Text(
              widget.phone,
              style: AppTextStyles.semiBold.copyWith(
                fontSize: SizeConfig.ts(13),
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: SizeConfig.h(12)),
            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'مثال: 123456',
                errorText: _error,
                contentPadding: SizeConfig.padding(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
        actionsPadding: SizeConfig.padding(horizontal: 12, vertical: 10),
        actions: [
          TextButton(
            onPressed: _loading ? null : () => Navigator.of(context).pop(null),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontSize: SizeConfig.ts(12),
                fontWeight: FontWeight.w900,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: _loading ? null : _handleResend,
            child: Text(
              'إعادة إرسال',
              style: TextStyle(
                fontSize: SizeConfig.ts(12),
                fontWeight: FontWeight.w900,
                color: AppColors.lightGreen,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _loading ? null : _handleVerify,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: SizeConfig.padding(horizontal: 14, vertical: 10),
            ),
            child: Text(
              _loading ? 'جارٍ التحقق...' : 'تحقق',
              style: TextStyle(
                fontSize: SizeConfig.ts(12),
                fontWeight: FontWeight.w900,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
