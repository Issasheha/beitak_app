import 'package:beitak_app/core/constants/fixed_service_categories.dart';
import 'package:beitak_app/core/providers/categories_id_map_provider.dart';
import 'package:beitak_app/features/provider/home/presentation/views/marketplace/viewmodels/marketplace_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/marketplace_filters.dart';
import 'marketplace_price_range_sheet.dart';
import 'marketplace_filter_chip_widgets.dart';

enum MarketplaceChipKey { sort, category, city, price }

class MarketplaceFilterChips extends ConsumerWidget {
  const MarketplaceFilterChips({
    super.key,
    required this.active,
    required this.onActiveChanged,
  });

  final MarketplaceChipKey active;
  final ValueChanged<MarketplaceChipKey> onActiveChanged;

  static const List<String> _categories = <String>[
    'سباكة',
    'تنظيف',
    'صيانة المنازل',
    'صيانة للأجهزة',
    'كهرباء',
  ];

  /// ✅ fallback ثابت لو FixedServiceCategories ما غطّى النص العربي
  static const Map<String, String> _labelToKeyFallback = {
    'تنظيف': 'cleaning',
    'سباكة': 'plumbing',
    'كهرباء': 'electricity',
    'صيانة المنازل': 'home_maintenance',
    'صيانة للأجهزة': 'appliance_maintenance',
  };

  static const Map<int, String> _cityIdToLabel = {
    1: 'عمّان',
    4: 'العقبة',
  };

  String _priceLabel(double? min, double? max) {
    final hasMin = min != null;
    final hasMax = max != null;
    if (!hasMin && !hasMax) return 'الكل';

    String fmt(double v) => v.toStringAsFixed(0);

    if (hasMin && hasMax) return '${fmt(min)}-${fmt(max)} د.أ';
    if (hasMin) return 'من ${fmt(min)} د.أ';
    return 'إلى ${fmt(max!)} د.أ';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(marketplaceControllerProvider);
    final notifier = ref.read(marketplaceControllerProvider.notifier);

    Future<void> setCategory(String? label) async {
      onActiveChanged(MarketplaceChipKey.category);

      if (label == null) {
        await notifier.applyFilters(state.filters.copyWith(clearCategory: true));
        return;
      }

      final keyFromFixed = FixedServiceCategories.keyFromAnyString(label);
      final key = keyFromFixed ?? _labelToKeyFallback[label];

      int? categoryId;
      if (key != null) {
        final idMap = await ref.read(categoriesIdMapProvider.future);
        categoryId = idMap[key];
      }

      await notifier.applyFilters(
        state.filters.copyWith(
          categoryLabel: label,
          categoryId: categoryId,
        ),
      );
    }

    Future<void> setCity(int? id) async {
      onActiveChanged(MarketplaceChipKey.city);

      if (id == null) {
        await notifier.applyFilters(state.filters.copyWith(clearCity: true));
        return;
      }

      await notifier.applyFilters(state.filters.copyWith(cityId: id));
    }

    Future<void> setSort(MarketplaceSort s) async {
      onActiveChanged(MarketplaceChipKey.sort);
      await notifier.applyFilters(state.filters.copyWith(sort: s));
    }

    Future<void> openPrice() async {
      onActiveChanged(MarketplaceChipKey.price);

      final result = await showModalBottomSheet<PriceRangeResult?>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => MarketplacePriceRangeSheet(
          initialMin: state.filters.minBudget,
          initialMax: state.filters.maxBudget,
        ),
      );

      if (result == null) return;

      if (result.reset) {
        await notifier.applyFilters(state.filters.copyWith(clearBudget: true));
      } else {
        await notifier.applyFilters(
          state.filters.copyWith(minBudget: result.min, maxBudget: result.max),
        );
      }
    }

    final isCategoryApplied = (state.filters.categoryId != null) ||
        (state.filters.categoryLabel != null &&
            state.filters.categoryLabel!.trim().isNotEmpty);

    final isCityApplied = state.filters.cityId != null;

    final isPriceApplied =
        state.filters.minBudget != null || state.filters.maxBudget != null;

    final categoryValue =
        isCategoryApplied ? (state.filters.categoryLabel ?? 'محددة') : 'الكل';

    final cityValue = state.filters.cityId == null
        ? 'الكل'
        : (_cityIdToLabel[state.filters.cityId!] ?? 'محددة');

    final priceValue =
        _priceLabel(state.filters.minBudget, state.filters.maxBudget);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ToggleChip(
            label: 'رتّب حسب',
            value: state.filters.sort.label,
            selected: active == MarketplaceChipKey.sort,
            onTap: () {
              final next = state.filters.sort == MarketplaceSort.newest
                  ? MarketplaceSort.oldest
                  : MarketplaceSort.newest;
              setSort(next);
            },
          ),
          const SizedBox(width: 10),

          MenuChip(
            label: 'الفئة',
            value: categoryValue,
            selected: (active == MarketplaceChipKey.category) || isCategoryApplied,
            onOpened: () => onActiveChanged(MarketplaceChipKey.category),
            items: <MenuItem>[
              MenuItem(label: 'جميع الفئات', onTap: () => setCategory(null)),
              ..._categories.map(
                (c) => MenuItem(label: c, onTap: () => setCategory(c)),
              ),
            ],
          ),
          const SizedBox(width: 10),

          MenuChip(
            label: 'المنطقة',
            value: cityValue,
            selected: (active == MarketplaceChipKey.city) || isCityApplied,
            onOpened: () => onActiveChanged(MarketplaceChipKey.city),
            items: <MenuItem>[
              MenuItem(label: 'كل المدن', onTap: () => setCity(null)),
              MenuItem(label: 'عمّان', onTap: () => setCity(1)),
              MenuItem(label: 'العقبة', onTap: () => setCity(4)),
            ],
          ),
          const SizedBox(width: 10),

          ActionChipX(
            label: 'السعر',
            value: priceValue,
            selected: (active == MarketplaceChipKey.price) || isPriceApplied,
            onTap: openPrice,
          ),
        ],
      ),
    );
  }
}
