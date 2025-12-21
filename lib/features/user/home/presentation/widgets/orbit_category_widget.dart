import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/constants/color_x.dart';
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

  // ✅ نفس الفئات لكن بدل apiQuery صار categoryKey
  // ✅ استخدمنا slug تبع الباك اند بالضبط (بما فيه المسافات)
  final List<_HomeCategory> _cats = const [
    _HomeCategory(
      title: 'السباكة',
      subtitle: 'مشاكل المياه',
      emoji: '🔧',
      categoryKey: 'plumbing',
    ),
    _HomeCategory(
      title: 'التنظيف',
      subtitle: 'منزل مرتب أجمل',
      emoji: '🧽',
      categoryKey: 'cleaning',
    ),
    _HomeCategory(
      title: 'صيانة',
      subtitle: 'شاملة للمنزل',
      emoji: '🪛',
      categoryKey: 'general maintenance',
    ),
    _HomeCategory(
      title: 'صيانة الأجهزة',
      subtitle: 'جميع الأجهزة',
      emoji: '🛠️',
      categoryKey: 'appliance repair',
    ),
    _HomeCategory(
      title: 'كهرباء',
      subtitle: 'مشاكلك بكل يسر',
      emoji: '⚡',
      categoryKey: 'electrical',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openBrowse(BuildContext context, String categoryKey) {
    final key = categoryKey.trim();
    if (key.isEmpty) return;

    context.push(
      Uri(
        path: AppRoutes.browseServices,
        queryParameters: {'category_key': key}, // ✅ أدق من q
      ).toString(),
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
                      onTap: () => _openBrowse(context, top[i].categoryKey),
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
            final sidePadding = ((c.maxWidth - twoRowW) / 2).clamp(0.0, 999.0);

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
                          onTap: () => _openBrowse(context, bottom[0].categoryKey),
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
                          onTap: () => _openBrowse(context, bottom[1].categoryKey),
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
  final String? subtitle;
  final String emoji;

  final String categoryKey; // ✅ بدل apiQuery

  const _HomeCategory({
    required this.title,
    this.subtitle,
    required this.emoji,
    required this.categoryKey,
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
                fontSize: SizeConfig.ts(13.2),
                height: 1.10,
              ),
            ),
            SizedBox(height: SizeConfig.h(4)),
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
