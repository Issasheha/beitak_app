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
    final isCompact = MediaQuery.of(context).size.height < 720;

    // تحكم أفضل بالفراغات حسب ارتفاع الهيدر
    final topTextGap = isCompact ? SizeConfig.h(22) : SizeConfig.h(28);
    final textToSearchGap = isCompact ? SizeConfig.h(16) : SizeConfig.h(18);

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // خلفية الهيدر بدون shadow (حتى ما يطلع خط)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(SizeConfig.radius(28)),
                bottomRight: Radius.circular(SizeConfig.radius(28)),
              ),
              child: Container(color: AppColors.lightGreen),
            ),
          ),

          // دوائر داخلية خفيفة (مثل الصورة)
          const Positioned(
            left: -135,
            top: -105,
            child: _SoftBlob(size: 280, opacity: 0.12),
          ),

          // قوس/نص دائرة أسفل يمين (بدون ما يوصل للبروفايل)
          const Positioned(
            right: -120,
            bottom: -190,
            child: ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: 0.58, // يظهر "قوس"
                child: _SoftBlob(size: 320, opacity: 0.12),
              ),
            ),
          ),

          // نقطة خفيفة وسط يسار مثل الصورة
          const Positioned(
            left: 44,
            bottom: 92,
            child: _SoftBlob(size: 74, opacity: 0.08),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: SizeConfig.padding(horizontal: 18, vertical: isCompact ? 12 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // RTL: أول عنصر يمين، آخر عنصر يسار
                  Row(
                    children: [
                      _ProfileChip(name: displayName, onTap: onProfileTap),
                      const Spacer(),

                      // جرس أكبر شوي (مرتب)
                      IconButton(
                        onPressed: onNotificationsTap,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: SizeConfig.w(26),
                        ),
                      ),
                      SizedBox(width: SizeConfig.w(8)),

                      // شعار أكبر
                      SvgPicture.asset(
                        'assets/images/Baitak white.svg',
                        height: SizeConfig.h(30),
                        fit: BoxFit.fill,
                      ),
                    ],
                  ),

                  SizedBox(height: topTextGap),

                  // نصوص الهيدر
                  Column(
                    children: [
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
                      SizedBox(height: SizeConfig.h(15)),
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
                    ],
                  ),

                  const SizedBox(height: 75),

                  // شريط البحث (مرفوع للأعلى)
                  _HeaderSearchBar(onTap: onSearchTap),

                  // نخلي باقي الفراغ تحت (بدون ما يبعد كثير)
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
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
              Icon(Icons.search_rounded, color: const Color(0xFF8A8A8A), size: SizeConfig.w(20)),
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
                child: Icon(Icons.mic_none_rounded, color: AppColors.lightGreen, size: SizeConfig.w(18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({required this.name, required this.onTap});
  final String name;
  final VoidCallback onTap;

  String _initials(String s) {
    final parts = s.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'ض';
    return parts.first.characters.isNotEmpty ? parts.first.characters.first : 'ض';
  }

  @override
  Widget build(BuildContext context) {
    final initial = _initials(name);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SizeConfig.radius(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: SizeConfig.w(38),
            height: SizeConfig.w(38),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4B58FF),
              border: Border.all(color: Colors.white.o(0.25)),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: TextStyle(
                fontSize: SizeConfig.ts(12.5),
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          SizeConfig.hSpace(10),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: SizeConfig.w(170)),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: SizeConfig.ts(13),
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
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
