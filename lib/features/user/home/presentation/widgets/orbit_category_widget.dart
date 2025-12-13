import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/constants/color_x.dart';
import 'package:beitak_app/core/helpers/search_normalizer.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrbitCategoryWidget extends StatefulWidget {
  const OrbitCategoryWidget({super.key});

  @override
  State<OrbitCategoryWidget> createState() => _OrbitCategoryWidgetState();
}

class _OrbitCategoryWidgetState extends State<OrbitCategoryWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // ✅ نفس الفئات + apiQuery (تركنا subtitle موجودة بالكلاس/البيانات بس مش رح نعرضها)
  final List<_HomeCategory> _cats = const [
    _HomeCategory(
      title: 'السباكة',
      subtitle: 'مشاكل المياه',
      emoji: '🔧',
      apiQuery: 'repair',
    ),
    _HomeCategory(
      title: 'التنظيف',
      subtitle: 'منزل مرتب أجمل',
      emoji: '🧽',
      apiQuery: 'cleaning',
    ),
    _HomeCategory(
      title: 'صيانة',
      subtitle: 'شاملة للمنزل',
      emoji: '🪛',
      apiQuery: 'maintenance',
    ),
    _HomeCategory(
      title: 'صيانة الأجهزة',
      subtitle: 'جميع الأجهزة',
      emoji: '🛠️',
      apiQuery: 'appliance repair',
    ),
    _HomeCategory(
      title: 'كهرباء',
      subtitle: 'مشاكلك بكل يسر',
      emoji: '⚡',
      apiQuery: 'Installation',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 520))
          ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openBrowse(BuildContext context, String apiQuery) {
    final q = SearchNormalizer.normalizeForApi(apiQuery);
    context.push(
      Uri(path: AppRoutes.browseServices, queryParameters: {'q': q}).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = _cats.take(3).toList();
    final bottom = _cats.skip(3).toList();
    const gap = 14.0;

    return Column(
      children: [
        Row(
          children: [
            for (int i = 0; i < top.length; i++) ...[
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _AnimatedTile(
                    index: i,
                    controller: _controller,
                    child: _CategoryCard(
                      cat: top[i],
                      onTap: () => _openBrowse(context, top[i].apiQuery),
                    ),
                  ),
                ),
              ),
              if (i != top.length - 1) const SizedBox(width: gap),
            ]
          ],
        ),
        SizedBox(height: SizeConfig.h(18)),
        LayoutBuilder(
          builder: (context, c) {
            final cardW = (c.maxWidth - (gap * 2)) / 3;
            final twoRowW = (cardW * 2) + gap;
            final sidePadding =
                ((c.maxWidth - twoRowW) / 2).clamp(0.0, 999.0);

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: sidePadding),
              child: Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _AnimatedTile(
                        index: 3,
                        controller: _controller,
                        child: _CategoryCard(
                          cat: bottom[0],
                          onTap: () => _openBrowse(context, bottom[0].apiQuery),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: gap),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _AnimatedTile(
                        index: 4,
                        controller: _controller,
                        child: _CategoryCard(
                          cat: bottom[1],
                          onTap: () => _openBrowse(context, bottom[1].apiQuery),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AnimatedTile extends StatelessWidget {
  const _AnimatedTile({
    required this.index,
    required this.controller,
    required this.child,
  });

  final int index;
  final AnimationController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.08).clamp(0.0, 0.6);
    final end = (start + 0.50).clamp(0.35, 1.0);

    final anim = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
            .animate(anim),
        child: child,
      ),
    );
  }
}

class _HomeCategory {
  final String title;
  final String? subtitle; // ✅ صارت اختيارية (موجودة للبيانات فقط)
  final String emoji;

  final String apiQuery;

  const _HomeCategory({
    required this.title,
    this.subtitle,
    required this.emoji,
    required this.apiQuery,
  });
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.cat, required this.onTap});
  final _HomeCategory cat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
      onTap: onTap,
      child: Container(
        padding: SizeConfig.padding(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
          border: Border.all(color: const Color(0xFFE9E9E9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.o(0.07),
              blurRadius: 12,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              cat.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.lightGreen,
                fontWeight: FontWeight.w900,
                fontSize: SizeConfig.ts(13.2), // ✅ أجمل شوي بعد حذف subtitle
                height: 1.10, // ✅ تنفّس أفضل
              ),
            ),

            // ✅ كان 6، قللناه 4 عشان التناسق بعد حذف subtitle
            SizedBox(height: SizeConfig.h(4)),

            // ✅ الإيموجي بالنص عموديًا
            const Spacer(),
            Text(cat.emoji, style: TextStyle(fontSize: SizeConfig.ts(22))),
            const Spacer(),

            SizedBox(height: SizeConfig.h(2)),
          ],
        ),
      ),
    );
  }
}
