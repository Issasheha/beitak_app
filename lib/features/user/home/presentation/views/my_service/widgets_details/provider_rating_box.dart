import 'package:flutter/material.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

class ProviderRatingBox extends StatelessWidget {
  final int? rating; // 1..5
  final double? amountPaid;
  final String currency; // ignored now (we show د.أ)
  final String message; // provider_response
  final String? ratedAt; // provider_response_at (optional)

  const ProviderRatingBox({
    super.key,
    required this.rating,
    required this.amountPaid,
    required this.currency,
    required this.message,
    this.ratedAt,
  });

  bool get _hasAnyData {
    final rOk = (rating ?? 0) > 0;
    final aOk = (amountPaid ?? 0) > 0;
    final mOk = message.trim().isNotEmpty;
    return rOk || aOk || mOk;
  }

  String _toArabicDigits(String input) {
    const map = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };
    final b = StringBuffer();
    for (final ch in input.runes) {
      final c = String.fromCharCode(ch);
      b.write(map[c] ?? c);
    }
    return b.toString();
  }

  String _formatAmount(double v) {
    final isInt = v == v.roundToDouble();
    final s = v.toStringAsFixed(isInt ? 0 : 2);
    return _toArabicDigits(s);
  }

  /// ✅ 2025-12-26T15:28:29.000Z -> ٢٦/١٢/٢٠٢٥ ٣:٢٨ م
  String _formatRatedAt(String raw) {
    final r = raw.trim();
    if (r.isEmpty) return '';

    // لو أصلاً عربي ومترتب خلّيه
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(r) && !r.contains('T')) {
      return r;
    }

    DateTime? dt;

    // جرّب parse ISO
    try {
      dt = DateTime.parse(r).toLocal();
    } catch (_) {
      dt = null;
    }

    // fallback بسيط لو فشل
    if (dt == null) {
      // خذ أول 19 char تقريباً: yyyy-MM-ddTHH:mm:ss
      final cleaned = r.replaceAll('T', ' ');
      final cut = cleaned.length >= 19 ? cleaned.substring(0, 19) : cleaned;
      return _toArabicDigits(cut);
    }

    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();

    int h = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final isPm = h >= 12;
    final suffix = isPm ? 'م' : 'ص';
    int hour12 = h % 12;
    if (hour12 == 0) hour12 = 12;

    final datePart = _toArabicDigits('$dd/$mm/$yyyy');
    final timePart = _toArabicDigits('$hour12:$minute');
    return '$datePart $timePart $suffix';
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    // ✅ دائماً نعرضها د.أ (حسب طلبك)
    const currencyAr = 'د.أ';

    final ratedAtPretty =
        (ratedAt != null && ratedAt!.trim().isNotEmpty) ? _formatRatedAt(ratedAt!) : '';

    return Container(
      padding: SizeConfig.padding(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(
          color: AppColors.lightGreen.withValues(alpha: 0.22),
        ),
      ),
      child: !_hasAnyData
          ? Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                  size: SizeConfig.w(20),
                ),
                SizedBox(width: SizeConfig.w(10)),
                Expanded(
                  child: Text(
                    'لم يقم مزود الخدمة بإرسال تقييم بعد.',
                    style: TextStyle(
                      fontSize: SizeConfig.ts(13),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: SizeConfig.w(36),
                      height: SizeConfig.w(36),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.star_rounded,
                        color: AppColors.lightGreen,
                        size: SizeConfig.w(22),
                      ),
                    ),
                    SizedBox(width: SizeConfig.w(10)),
                    Expanded(
                      child: Text(
                        'تقييم مزود الخدمة',
                        style: TextStyle(
                          fontSize: SizeConfig.ts(14),
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.h(10)),

                if ((rating ?? 0) > 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final idx = i + 1;
                      final filled = idx <= (rating ?? 0);
                      return Icon(
                        filled ? Icons.star_rounded : Icons.star_border_rounded,
                        size: SizeConfig.ts(28),
                        color: filled ? const Color(0xFFFFC107) : AppColors.textSecondary,
                      );
                    }),
                  ),
                  SizedBox(height: SizeConfig.h(8)),
                  Center(
                    child: Text(
                      '${_toArabicDigits((rating ?? 0).toString())}/٥',
                      style: TextStyle(
                        fontSize: SizeConfig.ts(13),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],

                if ((amountPaid ?? 0) > 0) ...[
                  SizedBox(height: SizeConfig.h(10)),
                  _Line(
                    label: 'المبلغ المدفوع:',
                    // ✅ رقم + د.أ
                    value: '${_formatAmount(amountPaid!)} $currencyAr',
                  ),
                ],

                if (message.trim().isNotEmpty) ...[
                  SizedBox(height: SizeConfig.h(10)),
                  _Line(
                    label: 'رسالة المزود:',
                    value: message.trim(),
                    valueBold: false,
                  ),
                ],

                if (ratedAtPretty.isNotEmpty) ...[
                  SizedBox(height: SizeConfig.h(10)),
                  Text(
                    'تاريخ التقييم: $ratedAtPretty',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: SizeConfig.ts(11.5),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  final bool valueBold;

  const _Line({
    required this.label,
    required this.value,
    this.valueBold = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: SizeConfig.ts(13),
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: SizeConfig.ts(13),
              fontWeight: valueBold ? FontWeight.w900 : FontWeight.w700,
              color: AppColors.textSecondary,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}
