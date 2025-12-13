import 'package:beitak_app/core/cache/locations_cache.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/search_normalizer.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/features/user/home/presentation/search_widgets/search_city_picker_sheet.dart';
import 'package:beitak_app/features/user/home/presentation/search_widgets/search_recent_store.dart';
import 'package:beitak_app/features/user/home/presentation/search_widgets/search_sections.dart';
import 'package:beitak_app/features/user/home/presentation/search_widgets/search_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ✅ جديد للتعبئة الافتراضية من profile
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
    _prefillCityFromProfileIfLoggedIn(); // ✅ تعديل 1
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

  // ✅ تعديل 1: المدينة الإفتراضية من مدينة المستخدم المسجل بها (إن أمكن)
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
    } catch (_) {
      // تجاهل: ضيف أو مشكلة توكن → المستخدم يختار يدويًا
    }
  }

  Future<int?> _fetchProfileCityId() async {
    final Dio dio = ApiClient.dio;

    // 1) /auth/profile
    try {
      final res = await dio.get(ApiConstants.authProfile);
      final root = res.data;

      if (root is Map) {
        final data = root['data'];
        if (data is Map) {
          // بعض الباك اند يرجع user داخل data
          final user = data['user'] ?? data;
          if (user is Map) {
            final v = user['city_id'];
            if (v is num) return v.toInt();
            return int.tryParse(v?.toString() ?? '');
          }
        }
      }
    } catch (_) {}

    // 2) fallback: /users/profile
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

  void _goBrowseWithText(String displayText) {
    final text = displayText.trim();

    // ✅ إجباري: لازم محافظة
    if (_selectedCity == null) {
      _toast('الرجاء اختيار المحافظة أولاً');
      return;
    }

    // ✅ إجباري: لازم خدمة/نص
    if (text.isEmpty) {
      _toast('الرجاء إدخال الخدمة المطلوبة');
      return;
    }

    final q = SearchNormalizer.normalizeForApi(text);

    _recent.add(text);

    final qp = <String, String>{
      'q': q,
      'city_id': _selectedCity!.id.toString(),
    };

    context.push(Uri(path: AppRoutes.browseServices, queryParameters: qp).toString());
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
                onClear: null, // ✅ ممنوع إزالة المحافظة
              ),

              SizeConfig.v(18),

              // Recent searches
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
                        _controller.selection =
                            TextSelection.fromPosition(TextPosition(offset: t.length));
                        _goBrowseWithText(t);
                      },
                      onRemove: (t) => _recent.remove(t),
                    ),
                  );
                },
              ),

              SizeConfig.v(16),

              // Popular services
              SearchSection(
                title: 'خدمات شائعة',
                child: PopularServicesList(
                  onPick: (displayText) => _goBrowseWithText(displayText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
