import 'package:flutter/material.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/constants/color_x.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

class AboutView extends StatelessWidget {
  const AboutView ({super.key});

  static const _heroAsset = 'assets/images/image_about.jpg';

  static const _services = <_ServiceTileData>[
    _ServiceTileData(emoji: '🧽', titleAr: 'سباكة', titleEn: 'Plumbing'),
    _ServiceTileData(emoji: '⚡', titleAr: 'كهرباء', titleEn: 'Electrical'),
    _ServiceTileData(emoji: '🛠️', titleAr: 'صيانة', titleEn: 'Maintenance'),
    _ServiceTileData(emoji: '🪛', titleAr: 'إصلاحات منزلية', titleEn: 'Home Repairs'),
  ];

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: _Header()),
            SliverToBoxAdapter(child: SizedBox(height: SizeConfig.h(14))),

            SliverPadding(
              padding: SizeConfig.padding(horizontal: 16),
              sliver: const  SliverToBoxAdapter(
                child: _VisionCard(
                  title: 'رؤيتنا',
                  text:
                      'أن نكون منصة خدمات المنزل الأكثر ثقة في الأردن، نُمكّن أصحاب المنازل من الوصول السهل للخدمات عالية الجودة، '
                      'ونمنح مقدمي الخدمات المحليين منصة لنمو أعمالهم.',
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: SizeConfig.h(14))),

            SliverPadding(
              padding: SizeConfig.padding(horizontal: 16),
              sliver: const  SliverToBoxAdapter(
                child: _HeroImageCard(assetPath: _heroAsset),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: SizeConfig.h(16))),

            SliverPadding(
              padding: SizeConfig.padding(horizontal: 22),
              sliver: SliverToBoxAdapter(
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen.o(0.30),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: SizeConfig.h(14))),

            SliverPadding(
              padding: SizeConfig.padding(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'خدماتنا',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.title18.copyWith(
                    fontSize: SizeConfig.ts(15.5),
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: SizeConfig.h(10))),

            SliverPadding(
              padding: SizeConfig.padding(horizontal: 16, vertical: 4),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _ServiceTile(data: _services[index]),
                  childCount: _services.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: SizeConfig.h(12),
                  crossAxisSpacing: SizeConfig.w(12),
                  childAspectRatio: 1.25,
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: SizeConfig.h(20))),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(
        top: topPad + SizeConfig.h(10),
        left: SizeConfig.w(16),
        right: SizeConfig.w(16),
        bottom: SizeConfig.h(16),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.lightGreen.o(0.18),
            Colors.white,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              Expanded(
                child: Text(
                  'حول بيتك',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headline22.copyWith(
                    fontSize: SizeConfig.ts(17),
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 48), // balance
            ],
          ),

          SizedBox(height: SizeConfig.h(10)),

          Text(
            'هي منصة رائدة في الأردن لخدمات المنازل. تربط بيتك مع مقدمي خدمات محترفين وموثوقين في جميع فئات الخدمات المنزلية، '
            'من الإصلاحات والصيانة إلى التنظيف. هدفنا أن نجعل الأمر أسهل عليك، وأكثر راحة، وبجودة تليق باحتياجاتك.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(12.6),
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _VisionCard extends StatelessWidget {
  final String title;
  final String text;

  const _VisionCard({
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.o(0.04),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: SizeConfig.w(46),
            height: SizeConfig.w(46),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lightGreen,
              boxShadow: [
                BoxShadow(
                  color: AppColors.lightGreen.o(0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.track_changes, color: Colors.white),
          ),
          SizedBox(height: SizeConfig.h(10)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.title18.copyWith(
              fontSize: SizeConfig.ts(14),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: SizeConfig.h(8)),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(12.4),
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImageCard extends StatelessWidget {
  final String assetPath;
  const _HeroImageCard({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
        border: Border.all(color: AppColors.lightGreen.o(0.55), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.o(0.06),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          width: double.infinity,
          height: SizeConfig.h(190),
          // ✅ أداء أفضل (تقليل استهلاك الذاكرة)
          cacheWidth: (w * MediaQuery.of(context).devicePixelRatio).round(),
          filterQuality: FilterQuality.low,
        ),
      ),
    );
  }
}

@immutable
class _ServiceTileData {
  final String emoji;
  final String titleAr;
  final String titleEn;

  const _ServiceTileData({
    required this.emoji,
    required this.titleAr,
    required this.titleEn,
  });
}

class _ServiceTile extends StatelessWidget {
  final _ServiceTileData data;
  const _ServiceTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.o(0.03),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data.emoji,
            style: TextStyle(fontSize: SizeConfig.ts(24), height: 1.0),
          ),
          SizedBox(height: SizeConfig.h(8)),
          Text(
            data.titleAr,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(12.8),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: SizeConfig.h(4)),
          Text(
            data.titleEn,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(11),
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
