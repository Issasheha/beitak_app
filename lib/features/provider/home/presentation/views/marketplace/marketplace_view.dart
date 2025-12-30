// lib/features/provider/home/presentation/views/marketplace/marketplace_view.dart
// (اسم الملف عندك ممكن مختلف، بس هذا هو الملف اللي بعرض MarketplaceView)

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/constants/fixed_service_categories.dart';
import 'package:beitak_app/core/providers/categories_id_map_provider.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/features/provider/home/presentation/views/marketplace/viewmodels/marketplace_providers.dart';
import 'package:beitak_app/features/provider/home/presentation/views/marketplace/widgets/marketplace_request_card.dart';
import 'package:beitak_app/features/provider/home/presentation/views/marketplace/widgets/marketplace_request_details_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'models/marketplace_filters.dart';
import 'models/marketplace_request_ui_model.dart';

class MarketplaceView extends ConsumerStatefulWidget {
  const MarketplaceView({super.key});

  @override
  ConsumerState<MarketplaceView> createState() => _MarketplaceViewState();
}

class _MarketplaceViewState extends ConsumerState<MarketplaceView> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  _ChipKey _activeChip = _ChipKey.sort;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_onScroll);

    // ✅ ضمان: كل مرة تدخل السوق يبدأ Default (حتى لو provider ما كان autoDispose)
    Future.microtask(() async {
      await ref.read(marketplaceControllerProvider.notifier).resetFilters();
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final extentAfter = _scrollController.position.extentAfter;
    if (extentAfter < 350) {
      ref.read(marketplaceControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();

    // ✅ مطلب QA: الفلاتر تنمسح عند الخروج من صفحة السوق
    // (ما بنعمل load هون لتجنب أي side-effect؛ بس نرجّع state default)
    Future.microtask(() {
      final n = ref.read(marketplaceControllerProvider.notifier);
      n.setSearchQuery('');
      n.applyFilters(MarketplaceFilters.initial());
    });

    super.dispose();
  }

  void _handleBack(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.providerHome);
  }

  void _openDetails(BuildContext context, MarketplaceRequestUiModel req) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MarketplaceRequestDetailsSheet(request: req),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketplaceControllerProvider);

    ref.listen(marketplaceControllerProvider, (prev, next) {
      final msg = next.uiMessage;
      if (msg != null && msg.isNotEmpty && msg != prev?.uiMessage) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );

        Future.microtask(() {
          ref.read(marketplaceControllerProvider.notifier).clearUiMessage();
        });
      }
    });

    if (_searchController.text != state.searchQuery) {
      _searchController.value = TextEditingValue(
        text: state.searchQuery,
        selection: TextSelection.collapsed(offset: state.searchQuery.length),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              _TopHeader(
                title: 'السوق',
                subtitle: 'طلبات الخدمات المتاحة في التطبيق',
                onBack: () => _handleBack(context),
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _MarketplaceFourFilterChips(
                  active: _activeChip,
                  onActiveChanged: (k) => setState(() => _activeChip = k),
                ),
              ),

              const SizedBox(height: 10),
              Expanded(
                child: Builder(
                  builder: (_) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.errorMessage != null && state.allRequests.isEmpty) {
                      return _ErrorState(
                        message: state.errorMessage!,
                        onRetry: () => ref
                            .read(marketplaceControllerProvider.notifier)
                            .load(),
                      );
                    }

                    final items = state.visibleRequests;
                    if (items.isEmpty) return const _EmptyState();

                    final showFooter = state.isLoadingMore ||
                        state.loadMoreFailed ||
                        state.hasMore;

                    return RefreshIndicator(
                      onRefresh: () async {
                        await ref
                            .read(marketplaceControllerProvider.notifier)
                            .load(refresh: true);
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: items.length + (showFooter ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == items.length) {
                            if (state.isLoadingMore) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            if (state.loadMoreFailed) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Center(
                                  child: TextButton(
                                    onPressed: () => ref
                                        .read(marketplaceControllerProvider.notifier)
                                        .loadMore(),
                                    child: const Text(
                                      'فشل تحميل المزيد — اضغط لإعادة المحاولة',
                                      style: TextStyle(fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                              );
                            }

                            return const SizedBox(height: 8);
                          }

                          final req = items[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: MarketplaceRequestCard(
                              request: req,
                              onTap: () => _openDetails(context, req),
                              onAccept: () => ref
                                  .read(marketplaceControllerProvider.notifier)
                                  .accept(req.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ChipKey { sort, category, city, price }

class _MarketplaceFourFilterChips extends ConsumerWidget {
  const _MarketplaceFourFilterChips({
    required this.active,
    required this.onActiveChanged,
  });

  final _ChipKey active;
  final ValueChanged<_ChipKey> onActiveChanged;

  static const List<String> _categories = <String>[
    'سباكة',
    'تنظيف',
    'صيانة المنازل',
    'صيانة للأجهزة',
    'كهرباء',
  ];

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

    if (hasMin && hasMax) return '${fmt(min!)}-${fmt(max!)} د.أ';
    if (hasMin) return 'من ${fmt(min!)} د.أ';
    return 'إلى ${fmt(max!)} د.أ';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(marketplaceControllerProvider);
    final notifier = ref.read(marketplaceControllerProvider.notifier);

    Future<void> setCategory(String? label) async {
      onActiveChanged(_ChipKey.category);

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
      onActiveChanged(_ChipKey.city);

      if (id == null) {
        await notifier.applyFilters(state.filters.copyWith(clearCity: true));
        return;
      }

      await notifier.applyFilters(state.filters.copyWith(cityId: id));
    }

    Future<void> setSort(MarketplaceSort s) async {
      onActiveChanged(_ChipKey.sort);
      await notifier.applyFilters(state.filters.copyWith(sort: s));
    }

    Future<void> openPrice() async {
      onActiveChanged(_ChipKey.price);

      final result = await showModalBottomSheet<_PriceRangeResult?>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _PriceRangeSheet(
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

    final categoryValue = isCategoryApplied
        ? (state.filters.categoryLabel ?? 'محددة')
        : 'الكل';

    final cityValue = state.filters.cityId == null
        ? 'الكل'
        : (_cityIdToLabel[state.filters.cityId!] ?? 'محددة');

    final priceValue = _priceLabel(state.filters.minBudget, state.filters.maxBudget);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ToggleChip(
            label: 'رتّب حسب',
            value: state.filters.sort.label,
            selected: active == _ChipKey.sort,
            onTap: () {
              final next = state.filters.sort == MarketplaceSort.newest
                  ? MarketplaceSort.oldest
                  : MarketplaceSort.newest;
              setSort(next);
            },
          ),
          const SizedBox(width: 10),

          _MenuChip(
            label: 'الفئة',
            value: categoryValue,
            selected: (active == _ChipKey.category) || isCategoryApplied,
            onOpened: () => onActiveChanged(_ChipKey.category),
            items: <_MenuItem>[
              _MenuItem(label: 'جميع الفئات', onTap: () => setCategory(null)),
              ..._categories.map((c) => _MenuItem(label: c, onTap: () => setCategory(c))),
            ],
          ),

          const SizedBox(width: 10),

          _MenuChip(
            label: 'المنطقة',
            value: cityValue,
            selected: (active == _ChipKey.city) || isCityApplied,
            onOpened: () => onActiveChanged(_ChipKey.city),
            items: <_MenuItem>[
              _MenuItem(label: 'كل المدن', onTap: () => setCity(null)),
              _MenuItem(label: 'عمّان', onTap: () => setCity(1)),
              _MenuItem(label: 'العقبة', onTap: () => setCity(4)),
            ],
          ),

          const SizedBox(width: 10),

          _ActionChip(
            label: 'السعر',
            value: priceValue,
            selected: (active == _ChipKey.price) || isPriceApplied,
            onTap: openPrice,
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final String label;
  final VoidCallback onTap;
  const _MenuItem({required this.label, required this.onTap});
}

class _MenuChip extends StatelessWidget {
  final String label;
  final String? value;
  final bool selected;
  final List<_MenuItem> items;
  final VoidCallback onOpened;

  const _MenuChip({
    required this.label,
    required this.selected,
    required this.items,
    required this.onOpened,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.lightGreen : Colors.white;
    final fg = selected ? Colors.white : const Color(0xFF111827);
    final border = selected ? AppColors.lightGreen : const Color(0xFFE5E7EB);

    final v = (value == null || value!.trim().isEmpty) ? null : value!.trim();

    return PopupMenuButton<String>(
      tooltip: '',
      onOpened: onOpened,
      onSelected: (String value) {
        final item = items.firstWhere((e) => e.label == value);
        item.onTap();
      },
      itemBuilder: (context) => items
          .map((e) => PopupMenuItem<String>(
                value: e.label,
                child: Text(e.label),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border, width: 1.1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
            if (v != null) ...[
              const SizedBox(width: 8),
              Text(
                v,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: fg,
                ),
              ),
            ],
            const SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: fg),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final String? value;
  final bool selected;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.lightGreen : Colors.white;
    final fg = selected ? Colors.white : const Color(0xFF111827);
    final border = selected ? AppColors.lightGreen : const Color(0xFFE5E7EB);

    final v = (value == null || value!.trim().isEmpty) ? null : value!.trim();

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border, width: 1.1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
            if (v != null) ...[
              const SizedBox(width: 8),
              Text(
                v,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: fg,
                ),
              ),
            ],
            const SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: fg),
          ],
        ),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.lightGreen : Colors.white;
    final fg = selected ? Colors.white : const Color(0xFF111827);
    final border = selected ? AppColors.lightGreen : const Color(0xFFE5E7EB);

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border, width: 1.1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRangeResult {
  final bool reset;
  final double? min;
  final double? max;

  const _PriceRangeResult.reset()
      : reset = true,
        min = null,
        max = null;

  const _PriceRangeResult.apply({required this.min, required this.max})
      : reset = false;
}

class _PriceRangeSheet extends StatefulWidget {
  final double? initialMin;
  final double? initialMax;

  const _PriceRangeSheet({
    required this.initialMin,
    required this.initialMax,
  });

  @override
  State<_PriceRangeSheet> createState() => _PriceRangeSheetState();
}

class _PriceRangeSheetState extends State<_PriceRangeSheet> {
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();

  String? _error;

  double? _parse(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  void _validateAndApply() {
    final min = _parse(_minCtrl.text);
    final max = _parse(_maxCtrl.text);

    // ✅ لا شيء مُدخل → اعتبر reset (أو خليها apply null/null)
    // هنا نخليها apply عادي (الفلاتر رح تفهمها)
    if (min != null && min < 0) {
      setState(() => _error = 'قيمة "من" يجب أن تكون رقمًا موجبًا.');
      return;
    }
    if (max != null && max < 0) {
      setState(() => _error = 'قيمة "إلى" يجب أن تكون رقمًا موجبًا.');
      return;
    }

    if (min != null && max != null && min > max) {
      setState(() => _error = 'نطاق غير منطقي: "من" يجب أن تكون أقل أو تساوي "إلى".');
      return;
    }

    setState(() => _error = null);

    Navigator.pop(
      context,
      _PriceRangeResult.apply(min: min, max: max),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialMin != null) {
      _minCtrl.text = widget.initialMin!.toStringAsFixed(0);
    }
    if (widget.initialMax != null) {
      _maxCtrl.text = widget.initialMax!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'السعر',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _NumberField(controller: _minCtrl, hint: 'من')),
                  const SizedBox(width: 10),
                  Expanded(child: _NumberField(controller: _maxCtrl, hint: 'إلى')),
                ],
              ),

              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],

              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.lightGreen, width: 1.2),
                        foregroundColor: AppColors.lightGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () =>
                          Navigator.pop(context, const _PriceRangeResult.reset()),
                      child: const Text(
                        'إعادة تعيين',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _validateAndApply,
                      child: const Text(
                        'تطبيق',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _NumberField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGreen, width: 1.1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _TopHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        height: 64,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                tooltip: 'رجوع',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'لا توجد طلبات حالياً',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
