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

  /// ✅ إذا موجود => البطاقة تصير كليكابل وتعمل فتح/تنقل
  final VoidCallback? onTap;

  const ProviderHeaderStat({
    required this.title,
    required this.value,
    required this.emoji,
    this.onTap,
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
    final topPad = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // الخلفية الخضراء
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

          // زخرفة بسيطة
          Positioned(right: -120, top: -140, child: _blob(260, Colors.white.o(0.10))),
          Positioned(left: -140, top: -120, child: _blob(220, Colors.white.o(0.08))),
          Positioned(right: -90, bottom: -110, child: _blob(220, Colors.white.o(0.07))),

          // المحتوى
          LayoutBuilder(
            builder: (context, c) {
              final available = c.maxHeight;

              // compact للهواتف/الشاشات القصيرة (يمنع overflow)
              final compact = available < SizeConfig.h(260);

              final gap1 = (available * 0.04).clamp(6.0, 14.0);
              final gap2 = (available * 0.03).clamp(6.0, 12.0);

              return Padding(
                padding: EdgeInsets.only(
                  top: topPad + (compact ? 8 : 12),
                  left: 16,
                  right: 16,
                  bottom: compact ? 10 : 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TopBar(
                      onProfileTap: onProfileTap,
                      onNotificationsTap: onNotificationsTap,
                    ),
                    SizedBox(height: gap1),

                    // الترحيب
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'أهلاً بك من جديد يا $providerName',
                          maxLines: compact ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: SizeConfig.ts(compact ? 15 : 16.5),
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: gap2),

                    ProviderHeaderStatsRow(
                      stats: stats,
                      compact: compact,
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
  const _TopBar({
    required this.onProfileTap,
    required this.onNotificationsTap,
  });

  final VoidCallback onProfileTap;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
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
