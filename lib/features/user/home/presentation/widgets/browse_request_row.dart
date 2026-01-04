import 'package:beitak_app/core/cache/locations_cache.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/search_normalizer.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/features/user/home/presentation/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BrowseRequestRow extends StatefulWidget {
  const BrowseRequestRow({super.key});

  @override
  State<BrowseRequestRow> createState() => _BrowseRequestRowState();
}

class _BrowseRequestRowState extends State<BrowseRequestRow> {
  final _serviceController = TextEditingController();
  final ValueNotifier<bool> _canSearch = ValueNotifier<bool>(false);

  bool _loadingCities = false;
  String? _citiesError;

  List<CityOption> _cities = const [];
  CityOption? _selectedCity;

  bool _showValidation = false;

  @override
  void initState() {
    super.initState();
    _serviceController.addListener(_recalcCanSearch);
    _fetchCities();
  }

  @override
  void dispose() {
    _serviceController.removeListener(_recalcCanSearch);
    _serviceController.dispose();
    _canSearch.dispose();
    super.dispose();
  }

  void _recalcCanSearch() {
    final hasText = _serviceController.text.trim().isNotEmpty;
    final hasCity = _selectedCity != null;
    final ok = hasText && hasCity;

    if (_canSearch.value != ok) _canSearch.value = ok;
    if (_showValidation) setState(() {}); // لتحديث رسائل الخطأ فوراً
  }

  Future<void> _fetchCities({bool forceRefresh = false}) async {
    setState(() {
      _loadingCities = true;
      _citiesError = null;
    });

    try {
      final parsed = forceRefresh
          ? await LocationsCache.refreshCities()
          : await LocationsCache.getCities();

      setState(() {
        _cities = parsed;
        _selectedCity = null; // لا تفرض محافظة
      });

      _recalcCanSearch();
    } catch (_) {
      setState(() {
        _citiesError = 'تعذر تحميل المحافظات';
        _cities = const [];
        _selectedCity = null;
      });
      _recalcCanSearch();
    } finally {
      if (mounted) setState(() => _loadingCities = false);
    }
  }

  void _goSearch() {
    FocusScope.of(context).unfocus();

    setState(() => _showValidation = true);

    final rawQ = _serviceController.text.trim();
    final cityId = _selectedCity?.id;

    // ✅ إجباري: خدمة + مدينة
    if (rawQ.isEmpty || cityId == null) {
      // بس نخلي الرسائل تظهر بالـ UI
      _recalcCanSearch();
      return;
    }

    final apiQ = SearchNormalizer.normalizeForApi(rawQ);

    final qp = <String, String>{
      'q': apiQ,
      'city_id': cityId.toString(),
    };

    context.push(Uri(path: AppRoutes.browseServices, queryParameters: qp).toString());
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final compact = h < 700;

    final serviceErr = _showValidation && _serviceController.text.trim().isEmpty;
    final cityErr = _showValidation && _selectedCity == null;

    return GlassContainer(
      child: Padding(
        padding: SizeConfig.padding(all: compact ? 12 : 14),
        child: Column(
          children: [
            TextField(
              controller: _serviceController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _goSearch(),
              decoration: InputDecoration(
                hintText: 'اكتب الخدمة المطلوبة (مثال: سباكة، تنظيف)',
                hintStyle: TextStyle(
                  fontSize: SizeConfig.ts(13),
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
                filled: true,
                fillColor: AppColors.cardBackground,
                contentPadding: SizeConfig.padding(
                  horizontal: 14,
                  vertical: compact ? 12 : 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
                  borderSide: BorderSide(
                    color: AppColors.primaryGreen.withValues(alpha: 0.09),
                    width: 1.6,
                  ),
                ),
                errorText: serviceErr ? 'الرجاء إدخال الخدمة' : null,
              ),
            ),

            SizeConfig.v(compact ? 8 : 10),

            if (_loadingCities)
              const LinearProgressIndicator(minHeight: 2)
            else if (_citiesError != null)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _citiesError!,
                      style: TextStyle(fontSize: SizeConfig.ts(12), color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _fetchCities(forceRefresh: true),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              )
            else
              DropdownButtonFormField<CityOption>(
                initialValue: _selectedCity,
                isExpanded: true,
                hint: Text(
                  'اختر المحافظة *',
                  style: TextStyle(
                    fontSize: SizeConfig.ts(13),
                    color: AppColors.textSecondary,
                  ),
                ),
                items: _cities
                    .map((c) => DropdownMenuItem<CityOption>(
                          value: c,
                          child: Text(c.name),
                        ))
                    .toList(),
                onChanged: (v) {
                  setState(() => _selectedCity = v);
                  _recalcCanSearch();
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  contentPadding: SizeConfig.padding(
                    horizontal: 14,
                    vertical: compact ? 12 : 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
                    borderSide: BorderSide(
                      color: AppColors.primaryGreen.withValues(alpha: 0.09),
                      width: 1.6,
                    ),
                  ),
                  errorText: cityErr ? 'الرجاء اختيار المحافظة' : null,
                ),
              ),

            SizeConfig.v(compact ? 10 : 12),

            ValueListenableBuilder<bool>(
              valueListenable: _canSearch,
              builder: (context, enabled, _) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: enabled ? _goSearch : _goSearch, // نسمح بالضغط حتى يطلع validation
                    icon: const Icon(Icons.tune),
                    label: const Text('عرض النتائج'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightGreen,
                      foregroundColor: Colors.white,
                      elevation: enabled ? 4 : 0,
                      shadowColor: AppColors.primaryGreen.withValues(alpha: 0.25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
                      ),
                      padding: SizeConfig.padding(vertical: compact ? 12 : 14),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
