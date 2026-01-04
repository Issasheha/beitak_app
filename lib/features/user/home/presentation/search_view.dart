import 'dart:io';

import 'package:beitak_app/core/cache/locations_cache.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/constants/fixed_service_categories.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/features/user/home/presentation/search_widgets/ai_voice_search_sheet.dart';
import 'package:beitak_app/features/user/home/presentation/search_widgets/search_city_picker_sheet.dart';
import 'package:beitak_app/features/user/home/presentation/search_widgets/search_recent_store.dart';
import 'package:beitak_app/features/user/home/presentation/search_widgets/search_sections.dart';
import 'package:beitak_app/features/user/home/presentation/search_widgets/search_widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/network/api_client.dart';
import 'package:beitak_app/core/network/api_constants.dart';

import 'package:beitak_app/features/user/home/presentation/providers/ai_search_providers.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final _controller = TextEditingController();
  final _recent = RecentSearchStore.instance;

  CityOption? _selectedCity;

  bool _isPopping = false;
  bool _popInProgress = false;

  bool _aiBusy = false;

  // ✅ Auto voice from query param
  bool _autoVoiceRequested = false;
  bool _autoVoiceHandled = false;

  // ✅ track prefill
  late final Future<void> _prefillFuture;

  @override
  void initState() {
    super.initState();
    _prefillFuture = _prefillCityFromProfileIfLoggedIn();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final qp = GoRouterState.of(context).uri.queryParameters;
    final v = (qp['auto_voice'] ?? '').toLowerCase().trim();
    final wantAuto = (v == '1' || v == 'true');

    _autoVoiceRequested = wantAuto;

    if (wantAuto && !_autoVoiceHandled) {
      _autoVoiceHandled = true;
      Future.microtask(_autoVoiceFlow);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    if (!mounted) return;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(
          SizeConfig.w(16),
          0,
          SizeConfig.w(16),
          bottomInset + SizeConfig.h(16),
        ),
        backgroundColor: AppColors.textPrimary,
      ),
    );
  }

  void _popPerfect() {
    if (_popInProgress) return;
    _popInProgress = true;

    if (mounted) setState(() => _isPopping = true);

    Future.microtask(() {
      if (!mounted) return;
      context.pop();
    });
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

  void _pushBrowse({required String? categoryKey, required String? q}) {
    // ✅ مهم: أي navigation لازم يكون مع mounted
    if (!mounted) return;
    if (_selectedCity == null) return;

    final qp = <String, String>{
      'city_id': _selectedCity!.id.toString(),
      if (categoryKey != null && categoryKey.trim().isNotEmpty)
        'category_key': categoryKey.trim(),
      if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
    };

    context.push(
      Uri(path: AppRoutes.browseServices, queryParameters: qp).toString(),
    );
  }

  Future<bool> _pickCity() async {
    final picked = await showModalBottomSheet<CityOption?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SearchCityPickerSheet(
        selectedCityId: _selectedCity?.id,
      ),
    );

    if (!mounted) return false;
    if (picked != null) {
      setState(() => _selectedCity = picked);
      return true;
    }
    return false;
  }

  // ============================================================
  // ✅ AI-first text flow (safe fallback)
  // ============================================================
  Future<void> _goBrowseWithText(String displayText) async {
    final text = displayText.trim();

    if (_selectedCity == null) {
      await _prefillFuture;
      if (!mounted) return;

      if (_selectedCity == null) {
        final ok = await _pickCity();
        if (!ok) return;
      }
    }

    if (text.isEmpty) {
      _toast('الرجاء إدخال الخدمة المطلوبة');
      return;
    }

    if (_aiBusy) return;
    _aiBusy = true;

    try {
      _recent.add(text);

      final localKey = FixedServiceCategories.keyFromAnyString(text);
      if (localKey != null) {
        _pushBrowse(categoryKey: localKey, q: null);
        return;
      }

      final ai = ref.read(aiSearchControllerProvider);
      final aiRes = await ai.predictText(text);
      if (!mounted) return;

      if (ai.shouldUseAiResult(aiRes)) {
        final key = aiRes.categoryKey.trim();
        if (key.isNotEmpty) {
          _pushBrowse(categoryKey: key, q: null);
          return;
        }
      }

      _pushBrowse(categoryKey: null, q: text);
    } catch (_) {
      if (!mounted) return;
      _pushBrowse(categoryKey: null, q: text);
    } finally {
      _aiBusy = false;
    }
  }

  // ============================================================
  // ✅ Voice flow (used by mic button + auto)
  // ============================================================
  Future<void> _startVoiceSearch() async {
    // بدل سناك بار: جرّب prefill ثم افتح picker لو لسه null
    if (_selectedCity == null) {
      await _prefillFuture;
      if (!mounted) return;

      if (_selectedCity == null) {
        final ok = await _pickCity();
        if (!ok) return;
      }
    }

    if (_aiBusy) return;
    _aiBusy = true;

    try {
      final file = await showModalBottomSheet<File?>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const AiVoiceSearchSheet(),
      );

      if (!mounted || file == null) return;

      final ai = ref.read(aiSearchControllerProvider);
      final aiRes = await ai.predictVoice(file);
      if (!mounted) return;

      if (ai.shouldUseAiResult(aiRes)) {
        _pushBrowse(categoryKey: aiRes.categoryKey, q: null);
        return;
      }

      final recognized = (aiRes.recognizedText ?? '').trim();
      if (recognized.isNotEmpty) {
        _controller.text = recognized;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: recognized.length),
        );
        _pushBrowse(categoryKey: null, q: recognized);
        return;
      }

      _toast('لم يتم التعرف على صوت واضح، جرّبي مرة ثانية.');
    } catch (_) {
      _toast('تعذر البحث بالصوت حالياً.');
    } finally {
      _aiBusy = false;
    }
  }

  Future<void> _autoVoiceFlow() async {
    // ✅ مهم: لا تفتح كيبورد، وابدأ صوت بعد ما تخلص محاولة prefill
    await _prefillFuture;
    if (!mounted) return;

    // لو ما في مدينة، افتح picker مباشرة (بدون سناك)
    if (_selectedCity == null) {
      final ok = await _pickCity();
      if (!ok) return;
    }

    // ابدأ الشيت
    await _startVoiceSearch();
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
    _pushBrowse(categoryKey: key, q: null);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final mq = MediaQuery.of(context);
    final frozenMq = _isPopping ? mq.copyWith(viewInsets: EdgeInsets.zero) : mq;

    return MediaQuery(
      data: frozenMq,
      child: PopScope(
        // ✅ نفس فكرة WillPopScope + _popPerfect
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          _popPerfect();
        },
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
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
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: SizeConfig.padding(all: 16),
                children: [
                  SearchQueryField(
                    controller: _controller,
                    onSubmitted: (t) => _goBrowseWithText(t),
                    onMicTap: _startVoiceSearch,
                    micLoading: _aiBusy,

                    // ✅ NEW: إذا داخلين من auto_voice لا تفتح كيبورد
                    autofocus: !_autoVoiceRequested,
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
