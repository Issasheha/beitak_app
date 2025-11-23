import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/features/user/home/domain/entities/service_entity.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/viewmodels/browse_services_viewmodel.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/widgets/filter_bottom_sheet.dart';
import 'package:beitak_app/features/user/home/presentation/views/browse/widgets/service_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BrowseServiceView extends StatefulWidget {
  const BrowseServiceView({super.key});

  @override
  State<BrowseServiceView> createState() => _BrowseServiceViewState();
}

class _BrowseServiceViewState extends State<BrowseServiceView> {
  late final BrowseServicesViewModel _viewModel;

  bool _isLoading = false;
  String? _errorMessage;

  List<ServiceEntity> _services = [];
  List<ServiceEntity> _filteredServices = [];

  // نفس شكل الفلاتر السابق عشان تبقى متوافقة مع FilterBottomSheet
  Map<String, dynamic> _filters = {
    'category': 'الكل',
    'minPrice': 0.0,
    'maxPrice': 150.0,
    'minRating': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _viewModel = BrowseServicesViewModel();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await _viewModel.loadInitial();

    setState(() {
      _isLoading = false;
      _errorMessage = _viewModel.errorMessage;
      _services = List<ServiceEntity>.from(_viewModel.services);
      _filteredServices = List<ServiceEntity>.from(_services);
    });
  }

  void _applyFilters(Map<String, dynamic> newFilters) {
    setState(() {
      _filters = newFilters;

      _filteredServices = _services.where((service) {
        final categoryOk = newFilters['category'] == 'الكل' ||
            (service.categoryName ?? '') == newFilters['category'];

        final servicePrice =
            service.minPrice ?? service.maxPrice ?? 0.0; // قيمة تقريبية
        final priceOk = servicePrice >= (newFilters['minPrice'] as double) &&
            servicePrice <= (newFilters['maxPrice'] as double);

        final ratingOk =
            (service.rating ?? 0.0) >= (newFilters['minRating'] as double);

        return categoryOk && priceOk && ratingOk;
      }).toList();
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        currentFilters: _filters,
        onApply: _applyFilters,
      ),
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
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.go(AppRoutes.home),
          ),
          title: Text(
            'جميع الخدمات',
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
              onPressed: _showFilterSheet,
            ),
          ],
        ),
        body: Padding(
          padding: SizeConfig.padding(horizontal: 16, top: 8),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: SizeConfig.ts(16),
              ),
            ),
            SizedBox(height: SizeConfig.h(12)),
            ElevatedButton(
              onPressed: _loadInitial,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBackground,
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_filteredServices.isEmpty) {
      return Center(
        child: Text(
          'لا توجد خدمات مطابقة للبحث الحالي.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: SizeConfig.ts(16),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: SizeConfig.w(16),
        mainAxisSpacing: SizeConfig.h(20),
      ),
      itemCount: _filteredServices.length,
      itemBuilder: (context, index) {
        final service = _filteredServices[index];

        // 👇 نرجّع Map بالـ keys التي يتوقعها ServiceCard
        final double priceValue =
            service.minPrice ?? service.maxPrice ?? 0.0;
        final double ratingValue = service.rating ?? 0.0;

        final serviceMap = {
          'title': service.title,
          'provider': service.categoryName ?? 'مزود خدمة',
          'rating': ratingValue,
          'price': priceValue,
          'imageUrl': service.imageUrl ?? '',
        };

        return ServiceCard(service: serviceMap);
      },
    );
  }
}
