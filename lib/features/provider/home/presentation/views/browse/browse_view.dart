import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/features/provider/home/presentation/views/browse/viewmodels/provider_browse_viewmodel.dart';
import 'package:beitak_app/features/provider/home/presentation/views/browse/widgets/provider_request_card.dart';
import 'package:beitak_app/features/provider/home/presentation/views/browse/widgets/provider_request_details_sheet.dart';
import 'package:beitak_app/features/provider/home/presentation/views/browse/widgets/provider_requests_filter_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProviderBrowseView extends StatefulWidget {
  const ProviderBrowseView({super.key});

  @override
  State<ProviderBrowseView> createState() => _ProviderBrowseViewState();
}

class _ProviderBrowseViewState extends State<ProviderBrowseView> {
  late final ProviderBrowseViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProviderBrowseViewModel();
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderRequestsFilterBottomSheet(
        currentFilters: {
          'category': _viewModel.selectedCategory,
          'minPrice': _viewModel.minPrice,
          'maxPrice': _viewModel.maxPrice,
          'minRating': _viewModel.minRating,
        },
        onApply: (filters) {
          setState(() {
            _viewModel.updateFilters(
              category: filters['category'] as String?,
              minPrice: filters['minPrice'] as double?,
              maxPrice: filters['maxPrice'] as double?,
              minRating: filters['minRating'] as double?,
            );
          });
        },
      ),
    );
  }

  void _openDetails(ServiceRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderRequestDetailsSheet(
        request: request,
        onClose: () => Navigator.pop(context),
        onAccept: request.status == 'قيد الانتظار'
            ? () {
                setState(() {
                  _viewModel.updateRequestStatus(request.id, 'مقبولة');
                });
                Navigator.pop(context);
              }
            : null,
        onCancel: (request.status == 'قيد الانتظار' ||
                request.status == 'مقبولة')
            ? () {
                setState(() {
                  _viewModel.updateRequestStatus(request.id, 'مكتملة');
                });
                Navigator.pop(context);
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final requests = _viewModel.filteredRequests;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          
          backgroundColor: AppColors.background,
          elevation: 0,
           leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.go(AppRoutes.providerHome),
          ),
          title: Text(
            'استكشاف الطلبات',
            style: TextStyle(
              fontSize: SizeConfig.ts(20),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _openFilters,
            ),
          ],
        ),
        body: Column(
          children: [
            _buildStatusChips(),
            const Divider(height: 1),
            Expanded(
              child: requests.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد طلبات مطابقة حاليًا',
                        style: TextStyle(
                          fontSize: SizeConfig.ts(16),
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding:
                          SizeConfig.padding(horizontal: 16, vertical: 12),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final req = requests[index];
                        return ProviderRequestCard(
                          request: req,
                          onViewDetails: () => _openDetails(req),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChips() {
    const statuses = ['الكل', 'قيد الانتظار', 'مقبولة', 'مكتملة'];

    return Container(
      padding: SizeConfig.padding(horizontal: 16, vertical: 10),
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: 8,
        children: statuses.map((s) {
          final isSelected = _viewModel.selectedStatus == s;
          return ChoiceChip(
            label: Text(
              s,
              style: TextStyle(
                fontSize: SizeConfig.ts(12.5),
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.lightGreen,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? AppColors.lightGreen
                    : AppColors.borderLight.withValues(alpha: 0.8),
              ),
            ),
            onSelected: (_) {
              setState(() {
                _viewModel.updateStatus(s);
              });
            },
          );
        }).toList(),
      ),
    );
  }
}
