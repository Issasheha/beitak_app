import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/constants/color_x.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

// ✅ NEW: ترجمة الخدمة من key/slug إلى عربي ثابت
import 'package:beitak_app/core/constants/fixed_service_categories.dart';

class ProviderNewRequestCard extends StatefulWidget {
  const ProviderNewRequestCard({
    super.key,
    required this.serviceName,
    required this.customerName,
    required this.onTap,
  });

  final String serviceName;
  final String customerName;
  final VoidCallback onTap;

  @override
  State<ProviderNewRequestCard> createState() => _ProviderNewRequestCardState();
}

class _ProviderNewRequestCardState extends State<ProviderNewRequestCard> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  // ✅ NEW: ترجمة اسم الخدمة للعرض بالعربي (يدعم key/slug/English/Arabic variants)
  String _serviceNameAr(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return '—';

    // جرّب من أي سترينغ (key/slug/arabic label)
    final k = FixedServiceCategories.keyFromAnyString(s);
    if (k != null) return FixedServiceCategories.labelArFromKey(k);

    // لو السيرفر باعث name_ar أحياناً أو نص عربي عام
    // نخليه كما هو بدل ما نظهر English
    final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(s);
    if (hasArabic) return s;

    // fallback
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final r = SizeConfig.radius(18);

    // ✅ Border: واضح حتى بدون ضغط
    final borderColor =
        _pressed ? AppColors.lightGreen.o(0.65) : AppColors.lightGreen.o(0.28);

    final borderWidth = _pressed ? 1.6 : 1.2;

    // ✅ Subtle glow around card (clickable affordance)
    final glow = _pressed ? 0.18 : 0.10;

    // ✅ press feedback
    final double lift = _pressed ? 0 : 1.0;
    final double blur = _pressed ? 12 : 16;

    // ✅ translated label
    final serviceLabel = _serviceNameAr(widget.serviceName);

    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.h(8)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, lift, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(r),
          boxShadow: [
            // ✅ green glow (makes it feel tappable)
            BoxShadow(
              color: AppColors.lightGreen.o(glow),
              blurRadius: _pressed ? 18 : 14,
              offset: const Offset(0, 10),
            ),
            // ✅ normal shadow
            BoxShadow(
              color: Colors.black.o(_pressed ? 0.04 : 0.08),
              blurRadius: blur,
              offset: Offset(0, _pressed ? 6 : 12),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r),
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => _setPressed(true),
            onTapCancel: () => _setPressed(false),
            onTapUp: (_) => _setPressed(false),
            borderRadius: BorderRadius.circular(r),
            splashColor: AppColors.lightGreen.o(0.12),
            highlightColor: AppColors.lightGreen.o(0.08),
            child: Container(
              padding: SizeConfig.padding(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(r),
                border: Border.all(
                  color: borderColor,
                  width: borderWidth,
                ),
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    width: SizeConfig.w(54),
                    height: SizeConfig.w(54),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
                      color: AppColors.lightGreen.o(_pressed ? 0.18 : 0.12),
                      border: Border.all(
                        color: AppColors.lightGreen.o(_pressed ? 0.34 : 0.22),
                        width: _pressed ? 1.2 : 1.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '📩',
                      style: TextStyle(fontSize: SizeConfig.ts(22), height: 1),
                    ),
                  ),
                  SizedBox(width: SizeConfig.w(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceLabel, // ✅ بدل widget.serviceName
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: SizeConfig.ts(13.5),
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: SizeConfig.h(5)),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.customerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: SizeConfig.ts(12.2),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            SizedBox(width: SizeConfig.w(8)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.w(8),
                                vertical: SizeConfig.h(4),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightGreen.o(0.08),
                                borderRadius:
                                    BorderRadius.circular(SizeConfig.radius(12)),
                                border: Border.all(
                                  color: AppColors.lightGreen.o(0.22),
                                ),
                              ),
                              child: Text(
                                'اضغط للتفاصيل',
                                style: TextStyle(
                                  fontSize: SizeConfig.ts(10.8),
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: SizeConfig.w(12)),
                  Container(
                    width: SizeConfig.w(34),
                    height: SizeConfig.w(34),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen.o(_pressed ? 0.18 : 0.10),
                      borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
                      border: Border.all(
                        color: AppColors.lightGreen.o(_pressed ? 0.34 : 0.22),
                        width: _pressed ? 1.2 : 1.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: SizeConfig.ts(22),
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
