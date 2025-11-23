import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/viewmodels/provider_my_service_viewmodel.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/widgets/provider_empty_services_state.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/widgets/provider_service_card.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/widgets/provider_service_filter_menu.dart';
import 'package:go_router/go_router.dart';

class ProviderMyServiceView extends StatefulWidget {
  const ProviderMyServiceView({super.key});

  @override
  State<ProviderMyServiceView> createState() => _ProviderMyServiceViewState();
}

class _ProviderMyServiceViewState extends State<ProviderMyServiceView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final ProviderMyServiceViewModel _viewModel;
  String _selectedFilter = 'الكل';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _viewModel = ProviderMyServiceViewModel();
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
      appBar:  AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  leading: Padding(
    padding: const EdgeInsets.only(right: 12),
    child: ProviderServiceFilterMenu(
      selectedFilter: _selectedFilter,
      onFilterChanged: (v) => setState(() => _selectedFilter = v),
    ),
  ),
  actions: [
    IconButton(
      icon: const Icon(
        Icons.arrow_forward_ios, // لاحظ تغيير الاتجاه
        color: AppColors.textPrimary,
      ),
      onPressed: () => context.go(AppRoutes.providerHome),
    ),
  ],
  title: const Text(
    'خدماتي كمزوّد',
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  centerTitle: true,
),

      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withValues(alpha: 0.1),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.lightGreen,
              unselectedLabelColor: AppColors.textSecondary,
              indicator: BoxDecoration(
                color: AppColors.lightGreen.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              tabs: const [
                Tab(text: 'الكل'),
                Tab(text: 'قيد التأكيد'),
                Tab(text: 'مكتملة'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTab(null),
                _buildTab('Pending'),
                _buildTab('Completed'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String? status) {
    final jobs = _viewModel.getFilteredJobs(
      statusFilter: status,
      filter: _selectedFilter,
    );

    if (jobs.isEmpty) {
      return const ProviderEmptyServicesState(message: 'لا توجد خدمات حالياً');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: jobs.length,
      itemBuilder: (context, i) => ProviderServiceCard(job: jobs[i]),
    );
  }
}
