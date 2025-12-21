// lib/features/user/home/presentation/search_view.dart

import 'package:beitak_app/core/cache/locations_cache.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/constants/fixed_service_categories.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/features/user/home/presentation/search_widgets/search_city_picker_sheet.dart';
import 'package:beitak_app/features/user/home/presentation/search_widgets/search_recent_store.dart';
import 'package:beitak_app/features/user/home/presentation/search_widgets/search_sections.dart';
import 'package:beitak_app/features/user/home/presentation/search_widgets/search_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';
import 'package:dio/dio.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _controller = TextEditingController();
  final _recent = RecentSearchStore.instance;

  CityOption? _selectedCity;

  @override
  void initState() {
    super.initState();
    _prefillCityFromProfileIfLoggedIn();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.textPrimary,
      ),
    );
  }

  Future<void> _prefillCityFromProfileIfLoggedIn() async {
    try {
      final cityId = await _fetchProfileCityId();
      if (!mounted || cityId == null) return;

      final cities = await LocationsCache.getCities();
      CityOption? match;
      for (final c in cities) {
        if (c.id == cityId) {
          match = c;
          break;
        }
      }
      if (!mounted || match == null) return;

      setState(() => _selectedCity = match);
    } catch (_) {}
  }

  Future<int?> _fetchProfileCityId() async {
    final Dio dio = ApiClient.dio;

    try {
      final res = await dio.get(ApiConstants.authProfile);
      final root = res.data;

      if (root is Map) {
        final data = root['data'];
        if (data is Map) {
          final user = data['user'] ?? data;
          if (user is Map) {
            final v = user['city_id'];
            if (v is num) return v.toInt();
            return int.tryParse(v?.toString() ?? '');
          }
        }
      }
    } catch (_) {}

    try {
      final res = await dio.get(ApiConstants.userProfile);
      final root = res.data;

      if (root is Map) {
        final data = root['data'];
        if (data is Map) {
          final user = data['user'] ?? data;
          if (user is Map) {
            final v = user['city_id'];
            if (v is num) return v.toInt();
            return int.tryParse(v?.toString() ?? '');
          }
        }
      }
    } catch (_) {}

    return null;
  }

  // ============================================================
  // ✅ NEW: Detect category_key from Arabic query (strong improvement)
  // ============================================================
  String? _detectCategoryKeyFromArabic(String text) {
    final t = text.trim();
    if (t.isEmpty) return null;

    // ✅ Normalize (hamza forms, ta marbuta, alif maqsura, tatweel, tashkeel)
    final normalized = t
        .replaceAll('ـ', '')
        .replaceAll(RegExp(r'[\u064B-\u0652]'), '') // تشكيل
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .trim();

    // ✅ category_key values MUST match your internal keys (underscore)
    // and should align with categoriesIdMapProvider output keys.
    const map = <String, String>{
      // Cleaning
      'تنظيف': 'cleaning',
      'نظافه': 'cleaning',
      'تنظيف المنازل': 'cleaning',
      'تنظيف البيت': 'cleaning',
      'تنظيف منزل': 'cleaning',

      // Plumbing
      'سباكه': 'plumbing',
      'سباك': 'plumbing',
      'مواسرجي': 'plumbing',
      'مواسير': 'plumbing',

      // Electrical  (✅ align with categoriesIdMapProvider: out['electricity'])
      'كهرباء': 'electricity',
      'كهربائي': 'electricity',

      // Painting (⚠️ ensure mapping exists in categoriesIdMapProvider)
      'رسم': 'painting',
      'دهان': 'painting',
      'دهانات': 'painting',
      'صبغ': 'painting',

      // Appliance Repair (✅ align with categoriesIdMapProvider: out['appliance_maintenance'])
      'اصلاح الاجهزه': 'appliance_maintenance',
      'تصليح الاجهزه': 'appliance_maintenance',
      'صيانه الاجهزه': 'appliance_maintenance',
      'صيانة الاجهزه': 'appliance_maintenance',
      'اصلاح الأجهزة': 'appliance_maintenance',
      'تصليح الأجهزة': 'appliance_maintenance',
      'صيانة الأجهزة': 'appliance_maintenance',
      'صيانه الأجهزة': 'appliance_maintenance',

      // General Maintenance (✅ align with categoriesIdMapProvider: out['home_maintenance'])
      'صيانه عامه': 'home_maintenance',
      'صيانة عامه': 'home_maintenance',
      'صيانة عامة': 'home_maintenance',
      'صيانه عامة': 'home_maintenance',
    };

    // ✅ IMPORTANT: removed broad words like "صيانة" and "أجهزة" to avoid false positives.

    // 1) Exact match first
    final exact = map[normalized];
    if (exact != null) return exact;

    // 2) Contains match (e.g. "تنظيف شقة", "سباك حمام")
    for (final entry in map.entries) {
      if (normalized.contains(entry.key)) return entry.value;
    }

    return null;
  }

  // ============================================================
  // ✅ UPDATED: If text matches known category, open via category_key
  // ============================================================
  void _goBrowseWithText(String displayText) {
  final text = displayText.trim();

  if (_selectedCity == null) {
    _toast('الرجاء اختيار المحافظة أولاً');
    return;
  }
  if (text.isEmpty) {
    _toast('الرجاء إدخال الخدمة المطلوبة');
    return;
  }

  _recent.add(text);

  final categoryKey = FixedServiceCategories.keyFromAnyString(text);

  final qp = <String, String>{
    'city_id': _selectedCity!.id.toString(),
    if (categoryKey != null) 'category_key': categoryKey,
    if (categoryKey == null) 'q': text,
  };

  context.push(Uri(path: AppRoutes.browseServices, queryParameters: qp).toString());
}
  void _goBrowseWithCategoryKey({
    required String categoryKey,
    required String displayTextForRecent,
  }) {
    if (_selectedCity == null) {
      _toast('الرجاء اختيار المحافظة أولاً');
      return;
    }

    final key = categoryKey.trim();
    if (key.isEmpty) return;

    _recent.add(displayTextForRecent);

    final qp = <String, String>{
      'city_id': _selectedCity!.id.toString(),
      'category_key': key,
    };

    context.push(
      Uri(path: AppRoutes.browseServices, queryParameters: qp).toString(),
    );
  }

  Future<void> _pickCity() async {
    final picked = await showModalBottomSheet<CityOption?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SearchCityPickerSheet(
        selectedCityId: _selectedCity?.id,
      ),
    );

    if (!mounted) return;

    if (picked != null) {
      setState(() => _selectedCity = picked);
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
          title: Text(
            'بحث',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: SizeConfig.ts(18),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: SizeConfig.padding(all: 16),
            children: [
              SearchQueryField(
                controller: _controller,
                onSubmitted: _goBrowseWithText,
              ),
              SizeConfig.v(12),
              SearchLocationChip(
                title: _selectedCity?.name ?? 'اختر المحافظة *',
                onTap: _pickCity,
                onClear: null,
              ),
              SizeConfig.v(18),

              ValueListenableBuilder<List<String>>(
                valueListenable: _recent.listenable,
                builder: (_, list, __) {
                  if (list.isEmpty) return const SizedBox.shrink();
                  return SearchSection(
                    title: 'عمليات البحث الأخيرة',
                    child: SearchList(
                      items: list,
                      leading: Icons.history_rounded,
                      onTap: (t) {
                        _controller.text = t;
                        _controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: t.length),
                        );
                        _goBrowseWithText(t);
                      },
                      onRemove: (t) => _recent.remove(t),
                    ),
                  );
                },
              ),

              SizeConfig.v(16),

              SearchSection(
                title: 'خدمات شائعة',
                child: PopularServicesList(
                  onPick: (item) {
                    _goBrowseWithCategoryKey(
                      categoryKey: item.categoryKey,
                      displayTextForRecent: item.label,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
