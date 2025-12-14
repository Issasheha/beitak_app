import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/constants/color_x.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeGreenHeader extends StatelessWidget {
  const HomeGreenHeader({
    super.key,
    required this.height,
    required this.displayName,
    required this.onProfileTap,
    required this.onNotificationsTap,
    required this.onSearchTap,
  });

  final double height;
  final String displayName;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isCompact = mq.size.height < 720;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // ✅ خلفية الهيدر (قصّ أسفل مثل الصورة)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(SizeConfig.radius(28)),
                bottomRight: Radius.circular(SizeConfig.radius(28)),
              ),
              child: Container(color: AppColors.lightGreen),
            ),
          ),

          // ✅ Blobs خفيفة مثل الصورة
          const Positioned(
            left: -135,
            top: -105,
            child: _SoftBlob(size: 280, opacity: 0.12),
          ),
          const Positioned(
            right: -120,
            bottom: -190,
            child: ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: 0.58,
                child: _SoftBlob(size: 320, opacity: 0.12),
              ),
            ),
          ),
          const Positioned(
            left: 44,
            bottom: 92,
            child: _SoftBlob(size: 74, opacity: 0.08),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: SizeConfig.padding(
                horizontal: 18,
                vertical: isCompact ? 12 : 14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ✅ Top row: (يمين: شعار) (يسار: بروفايل + جرس)
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      SvgPicture.asset(
                        'assets/images/Baitak white.svg',
                        height: SizeConfig.h(30),
                        fit: BoxFit.contain,
                      ),
                      const Spacer(),
                      _HeaderIconBtn(
                        icon: Icons.person_outline_rounded,
                        onTap: onProfileTap,
                      ),
                      SizedBox(width: SizeConfig.w(10)),
                      _HeaderIconBtn(
                        icon: Icons.notifications_none_rounded,
                        onTap: onNotificationsTap,
                      ),
                    ],
                  ),

                  SizedBox(height: SizeConfig.h(14)),

                  // ✅ Name row (مثل الصورة: الاسم يمين + دائرة الحرف)
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: onProfileTap,
                      borderRadius: BorderRadius.circular(SizeConfig.radius(999)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.w(4),
                          vertical: SizeConfig.h(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          textDirection: TextDirection.rtl,
                          children: [
                            Container(
                              width: SizeConfig.w(46),
                              height: SizeConfig.w(46),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF4B58FF),
                                border: Border.all(color: Colors.white.o(0.25)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _initials(displayName),
                                style: TextStyle(
                                  fontSize: SizeConfig.ts(13),
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1.0,
                                ),
                              ),
                            ),
                            SizedBox(width: SizeConfig.w(10)),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: SizeConfig.w(220)),
                              child: Text(
                                displayName.trim().isEmpty ? 'ضيف' : displayName.trim(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: SizeConfig.ts(16),
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ✅ الجزء المرن لمنع overflow
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, c) {
                        // رفع البحث للأعلى بشكل مرن حسب المساحة
                        final lift = (c.maxHeight * 0.22).clamp(40.0, 78.0);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: isCompact ? SizeConfig.h(14) : SizeConfig.h(18)),
                            Text(
                              'مكانك الموثوق للخدمات المنزلية',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: SizeConfig.ts(16.5),
                                fontWeight: FontWeight.w900,
                                color: Colors.white.o(0.96),
                                height: 1.15,
                              ),
                            ),
                            SizedBox(height: SizeConfig.h(14)),
                            Text(
                              'محترفون موثوقون ومعتمدون دون عناء البحث.',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: SizeConfig.ts(11.8),
                                fontWeight: FontWeight.w600,
                                color: Colors.white.o(0.90),
                                height: 1.2,
                              ),
                            ),

                            const Spacer(),

                            Padding(
                              padding: EdgeInsets.only(bottom: lift),
                              child: _HeaderSearchBar(onTap: onSearchTap),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String s) {
    final parts = s.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'ض';
    final first = parts.first;
    if (first.characters.isEmpty) return 'ض';
    return first.characters.first;
  }
}

class _HeaderIconBtn extends StatelessWidget {
  const _HeaderIconBtn({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: SizeConfig.w(40),
        height: SizeConfig.w(40),
        decoration: BoxDecoration(
          color: Colors.white.o(0.18),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.o(0.25)),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: Colors.white,
          size: SizeConfig.w(24),
        ),
      ),
    );
  }
}

class _HeaderSearchBar extends StatelessWidget {
  const _HeaderSearchBar({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.height < 720;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SizeConfig.radius(22)),
        child: Container(
          padding: SizeConfig.padding(horizontal: 14, vertical: isCompact ? 12 : 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(SizeConfig.radius(22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.o(0.14),
                blurRadius: 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: const Color(0xFF8A8A8A),
                size: SizeConfig.w(20),
              ),
              SizeConfig.hSpace(10),
              Expanded(
                child: Text(
                  'شو بدك تصلّح اليوم؟',
                  style: TextStyle(
                    color: const Color(0xFF8A8A8A),
                    fontWeight: FontWeight.w700,
                    fontSize: SizeConfig.ts(12.5),
                  ),
                ),
              ),
              Container(
                width: SizeConfig.w(38),
                height: SizeConfig.w(38),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightGreen.o(0.14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.mic_none_rounded,
                  color: AppColors.lightGreen,
                  size: SizeConfig.w(18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftBlob extends StatelessWidget {
  const _SoftBlob({required this.size, required this.opacity});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.o(opacity),
      ),
    );
  }
}
