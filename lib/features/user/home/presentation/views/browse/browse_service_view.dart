import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/models/browse_filters_result.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/service_details_view.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/viewmodels/browse_providers.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/viewmodels/browse_state.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/widgets/filter_bottom_sheet.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/widgets/service_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BrowseServiceView extends ConsumerStatefulWidget {
  const BrowseServiceView({
    super.key,
    this.initialSearch,
    this.initialCityId,
    this.initialAreaId,
    this.initialCategoryId,
    this.initialCategoryKey,
  });

  final String? initialSearch;
  final int? initialCityId;
  final int? initialAreaId;

  // (موجود عندك—ممكن ما يكون مستخدم حاليًا)
  final int? initialCategoryId;

  // ✅ الجديد: تفعيل categoryKey من الروت
  final String? initialCategoryKey;

  @override
  ConsumerState<BrowseServiceView> createState() => _BrowseServiceViewState();
}

class _BrowseServiceViewState extends ConsumerState<BrowseServiceView> {
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;
  late final BrowseArgs _args;

  ProviderSubscription<BrowseState>? _syncSub;

  @override
  void initState() {
    super.initState();

    _args = BrowseArgs(
      initialSearch: widget.initialSearch,
      initialCityId: widget.initialCityId,
      initialAreaId: widget.initialAreaId,
      initialCategoryKey: widget.initialCategoryKey, // ✅ مهم
    );

    _scrollController = ScrollController()..addListener(_onScroll);
    _searchController = TextEditingController(text: widget.initialSearch ?? '');

    _syncSub = ref.listenManual<BrowseState>(
      browseControllerProvider(_args),
      (prev, next) {
        final desired = next.searchTerm;
        if (_searchController.text == desired) return;

        _searchController.value = _searchController.value.copyWith(
          text: desired,
          selection: TextSelection.collapsed(offset: desired.length),
          composing: TextRange.empty,
        );
      },
    );

    Future.microtask(() {
      ref.read(browseControllerProvider(_args).notifier).bootstrap();
    });
  }

  @override
  void dispose() {
    _syncSub?.close();

    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 220) {
      ref.read(browseControllerProvider(_args).notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(browseControllerProvider(_args).notifier).refresh();
  }

  void _openFilters(BrowseState state) async {
    final result = await showModalBottomSheet<BrowseFiltersResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        initialCategoryKey: state.categoryKey,
        initialMinPrice: state.minPrice,
        initialMaxPrice: state.maxPrice,
        initialMinRating: state.minRating,
      ),
    );

    if (result == null) return;

    ref.read(browseControllerProvider(_args).notifier).applyFilters(
          categoryKey: result.categoryKey,
          minPrice: result.minPrice,
          maxPrice: result.maxPrice,
          minRating: result.minRating,
        );
  }

  void _openDetails(int serviceId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ServiceDetailsView(
          serviceId: serviceId,
          lockedCityId: widget.initialCityId,
          openBookingOnLoad: false,
        ),
      ),
    );
  }

  void _openBooking(int serviceId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ServiceDetailsView(
          serviceId: serviceId,
          lockedCityId: widget.initialCityId,
          openBookingOnLoad: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final state = ref.watch(browseControllerProvider(_args));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leadingWidth: 44,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
          centerTitle: true,
          title: Text(
            'الخدمات',
            style: AppTextStyles.screenTitle.copyWith(
              fontSize: SizeConfig.ts(18),
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => _openFilters(state),
              icon: const Icon(Icons.tune, color: AppColors.textPrimary),
              tooltip: 'فلترة',
            ),
          ],
        ),
        body: Padding(
          padding: SizeConfig.padding(horizontal: 16, top: 10),
          child: Column(
            children: [
              _SearchBar(
                controller: _searchController,
                onSubmitted: (v) {
                  ref
                      .read(browseControllerProvider(_args).notifier)
                      .submitSearch(v);
                },
                onClear: () {
                  _searchController.clear();
                  ref.read(browseControllerProvider(_args).notifier).clearSearch();
                },
              ),
              SizedBox(height: SizeConfig.h(10)),
              Expanded(child: _buildBody(state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BrowseState state) {
    if (state.isLoading) return const _ListSkeleton();

    if (state.errorMessage != null) {
      return _ErrorState(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(browseControllerProvider(_args).notifier).loadInitial(),
      );
    }

    if (state.visible.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.lightGreen,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.only(bottom: SizeConfig.h(16)),
        itemCount: state.visible.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => SizedBox(height: SizeConfig.h(12)),
        itemBuilder: (context, index) {
          if (index >= state.visible.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: SizeConfig.h(10)),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.lightGreen),
              ),
            );
          }

          final s = state.visible[index];

          final serviceMap = {
            'id': s.id,
            'title': s.title,
            'provider': s.providerName.isNotEmpty ? s.providerName : 'مزود خدمة',
            'rating': s.rating,
            'price': s.price,
          };

          return ServiceCard(
            service: serviceMap,
            onTap: () => _openDetails(s.id),
            onBookNow: () => _openBooking(s.id),
          );
        },
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (_, __, ___) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.borderLight.withValues(alpha: 0.7),
            ),
          ),
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: onSubmitted,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'ابحث عن خدمة…',
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: onClear,
                    ),
              filled: true,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        );
      },
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: SizeConfig.h(16)),
      itemCount: 8,
      separatorBuilder: (_, __) => SizedBox(height: SizeConfig.h(12)),
      itemBuilder: (_, __) {
        return Container(
          height: SizeConfig.h(150),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.borderLight.withValues(alpha: 0.7),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'لا توجد خدمات مطابقة',
        style: AppTextStyles.semiBold.copyWith(
          color: AppColors.textSecondary,
          fontSize: SizeConfig.ts(15),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                color: Colors.redAccent, size: SizeConfig.ts(34)),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.semiBold.copyWith(
                color: AppColors.textSecondary,
                fontSize: SizeConfig.ts(14),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              child: Text(
                'إعادة المحاولة',
                style: AppTextStyles.semiBold.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
