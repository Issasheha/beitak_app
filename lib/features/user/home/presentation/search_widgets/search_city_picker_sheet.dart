import 'package:beitak_app/core/cache/locations_cache.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

import 'package:beitak_app/core/utils/app_text_styles.dart';

/// BottomSheet لاختيار المحافظة فقط (بدون بحث وبدون خيار "بدون محافظة")
class SearchCityPickerSheet extends StatefulWidget {
  const SearchCityPickerSheet({
    super.key,
    required this.selectedCityId,
  });

  final int? selectedCityId;

  @override
  State<SearchCityPickerSheet> createState() => _SearchCityPickerSheetState();
}

class _SearchCityPickerSheetState extends State<SearchCityPickerSheet> {
  List<CityOption> _cities = const [];
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final list = await LocationsCache.getCities();
      if (!mounted) return;
      setState(() {
        _cities = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final height = MediaQuery.of(context).size.height;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: height * 0.72,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(SizeConfig.radius(18)),
          ),
          border: Border.all(
            color: AppColors.borderLight.withValues(alpha: 0.6),
          ),
        ),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.lightGreen),
              )
            : _error
                ? _ErrorState(onRetry: _load)
                : Column(
                    children: [
                      SizedBox(height: SizeConfig.h(10)),
                      Container(
                        width: 46,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.borderLight.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      SizedBox(height: SizeConfig.h(12)),
                      Padding(
                        padding: SizeConfig.padding(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'اختر المحافظة',
                                style: AppTextStyles.sheetTitle.copyWith(
                                  fontSize: SizeConfig.ts(16),
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'إغلاق',
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.close,
                                color: AppColors.textSecondary,
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: SizeConfig.h(6)),
                      Expanded(
                        child: ListView.separated(
                          itemCount: _cities.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color:
                                AppColors.borderLight.withValues(alpha: 0.45),
                          ),
                          itemBuilder: (_, i) {
                            final c = _cities[i];
                            final selected = c.id == widget.selectedCityId;

                            return ListTile(
                              title: Text(
                                c.name,
                                style: AppTextStyles.body14.copyWith(
                                  fontSize: SizeConfig.ts(14),
                                  fontWeight: selected
                                      ? FontWeight.w900
                                      : FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              trailing: selected
                                  ? const Icon(Icons.check_circle,
                                      color: AppColors.lightGreen)
                                  : const Icon(Icons.chevron_left,
                                      color: AppColors.textSecondary),
                              onTap: () => Navigator.pop(context, c),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_city_outlined,
              size: 44,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 10),
            Text(
              'تعذر تحميل المحافظات',
              style: AppTextStyles.body14.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'إعادة المحاولة',
                style: AppTextStyles.body14.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
