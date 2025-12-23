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

  // ✅ NEW: Freeze insets while popping to kill keyboard "flash"
  bool _isPopping = false;
  bool _popInProgress = false;

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

  // ✅ Perfect 1-tap back: no unfocus, freeze insets, pop immediately
  void _popPerfect() {
    if (_popInProgress) return;
    _popInProgress = true;

    if (mounted) {
      setState(() => _isPopping = true);
    }

    // pop on next microtask after rebuild applies MediaQuery freeze
    Future.microtask(() {
      if (!mounted) return;
      context.pop();
    });
  }

  Future<bool> _onWillPop() async {
    _popPerfect();
    return false;
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

    context.push(
      Uri(path: AppRoutes.browseServices, queryParameters: qp).toString(),
    );
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

    final mq = MediaQuery.of(context);

    // ✅ Freeze keyboard insets during pop to eliminate flash completely
    final frozenMq = _isPopping
        ? mq.copyWith(
            viewInsets: EdgeInsets.zero,
            // Optional extra safety (rare cases):
            // viewPadding: mq.viewPadding,
          )
        : mq;

    return MediaQuery(
      data: frozenMq,
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            // ✅ Keep it stable; we handle inset ourselves
            resizeToAvoidBottomInset: false,
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
                onPressed: _popPerfect,
              ),
            ),
            body: SafeArea(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
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
        ),
      ),
    );
  }
}
