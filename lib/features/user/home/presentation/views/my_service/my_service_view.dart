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

    // أول ما تفتح الشاشة: تبويب "طلباتي القادمة"
    final controller = ref.read(myServicesControllerProvider.notifier);
    controller.loadInitial(MyServicesTab.upcoming);

    // لما يغيّر التاب، نحمّل بياناته لو فاضي
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;

      final tab = _indexToTab(_tabController.index);
      final st = ref.read(myServicesControllerProvider).tab(tab);

      if (st.items.isEmpty && !st.isLoading) {
        controller.loadInitial(tab);
      }
    });
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

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
            'طلباتي',
            style: AppTextStyles.h1.copyWith(
              fontSize: SizeConfig.ts(22),
              fontWeight: FontWeight.bold,
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
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(
                  SizeConfig.radius(18),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    SizeConfig.radius(16),
                  ),
                  color: AppColors.lightGreen.withValues(alpha: 0.25),
                ),
                labelColor: AppColors.lightGreen,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTextStyles.semiBold.copyWith(
                  fontSize: SizeConfig.ts(13),
                  fontWeight: FontWeight.w700,
                ),
                tabs: const [
                  Tab(text: 'طلباتي القادمة'),
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

    if (st.isLoading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

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

    if (items.isEmpty) {
      return const EmptyServicesState(
        message: 'لا توجد طلبات حالياً.',
      );
    }

    final controller = ref.read(myServicesControllerProvider.notifier);

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 180) {
          if (!st.isLoadingMore && st.hasMore) {
            controller.loadMore(tab, limit: 20);
          }
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
              // ✅ لو رجعت التفاصيل بـ true (إلغاء مثلاً) نعيد تحميل التاب الحالي
              onChanged: () => controller.loadInitial(tab, limit: 20),
            );
          },
        ),
      ),
    );
  }
}
