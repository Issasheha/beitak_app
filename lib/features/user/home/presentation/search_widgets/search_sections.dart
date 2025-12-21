import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class SearchSection extends StatelessWidget {
  const SearchSection({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.lightGreen,
                shape: BoxShape.circle,
              ),
            ),
            SizeConfig.hSpace(8),
            Text(
              title,
              style: TextStyle(
                fontSize: SizeConfig.ts(13),
                fontWeight: FontWeight.w900,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        SizeConfig.v(10),
        child,
      ],
    );
  }
}

class SearchList extends StatelessWidget {
  const SearchList({
    super.key,
    required this.items,
    required this.leading,
    required this.onTap,
    required this.onRemove,
  });

  final List<String> items;
  final IconData leading;
  final void Function(String t) onTap;
  final void Function(String t) onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.6),
        ),
      ),
      child: ListView.separated(
        itemCount: items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: AppColors.borderLight.withValues(alpha: 0.45),
        ),
        itemBuilder: (_, i) {
          final t = items[i];
          return ListTile(
            leading: Icon(leading, color: AppColors.textSecondary),
            title: Text(
              t,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                fontSize: SizeConfig.ts(14),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => onRemove(t),
            ),
            onTap: () => onTap(t),
          );
        },
      ),
    );
  }
}

/// ✅ موديل بسيط للخدمات الشائعة
class PopularServiceItem {
  final String label; // عربي
  final String categoryKey; // ✅ لازم يكون FixedServiceCategories key

  const PopularServiceItem({
    required this.label,
    required this.categoryKey,
  });
}

class PopularServicesList extends StatelessWidget {
  const PopularServicesList({super.key, required this.onPick});

  final void Function(PopularServiceItem item) onPick;

  // ✅ categoryKey لازم يطابق keys الثابتة عندك (FixedServiceCategories)
  static const _popular = <PopularServiceItem>[
    PopularServiceItem(label: 'تنظيف المنازل', categoryKey: 'cleaning'),
    PopularServiceItem(label: 'سباكة', categoryKey: 'plumbing'),
    PopularServiceItem(label: 'كهرباء', categoryKey: 'electricity'),
    PopularServiceItem(label: 'صيانة الأجهزة', categoryKey: 'appliance_maintenance'),
    PopularServiceItem(label: 'صيانة عامة', categoryKey: 'home_maintenance'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.6),
        ),
      ),
      child: ListView.separated(
        itemCount: _popular.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: AppColors.borderLight.withValues(alpha: 0.45),
        ),
        itemBuilder: (_, i) {
          final item = _popular[i];
          return ListTile(
            leading: const Icon(
              Icons.trending_up_rounded,
              color: AppColors.textSecondary,
            ),
            title: Text(
              item.label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                fontSize: SizeConfig.ts(14),
              ),
            ),
            onTap: () => onPick(item),
          );
        },
      ),
    );
  }
}
