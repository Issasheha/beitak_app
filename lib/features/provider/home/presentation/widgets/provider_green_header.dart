import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/constants/color_x.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/provider/home/presentation/widgets/provider_header_stat_cards.dart';

@immutable
class ProviderHeaderStat {
  final String title;
  final String value;
  final String emoji;

  /// إذا موجود => البطاقة تصير كليكابل
  final VoidCallback? onTap;

  /// ✅ NEW: لو true نرسم Skeleton بدل النصوص
  final bool skeleton;

  const ProviderHeaderStat({
    required this.title,
    required this.value,
    required this.emoji,
    this.onTap,
    this.skeleton = false,
  });
}

class ProviderGreenHeader extends StatelessWidget {
  const ProviderGreenHeader({
    super.key,
    required this.height,
    required this.providerName,
    required this.onProfileTap,
    required this.onNotificationsTap,
    required this.stats,
  });

  final double height;
  final String providerName;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationsTap;
  final List<ProviderHeaderStat> stats;

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final topPad = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.lightGreen,
                    AppColors.lightGreen.o(0.92),
                  ],
                ),
              ),
            ),
          ),

          // blobs
          Positioned(right: -120, top: -140, child: _blob(260, Colors.white.o(0.10))),
          Positioned(left: -140, top: -120, child: _blob(220, Colors.white.o(0.08))),
          Positioned(right: -90, bottom: -110, child: _blob(220, Colors.white.o(0.07))),

          LayoutBuilder(
            builder: (context, c) {
              final headerH = c.maxHeight;

              // ✅ لو الهيدر صار صغير جدًا (landscape غالبًا)
              final superTiny = headerH < 140;
              final compact = headerH < SizeConfig.h(260);

              // padding أقل عند الصغر
              final padTop = topPad + (superTiny ? 4 : (compact ? 6 : 12));
final double padBottom = compact ? 10.0 : 12.0;

              // gaps أقل عند الصغر
              final gap1 = (headerH * (superTiny ? 0.02 : 0.035)).clamp(4.0, 12.0);
              final gap2 = (headerH * (superTiny ? 0.018 : 0.028)).clamp(4.0, 10.0);

              // ارتفاع الترحيب (مرن + آمن)
              final greetH = (headerH * (superTiny ? 0.26 : (compact ? 0.22 : 0.20)))
                  .clamp(superTiny ? 26.0 : 34.0, superTiny ? 40.0 : 56.0);

              // نقدر نحسب مساحة المحتوى داخل padding
              final innerH = headerH - padTop - padBottom;

              // TopBar تقريبًا 38px
              const topBarH = 38.0;

              // مساحة متبقية للـ stats
              final remainingForStats = innerH - topBarH - gap1 - greetH - gap2;

              // ✅ إذا المساحة قليلة: نخفي stats لتفادي overflow
              final showStats = !superTiny && remainingForStats >= 52;

              // ارتفاع stats المرغوب
              final desiredStatsH = compact ? SizeConfig.h(78) : SizeConfig.h(90);
              final statsH = showStats ? remainingForStats.clamp(52.0, desiredStatsH) : 0.0;

              return Padding(
                padding: EdgeInsets.only(
                  top: padTop,
                  left: 16,
                  right: 16,
                  bottom: padBottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: topBarH,
                      child: _TopBar(),
                    ),

                    SizedBox(height: gap1),

                    SizedBox(
                      height: greetH,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            'أهلاً بك من جديد يا $providerName',
                            textDirection: TextDirection.rtl,
                            maxLines: compact ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: SizeConfig.ts(superTiny ? 13.5 : (compact ? 15 : 16.5)),
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.15,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: gap2),

                    if (showStats)
                      SizedBox(
                        height: statsH,
                        child: ProviderHeaderStatsRow(
                          stats: stats,
                          compact: compact,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    // ✅ نخليها تاخد callbacks من أعلى عن طريق Inherited/Closure؟
    // بما إنك كنت تمرر callbacks سابقًا، الأفضل نخليها مثل ما كانت:
    // (بس عشان ما نكسر شي، رح نرجعها كنسخة تقبل callbacks عبر context)
    final parent = context.findAncestorWidgetOfExactType<ProviderGreenHeader>();
    final onProfileTap = parent?.onProfileTap;
    final onNotificationsTap = parent?.onNotificationsTap;

    return Row(
      textDirection: TextDirection.rtl,
      children: [
        InkWell(
          onTap: onProfileTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.o(0.18),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.o(0.25)),
            ),
            child: const Icon(Icons.person_outline, color: Colors.white),
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onNotificationsTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.o(0.18),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.o(0.25)),
            ),
            child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
