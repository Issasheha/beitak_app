import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/constants/color_x.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/provider/home/presentation/widgets/provider_green_header.dart';

import 'package:beitak_app/core/utils/app_text_styles.dart';

class ProviderHeaderStatsRow extends StatelessWidget {
  const ProviderHeaderStatsRow({
    super.key,
    required this.stats,
    required this.compact,
  });

  final List<ProviderHeaderStat> stats;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, c) {
        final count = stats.length;
        final maxW = c.maxWidth;

        // ✅ spacing مرن عشان ما يضغط البطاقات جداً بالشاشات الضيقة
        final spacing = (maxW * 0.03).clamp(6.0, 12.0);

        final totalSpacing = spacing * (count - 1);
        var cardW = (maxW - totalSpacing) / count;

        // ✅ خلي الحد الأدنى أهدى (بدل 96) لأنك وصلت لـ 78 فعلاً
        cardW = cardW.clamp(SizeConfig.w(76), SizeConfig.w(150));

        // ✅ ارتفاع البطاقة “مقترح” لكن رح ينضغط تلقائياً حسب مساحة الهيدر
        final cardH = compact ? SizeConfig.h(78) : SizeConfig.h(90);

        return Row(
          textDirection: TextDirection.rtl,
          children: List.generate(count, (i) {
            final isLast = i == count - 1;
            return Padding(
              padding: EdgeInsets.only(left: isLast ? 0 : spacing),
              child: SizedBox(
                width: cardW,
                height: cardH,
                child: ProviderHeaderStatCard(
                  stat: stats[i],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class ProviderHeaderStatCard extends StatelessWidget {
  const ProviderHeaderStatCard({
    super.key,
    required this.stat,
  });

  final ProviderHeaderStat stat;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxHeight;
        final w = c.maxWidth;

        // ✅ tiny mode للقياسات الشديدة (مثل 65px height)
        final tiny = h < 70 || w < 86;

        // padding مرن حسب الارتفاع
        final padV =
            (h * 0.14).clamp(tiny ? 6.0 : 8.0, tiny ? 8.0 : 12.0);
        final padH = (w * 0.12).clamp(8.0, 12.0);

        // sizes مرنة حسب الارتفاع (تمنع overflow)
        final emojiSize = (h * 0.22).clamp(12.0, 18.0);
        final valueSize = (h * 0.20).clamp(11.0, 14.5);
        final titleSize = (h * 0.16).clamp(9.5, 12.0);

        // gaps مرنة
        final gap1 = (h * 0.10).clamp(3.0, 7.0);
        final gap2 = (h * 0.08).clamp(2.0, 6.0);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.o(0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stat.emoji,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title18.copyWith(
                    fontSize: emojiSize,
                    height: 1.0,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: gap1),
                Text(
                  stat.value,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title18.copyWith(
                    fontSize: valueSize,
                    height: 1.0,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: gap2),
                Text(
                  stat.title,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body16.copyWith(
                    fontSize: titleSize,
                    height: 1.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
