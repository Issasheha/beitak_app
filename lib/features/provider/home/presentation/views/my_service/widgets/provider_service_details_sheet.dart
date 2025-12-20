import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/models/provider_service_model.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/pages/provider_edit_service_view.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/providers/provider_my_services_provider.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/widgets/provider_package_tile.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProviderServiceDetailsSheet extends ConsumerStatefulWidget {
  final ProviderServiceModel service;
  final int initialTab; // 0 details, 1 packages

  const ProviderServiceDetailsSheet({
    super.key,
    required this.service,
    this.initialTab = 0,
  });

  @override
  ConsumerState<ProviderServiceDetailsSheet> createState() =>
      _ProviderServiceDetailsSheetState();
}

class _ProviderServiceDetailsSheetState
    extends ConsumerState<ProviderServiceDetailsSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  String _arabicCategory() {
    final cat = (widget.service.categoryOther ?? '').trim();
    if (cat.isNotEmpty) return cat;
    return widget.service.name;
  }

  String _priceText() {
    final p = widget.service.basePrice.toStringAsFixed(0);
    if (widget.service.priceType == 'hourly') return '$p د.أ / ساعة';
    return '$p د.أ';
  }

  Future<bool> _confirmDelete() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف الخدمة'),
          content: Text(
            'هل أنت متأكد أنك تريد حذف هذه الخدمة؟\nلا يمكن التراجع عن هذا الإجراء.',
            style: AppTextStyles.body14.copyWith(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'حذف',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
    return res == true;
  }

  Future<void> _deleteService() async {
    if (_deleting) return;

    final ok = await _confirmDelete();
    if (!ok) return;

    setState(() => _deleting = true);

    try {
      await ApiClient.dio.delete(
        ApiConstants.serviceDetails(widget.service.id),
        options: Options(contentType: Headers.jsonContentType),
      );

      // ✅ Refresh list
      ref.invalidate(providerMyServicesProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حذف الخدمة بنجاح',
            style: AppTextStyles.body14.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.lightGreen,
        ),
      );

      // ✅ Close sheet after delete
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر حذف الخدمة. حاول مرة أخرى.',
            style: AppTextStyles.body14.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.82;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AbsorbPointer(
        absorbing: _deleting,
        child: Container(
          height: height,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: SizeConfig.h(14),
              left: SizeConfig.w(16),
              right: SizeConfig.w(16),
              bottom: MediaQuery.of(context).viewInsets.bottom + 14,
            ),
            child: Column(
              children: [
                // handle
                Center(
                  child: Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizeConfig.v(12),

                // title row (بدون Badge نشطة/غير نشطة)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _arabicCategory(),
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body16.copyWith(
                          fontSize: SizeConfig.ts(16.5),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),

                SizeConfig.v(10),

                // tabs
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: _tab,
                    labelColor: AppColors.lightGreen,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicator: BoxDecoration(
                      color: AppColors.lightGreen.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    labelStyle:
                        AppTextStyles.body14.copyWith(fontWeight: FontWeight.w700),
                    unselectedLabelStyle:
                        AppTextStyles.body14.copyWith(fontWeight: FontWeight.w600),
                    tabs: [
                      const Tab(text: 'تفاصيل الخدمة'),
                      Tab(text: 'الباقات (${widget.service.packages.length})'),
                    ],
                  ),
                ),

                SizeConfig.v(12),

                Expanded(
                  child: TabBarView(
                    controller: _tab,
                    children: [
                      _detailsTab(context),
                      _packagesTab(context),
                    ],
                  ),
                ),

                SizeConfig.v(10),

                // Main actions row
                Row(
                  children: [
                   Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final res = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProviderEditServiceView(service: widget.service),
                            ),
                          );

                          if (res == true && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'تم تعديل الخدمة بنجاح',
                                  style: AppTextStyles.body14.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                backgroundColor: AppColors.lightGreen,
                              ),
                            );

                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: SizeConfig.padding(vertical: 12),
                        ),
                        child: Text(
                          'تعديل الخدمة',
                          style: AppTextStyles.body14.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                     Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.lightGreen,
                          side: const BorderSide(color: AppColors.lightGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: SizeConfig.padding(vertical: 12),
                        ),
                        child: Text(
                          'إغلاق',
                          style: AppTextStyles.body14.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.lightGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizeConfig.v(10),

                // ✅ Delete button (full width, destructive)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _deleteService,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.withValues(alpha: 0.55)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: SizeConfig.padding(vertical: 12),
                    ),
                    child: _deleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'حذف الخدمة',
                            style: AppTextStyles.body14.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.red,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailsTab(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _priceText(),
                style: AppTextStyles.body14.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.view_module_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'عدد الباقات: ${widget.service.packages.length}',
                    style: AppTextStyles.body14.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizeConfig.v(12),
          Text(
            'الوصف',
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(14),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizeConfig.v(6),
          Text(
            (widget.service.description ?? '').trim().isEmpty
                ? '—'
                : widget.service.description!.trim(),
            style: AppTextStyles.body14.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _packagesTab(BuildContext context) {
    final pkgs = widget.service.packages;

    if (pkgs.isEmpty) {
      return Center(
        child: Text(
          'لا توجد باقات لهذه الخدمة حالياً',
          style: AppTextStyles.body14.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: pkgs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => ProviderPackageTile(
        service: widget.service,
        packageIndex: i,
      ),
    );
  }
}
