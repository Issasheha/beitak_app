import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  /// keys:
  /// title (String), rating (num), price (num), provider (String?) فقط للأحرف
  final Map<String, dynamic> service;
  final VoidCallback onTap;

  String _s(dynamic v) => (v ?? '').toString().trim();

  double _d(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  String _initials(String name) {
    final cleaned = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty) return '—';
    final parts = cleaned.split(' ').where((e) => e.isNotEmpty).toList();
    String firstChar(String s) => s.characters.isEmpty ? '' : s.characters.first;
    if (parts.length >= 2) {
      final out = (firstChar(parts[0]) + firstChar(parts[1])).toUpperCase();
      return out.isEmpty ? '—' : out;
    }
    final chars = parts.first.characters.toList();
    if (chars.isEmpty) return '—';
    if (chars.length == 1) return chars.first.toUpperCase();
    return (chars[0] + chars[1]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final title = _s(service['title']);
    final provider = _s(service['provider']);
    final rating = _d(service['rating']);
    final price = _d(service['price']);
    final initials = _initials(provider.isEmpty ? title : provider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final isTight = cardWidth < 190; // ✅ أضيق شوي (Grid cards)
        final pad = isTight ? 10.0 : 12.0;

        // ✅ أحجام مرنة بدون ما نسبب overflow
        final titleFont = isTight ? SizeConfig.ts(14) : SizeConfig.ts(15);
        final chipFont = isTight ? 12.0 : 13.0;
        final buttonFont = isTight ? 12.5 : 13.5;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderLight),
              ),
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ✅ Top row: بدون Wrap عشان ما يزيد height بشكل مفاجئ
                  Row(
                    children: [
                      Expanded(
                        child: _PriceChip(
                          price: price,
                          fontSize: chipFont,
                          isTight: isTight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _RatingChip(
                        rating: rating,
                        fontSize: chipFont,
                        isTight: isTight,
                      ),
                      const SizedBox(width: 8),
                      _InitialsAvatar(
                        initials: initials,
                        size: isTight ? 36 : 40,
                      ),
                    ],
                  ),

                  SizedBox(height: SizeConfig.h(10)),

                  // ✅ Title: مرن + عربيات أحسن
                  Expanded(
                    child: Center(
                      child: Text(
                        title.isEmpty ? 'خدمة' : title,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        strutStyle: StrutStyle(
                          fontSize: titleFont,
                          height: 1.18,
                          forceStrutHeight: true,
                        ),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: titleFont,
                          fontWeight: FontWeight.w900,
                          height: 1.18,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: SizeConfig.h(10)),

                  // ✅ زر ثابت الارتفاع بدل AspectRatio (يحل overflow كثير)
                  SizedBox(
                    height: isTight ? 38 : 42,
                    child: OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(color: AppColors.lightGreen.withValues(alpha: 0.35),),
                        backgroundColor: AppColors.lightGreen.withValues(alpha: 0.88),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              'عرض التفاصيل',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: buttonFont,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // ✅ RTL: سهم للداخل (عادةً لليسار)
                          Icon(
                            Icons.chevron_left,
                            size: isTight ? 18 : 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({
    required this.initials,
    required this.size,
  });

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.lightGreen.withValues(alpha: 0.18),
        border: Border.all(color: AppColors.lightGreen.withValues(alpha: 0.45),),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w900,
          fontSize: size <= 36 ? 12 : 13.5,
        ),
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  const _PriceChip({
    required this.price,
    required this.fontSize,
    required this.isTight,
  });

  final double price;
  final double fontSize;
  final bool isTight;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTight ? 10 : 12,
          vertical: isTight ? 6 : 7,
        ),
        decoration: BoxDecoration(
          color: AppColors.lightGreen.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.lightGreen.withValues(alpha: 0.35),),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'د.أ ${price.toStringAsFixed(0)}',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: fontSize,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({
    required this.rating,
    required this.fontSize,
    required this.isTight,
  });

  final double rating;
  final double fontSize;
  final bool isTight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          size: isTight ? 18 : 20,
          color: AppColors.lightGreen,
        ),
        const SizedBox(width: 4),
        Text(
          rating <= 0 ? '—' : rating.toStringAsFixed(1),
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: fontSize,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
