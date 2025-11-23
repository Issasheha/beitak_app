import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/user/home/presentation/views/my_service/viewmodels/my_services_viewmodel.dart';
import 'package:beitak_app/features/user/home/presentation/views/my_service/widgets/empty_services_state.dart';
import 'package:beitak_app/features/user/home/presentation/views/my_service/widgets/service_card.dart';
import 'package:beitak_app/features/user/home/presentation/views/my_service/widgets/service_filter_menu.dart';
import 'package:flutter/material.dart';

class MyServicesView extends StatefulWidget {
  const MyServicesView({super.key});

  @override
  State<MyServicesView> createState() => _MyServicesViewState();
}

class _MyServicesViewState extends State<MyServicesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late final MyServicesViewModel _viewModel;

  String _selectedFilter = 'الكل';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _viewModel = MyServicesViewModel();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'خدماتي',
          style: TextStyle(
            fontSize: SizeConfig.ts(22),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          ServiceFilterMenu(
            selectedFilter: _selectedFilter,
            onFilterChanged: (value) =>
                setState(() => _selectedFilter = value),
          ),
          SizedBox(width: SizeConfig.w(12)),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: SizeConfig.padding(horizontal: 20, top: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(SizeConfig.radius(14)),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(SizeConfig.radius(14)),
                color: AppColors.lightGreen
                    .withValues(alpha: 0.25),
              ),
              labelColor: AppColors.lightGreen,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: TextStyle(
                fontSize: SizeConfig.ts(14),
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'جميع الخدمات'),
                Tab(text: 'قيد الانتظار'),
                Tab(text: 'طلباتي'),
              ],
            ),
          ),
          SizeConfig.v(20),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent(null),        // جميع الخدمات
                _buildTabContent('Pending'),   // قيد الانتظار
                _buildTabContent(null),        // "طلباتي" مع فلتر القائمة فقط
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(String? statusFilter) {
    final services = _viewModel.getFilteredServices(
      statusFilter: statusFilter,
      filter: _selectedFilter,
    );

    if (services.isEmpty) {
      return EmptyServicesState(
        message: 'لا توجد طلبات $_selectedFilter',
      );
    }

    return ListView.builder(
      padding: SizeConfig.padding(horizontal: 20, bottom: 20),
      itemCount: services.length,
      itemBuilder: (context, index) =>
          ServiceCard(item: services[index]),
    );
  }
}
