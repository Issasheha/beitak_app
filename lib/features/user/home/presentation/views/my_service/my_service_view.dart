import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

import 'package:beitak_app/features/user/home/presentation/views/my_service/viewmodels/my_services_state.dart';
import 'package:beitak_app/features/user/home/presentation/views/my_service/viewmodels/my_services_providers.dart';

import 'package:beitak_app/features/user/home/presentation/views/my_service/widgets/empty_services_state.dart';
import 'package:beitak_app/features/user/home/presentation/views/my_service/widgets/service_card.dart';

class MyServicesView extends ConsumerStatefulWidget {
  const MyServicesView({super.key});

  @override
  ConsumerState<MyServicesView> createState() => _MyServicesViewState();
}

class _MyServicesViewState extends ConsumerState<MyServicesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    // ✅ مهم جداً: أول تحميل لازم يكون بعد أول frame (حتى ما يطلع Exception تبع Riverpod)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(myServicesControllerProvider.notifier).loadInitial(
            MyServicesTab.upcoming,
            limit: 20,
          );
    });

    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    setState(() {}); // للـ accent

    final tab = _indexToTab(_tabController.index);

    // ✅ كمان نأخر التحميل بعد الـ frame (خصوصاً TabBarView أثناء إعادة البناء)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final st = ref.read(myServicesControllerProvider).tab(tab);
      if (st.items.isEmpty && !st.isLoading) {
        ref.read(myServicesControllerProvider.notifier).loadInitial(tab, limit: 20);
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  // 0: upcoming, 1: pending, 2: archive
  MyServicesTab _indexToTab(int index) {
    switch (index) {
      case 0:
        return MyServicesTab.upcoming;
      case 1:
        return MyServicesTab.pending;
      case 2:
      default:
        return MyServicesTab.archive;
    }
  }

  Color _tabAccent(int index) {
    switch (index) {
      case 0:
        return AppColors.lightGreen; // القادمة
      case 1:
        return Colors.orange.shade700; // قيد الانتظار
      case 2:
      default:
        return Colors.blue.shade700; // السجل
    }
  }

  String _emptyMessage(MyServicesTab tab) {
    switch (tab) {
      case MyServicesTab.upcoming:
        return 'لا توجد طلبات قادمة حالياً.';
      case MyServicesTab.pending:
        return 'لا توجد طلبات قيد الانتظار حالياً.';
      case MyServicesTab.archive:
        return 'لا يوجد سجل حتى الآن.';
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final accent = _tabAccent(_tabController.index);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'حجوزاتي و طلباتي',
            style: AppTextStyles.h1.copyWith(
              fontSize: SizeConfig.ts(20),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              margin: SizeConfig.padding(horizontal: 16, top: 8),
              padding: SizeConfig.padding(all: 6),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.16),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
                  color: accent.withValues(alpha: 0.20),
                ),
                labelColor: accent,
                unselectedLabelColor: AppColors.textSecondary,
                dividerColor: Colors.transparent,
                labelStyle: AppTextStyles.semiBold.copyWith(
                  fontSize: SizeConfig.ts(13),
                  fontWeight: FontWeight.w800,
                ),
                tabs: const [
                  Tab(text: 'القادمة'),
                  Tab(text: 'قيد الانتظار'),
                  Tab(text: 'السجل'),
                ],
              ),
            ),
            SizeConfig.v(16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTab(MyServicesTab.upcoming),
                  _buildTab(MyServicesTab.pending),
                  _buildTab(MyServicesTab.archive),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(MyServicesTab tab) {
    final state = ref.watch(myServicesControllerProvider);
    final st = state.tab(tab);
    final items = st.items;

    // ✅ تحميل أولي
    if (st.isLoading && items.isEmpty && st.hasMore) {
      return const Center(child: CircularProgressIndicator());
    }

    // ✅ خطأ
    if (st.error != null && items.isEmpty) {
      return Center(
        child: Padding(
          padding: SizeConfig.padding(all: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                st.error!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  fontSize: SizeConfig.ts(16),
                  color: AppColors.textSecondary,
                ),
              ),
              SizeConfig.v(12),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(myServicesControllerProvider.notifier)
                      .loadInitial(tab, limit: 20);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBackground,
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

    // ✅ فاضي
    if (items.isEmpty) {
      return EmptyServicesState(message: _emptyMessage(tab));
    }

    final controller = ref.read(myServicesControllerProvider.notifier);

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        // ✅ تجاهل أي شيء غير تحديث سكرول فعلي
        if (n is! ScrollUpdateNotification && n is! OverscrollNotification) {
          return false;
        }

        // ✅ إذا ما في سكرول أصلاً (القائمة أقصر من الشاشة) لا تعمل loadMore
        if (n.metrics.maxScrollExtent <= 0) return false;

        // ✅ لا تعمل loadMore أثناء loadInitial
        if (st.isLoading) return false;

        if (n.metrics.extentAfter < 250) {
          // ✅ نفذ بعد الحدث (حتى ما يصير تعديل Provider أثناء build/paint)
          Future.microtask(() {
            if (!mounted) return;

            final latest = ref.read(myServicesControllerProvider).tab(tab);
            if (!latest.isLoading &&
                !latest.isLoadingMore &&
                latest.hasMore) {
              ref
                  .read(myServicesControllerProvider.notifier)
                  .loadMore(tab, limit: 20);
            }
          });
        }

        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => controller.loadInitial(tab, limit: 20),
        child: ListView.builder(
          padding: SizeConfig.padding(horizontal: 16, bottom: 20),
          itemCount: items.length + (st.isLoadingMore ? 1 : 0),
          itemBuilder: (context, i) {
            if (i >= items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return ServiceCard(
              item: items[i],
              onChanged: () => controller.loadInitial(tab, limit: 20),
            );
          },
        ),
      ),
    );
  }
}
