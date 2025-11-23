// lib/features/provider/home/presentation/views/provider_home_view.dart

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/provider/home/presentation/viewmodels/provider_home_viewmodel.dart';
import 'package:beitak_app/features/provider/home/presentation/widgets/provider_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class ProviderHomeView extends StatefulWidget {
  const ProviderHomeView({super.key});

  @override
  State<ProviderHomeView> createState() => _ProviderHomeViewState();
}

class _ProviderHomeViewState extends State<ProviderHomeView> {
  late final ProviderHomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProviderHomeViewModel(
      providerName: 'أحمد مزوّد الخدمات', // مؤقتاً، لاحقاً نجيبه من الـ session
    );
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
          title: Text(
            'لوحة مزوّد الخدمة',
            style: TextStyle(
              fontSize: SizeConfig.ts(20),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: SizeConfig.padding(all: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // التحية
                Text(
                  _viewModel.greeting,
                  style: TextStyle(
                    fontSize: SizeConfig.ts(22),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizeConfig.v(12),
                Text(
                  'إدارة طلباتك، حجوزاتك، وخدماتك من مكان واحد.',
                  style: TextStyle(
                    fontSize: SizeConfig.ts(14),
                    color: AppColors.textSecondary,
                  ),
                ),
                SizeConfig.v(24),

                // إحصائيات سريعة
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'طلبات جديدة',
                        value: _viewModel.newRequestsCount.toString(),
                        icon: Icons.inbox_outlined,
                      ),
                    ),
                    SizeConfig.hSpace(12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'حجوزات اليوم',
                        value: _viewModel.todayBookingsCount.toString(),
                        icon: Icons.event_available_outlined,
                      ),
                    ),
                  ],
                ),
                SizeConfig.v(12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'تقييمك',
                        value: _viewModel.rating.toStringAsFixed(1),
                        icon: Icons.star_rate_rounded,
                      ),
                    ),
                    SizeConfig.hSpace(12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'أرباح اليوم',
                        value: '${_viewModel.todayEarnings.toStringAsFixed(2)} د.أ',
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                    ),
                  ],
                ),
                SizeConfig.v(28),

                // حجوزات اليوم
                Text(
                  'حجوزات اليوم',
                  style: TextStyle(
                    fontSize: SizeConfig.ts(18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizeConfig.v(12),
                ..._viewModel.todayBookings.map(
                  (b) => _buildBookingItem(
                    service: b['service'],
                    time: b['time'],
                    location: b['location'],
                  ),
                ),
                SizeConfig.v(80),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const ProviderBottomNavigationBar(),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: SizeConfig.padding(all: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        boxShadow: [AppColors.primaryShadow],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.lightGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
            ),
            child: Icon(
              icon,
              color: AppColors.lightGreen,
              size: SizeConfig.ts(22),
            ),
          ),
          SizeConfig.hSpace(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: SizeConfig.ts(13),
                    color: AppColors.textSecondary,
                  ),
                ),
                SizeConfig.v(4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: SizeConfig.ts(18),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingItem({
    required String service,
    required String time,
    required String location,
  }) {
    return Container(
      margin: SizeConfig.padding(bottom: 10),
      padding: SizeConfig.padding(all: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        boxShadow: [AppColors.primaryShadow],
      ),
      child: Row(
        children: [
          Icon(
            Icons.event_note_outlined,
            size: SizeConfig.ts(24),
            color: AppColors.lightGreen,
          ),
          SizeConfig.hSpace(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service,
                  style: TextStyle(
                    fontSize: SizeConfig.ts(15),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizeConfig.v(4),
                Text(
                  '$time • $location',
                  style: TextStyle(
                    fontSize: SizeConfig.ts(13),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
