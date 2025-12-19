import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
    this.onBookNow,
  });

  /// keys (اختياري/مقترح):
  /// title (String)
  /// category (String?)  -> مثال: "التنظيف"
  /// rating (num)
  /// price (num)
  /// provider (String?) -> للأحرف
  final Map<String, dynamic> service;
  final VoidCallback onTap;
  final VoidCallback? onBookNow;

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
    final category = _s(service['category']); // اختياري
    final provider = _s(service['provider']);
    final rating = _d(service['rating']);
    final price = _d(service['price']);
    final initials = _initials(provider.isEmpty ? title : provider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: EdgeInsets.all(SizeConfig.h(12)),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ===== Top row: text (right) + avatar (left) =====
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text area
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.isEmpty ? 'خدمة' : title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: SizeConfig.ts(16),
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            height: 1.15,
                          ),
                        ),
                        if (category.isNotEmpty) ...[
                          SizedBox(height: SizeConfig.h(4)),
                          Text(
                            category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: SizeConfig.ts(13),
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              height: 1.1,
                            ),
                          ),
                        ],
                        SizedBox(height: SizeConfig.h(8)),

                        // Price (left-ish) + Rating (right-ish) like screenshot
                        Row(
                          children: [
                            Text(
                              '${price.toStringAsFixed(0)} JD',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: SizeConfig.ts(14),
                                fontWeight: FontWeight.w900,
                                color: AppColors.lightGreen,
                                height: 1.0,
                              ),
                            ),
                            const Spacer(),
                            _RatingInline(rating: rating),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: SizeConfig.w(12)),

                  // Avatar (في RTL: وضعه آخر عنصر => يطلع على اليسار مثل الصورة)
                  _InitialsAvatar(initials: initials),
                ],
              ),

              SizedBox(height: SizeConfig.h(12)),

              // ===== Buttons row: (right) Book Now, (left) Details =====
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: SizeConfig.h(40),
                      child: ElevatedButton(
                        onPressed: onBookNow ?? onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'احجز الآن',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: SizeConfig.ts(13.5),
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: SizeConfig.w(10)),
                  Expanded(
                    child: SizedBox(
                      height: SizeConfig.h(40),
                      child: OutlinedButton(
                        onPressed: onTap,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.lightGreen,
                          side: BorderSide(
                            color: AppColors.lightGreen.withValues(alpha: 0.55),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                        child: Text(
                          'التفاصيل',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: SizeConfig.ts(13.5),
                            fontWeight: FontWeight.w900,
                            color: AppColors.lightGreen,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) {
    final size = SizeConfig.h(44);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.lightGreen.withValues(alpha: 0.18),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w900,
          fontSize: SizeConfig.ts(13),
        ),
      ),
    );
  }
}

class _RatingInline extends StatelessWidget {
  const _RatingInline({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    final text = rating <= 0 ? '—' : rating.toStringAsFixed(1);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          size: SizeConfig.h(18),
          color: Colors.amber, // مثل الصورة (ذهبي)
        ),
        SizedBox(width: SizeConfig.w(4)),
        Text(
          text,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: SizeConfig.ts(13.5),
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
