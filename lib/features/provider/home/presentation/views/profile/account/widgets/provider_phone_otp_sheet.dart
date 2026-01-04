// lib/features/provider/home/presentation/views/profile/account/widgets/provider_phone_otp_sheet.dart
import 'dart:async';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProviderPhoneOtpSheet extends StatefulWidget {
  final String phone;

  /// ترجع error أو null
  final Future<String?> Function() onResend;

  /// ترجع error أو null
  final Future<String?> Function(String otp) onVerify;

  const ProviderPhoneOtpSheet({
    super.key,
    required this.phone,
    required this.onResend,
    required this.onVerify,
  });

  @override
  State<ProviderPhoneOtpSheet> createState() => _ProviderPhoneOtpSheetState();
}

class _ProviderPhoneOtpSheetState extends State<ProviderPhoneOtpSheet> {
  final TextEditingController _otpC = TextEditingController();

  Timer? _timer;
  int _secondsLeft = 60;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpC.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 1) {
        _timer?.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
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

  Future<void> _handleResend() async {
    try {
      await _runWithLoading(() async {
        final err = await widget.onResend();
        if (err != null) throw Exception(err);
      });

      if (!mounted) return;
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إعادة إرسال الرمز')),
      );
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

  Future<void> _handleVerify() async {
    final code = _otpC.text.trim();

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل رمز مكوّن من 6 أرقام')),
      );
      return;
    }

    try {
      await _runWithLoading(() async {
        final err = await widget.onVerify(code);
        if (err != null) throw Exception(err);
      });

      if (!mounted) return;
      Navigator.pop(context, true); // ✅ success
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
    final canResend = _secondsLeft == 0;

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
                'أدخل رمز التحقق',
                style: AppTextStyles.body16.copyWith(
                  fontSize: SizeConfig.ts(16),
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              SizeConfig.v(6),
              Text(
                'تم إرسال رمز إلى: ${widget.phone}',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption11.copyWith(
                  fontSize: SizeConfig.ts(12),
                  color: AppColors.textSecondary,
                ),
              ),
              SizeConfig.v(12),

              TextField(
                controller: _otpC,
                autofocus: true,
                maxLength: 6,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '123456',
                  hintStyle: AppTextStyles.body14.copyWith(
                    fontSize: SizeConfig.ts(14),
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

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: (!_loading && canResend) ? _handleResend : null,
                  child: Text(
                    canResend
                        ? 'إعادة إرسال الرمز'
                        : 'إعادة الإرسال خلال $_secondsLeft ث',
                    style: AppTextStyles.body14.copyWith(
                      color: canResend
                          ? AppColors.lightGreen
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

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
                  onPressed: _loading ? null : _handleVerify,
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
                          'تأكيد',
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
