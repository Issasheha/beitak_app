// lib/features/provider/home/presentation/views/marketplace/presentation/controllers/marketplace_controller.dart

import 'package:beitak_app/core/constants/fixed_service_categories.dart';
import 'package:beitak_app/core/error/error_text.dart';
import 'package:beitak_app/features/provider/home/presentation/views/marketplace/data/marketplace_remote_data_source_impl.dart';
import 'package:beitak_app/features/provider/home/presentation/views/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/marketplace_filters.dart';
import '../models/marketplace_request_ui_model.dart';
import 'marketplace_state.dart';

class MarketplaceController extends StateNotifier<MarketplaceState> {
  final MarketplaceRepository repo;

  MarketplaceController({required this.repo})
      : super(MarketplaceState.initial());

  void clearUiMessage() {
    if (state.uiMessage == null) return;
    state = state.copyWith(clearUiMessage: true);
  }

  void clearBanner() {
    if (state.bannerMessage == null) return;
    state = state.copyWith(clearBanner: true);
  }

  void _emitUiMessage(String msg) {
    final m = msg.trim();
    if (m.isEmpty) return;
    state = state.copyWith(uiMessage: m);
  }

  bool _looksArabic(String s) => RegExp(r'[\u0600-\u06FF]').hasMatch(s);

  bool _isUnauthorized(Object e) {
    if (e is MarketplaceApiException) {
      if (e.httpStatus == 401) return true;
      final code = (e.code ?? '').toUpperCase().trim();
      if (code == 'UNAUTHORIZED' || code == 'SESSION_EXPIRED') return true;
    }

    if (e is DioException) {
      return e.response?.statusCode == 401;
    }

    return false;
  }

  void _handleUnauthorized() {
    state = state.copyWith(
      sessionExpired: true,
      bannerMessage: 'انتهت الجلسة. الرجاء تسجيل الدخول مرة أخرى.',
    );
  }

  String _prettyDate(String iso) {
    final p = iso.split('-');
    if (p.length != 3) return iso;
    return '${p[2]}/${p[1]}/${p[0]}';
  }

  ({String? date, String? time}) _extractDateTimeFromEnglish(String msg) {
    final dateMatch = RegExp(r'(\d{4}-\d{2}-\d{2})').firstMatch(msg);
    final timeMatch = RegExp(r'(\d{1,2}:\d{2})').firstMatch(msg);

    final date = dateMatch?.group(1);
    final time = timeMatch?.group(1);

    return (date: date, time: time);
  }

  /// ✅ يترجم أي نص (key/slug/English/Arabic) إلى label عربي حسب FixedServiceCategories
  String _catToAr(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return '—';

    if (_looksArabic(s)) return s;

    final key = FixedServiceCategories.keyFromAnyString(s);
    if (key != null) {
      return FixedServiceCategories.labelArFromKey(key);
    }

    return s;
  }

  String _friendlyMarketplaceError(
    Object e, {
    String fallback = 'حدث خطأ غير متوقع. حاول مرة أخرى.',
  }) {
    if (e is MarketplaceApiException) {
      final code = (e.code ?? '').trim().toUpperCase();
      final msg = e.message.trim();

      if (msg.isNotEmpty && _looksArabic(msg)) return msg;

      switch (code) {
        case 'SESSION_EXPIRED':
        case 'UNAUTHORIZED':
          return 'انتهت الجلسة. الرجاء تسجيل الدخول مرة أخرى.';

        case 'OUTDATED_REQUEST':
          return 'هذا الطلب قديم: تاريخ الخدمة انتهى ولا يمكن قبوله.';
        case 'OUTDATED_REQUEST_TIME':
          return 'هذا الطلب قديم: وقت الخدمة المحدد مرّ بالفعل ولا يمكن قبوله.';

        case 'PROVIDER_UNAVAILABLE':
          final dt = _extractDateTimeFromEnglish(msg);
          final dateTxt = (dt.date == null || dt.date!.trim().isEmpty)
              ? ''
              : ' بتاريخ ${_prettyDate(dt.date!)}';
          final timeTxt = (dt.time == null || dt.time!.trim().isEmpty)
              ? ''
              : ' الساعة ${dt.time!}';
          if (dateTxt.isNotEmpty || timeTxt.isNotEmpty) {
            return 'لا يمكنك قبول هذا الطلب لأنك غير متاح$dateTxt$timeTxt.';
          }
          return 'لا يمكنك قبول هذا الطلب لأنك غير متاح في هذا الموعد.';

        case 'DATE_CONFLICT':
          final d = (e.conflictingDate ?? '').trim();
          final bn = (e.existingBookingNumber ?? '').trim();
          final dateTxt = d.isEmpty ? '' : ' بتاريخ ${_prettyDate(d)}';
          final bnTxt = bn.isEmpty ? '' : '\nرقم الحجز: $bn';
          return 'لا يمكنك قبول هذا الطلب لأن لديك حجزًا مؤكدًا$dateTxt.$bnTxt';

        case 'CATEGORY_MISMATCH':
          final reqCatRaw = (e.requestCategory == null)
              ? ''
              : e.requestCategory.toString().trim();
          final reqCatClean = reqCatRaw.toLowerCase() == 'null' ? '' : reqCatRaw;
          final reqCatAr = reqCatClean.isEmpty ? '' : _catToAr(reqCatClean);

          final rawYour = e.yourCategories ?? const [];
          final yourCatsArList = rawYour
              .where((x) => x != null)
              .map((x) => x.toString().trim())
              .where((s) => s.isNotEmpty && s.toLowerCase() != 'null')
              .map(_catToAr)
              .toSet()
              .toList();

          final yourCatsAr = yourCatsArList.join('، ');

          if (reqCatAr.isEmpty && yourCatsAr.isEmpty) {
            return 'تعذّر قبول الطلب لأن فئة الطلب أو فئات خدماتك غير محددة حالياً.\n'
                'جرّب طلبًا أحدث، أو تأكد من إنشاء خدماتك من جديد بعد تحديث التصنيفات.';
          }

          if (reqCatAr.isEmpty) {
            return 'تعذّر قبول الطلب لأن الطلب الحالي لا يحتوي على فئة خدمة محددة.\n'
                'جرّب طلبًا آخر أو تواصل مع الدعم.';
          }

          if (yourCatsAr.isEmpty) {
            return 'لا يمكنك قبول هذا الطلب لأن حسابك غير مرتبط بأي فئة خدمات.\n'
                'اذهب إلى: خدماتي → أنشئ خدمة واحدة على الأقل داخل فئة صحيحة ثم أعد المحاولة.';
          }

          return 'لا يمكنك قبول هذا الطلب لأن فئة الطلب لا تطابق فئات خدماتك.\n'
              'فئة الطلب: $reqCatAr\n'
              'فئاتك: $yourCatsAr\n'
              'عدّل فئات خدماتك أو اختر طلبًا ضمن نفس الفئة.';

        case 'ALREADY_ACCEPTED':
          return 'هذا الطلب تم قبوله مسبقاً ولم يعد متاحاً.';
        case 'NOT_FOUND':
        case 'REQUEST_NOT_FOUND':
          return 'هذا الطلب غير موجود أو تم حذفه.';
        case 'FORBIDDEN':
          return 'ليس لديك صلاحية لتنفيذ هذا الإجراء.';
      }

      final t = errorText(e).trim();
      return t.isEmpty ? fallback : t;
    }

    final t = errorText(e).trim();
    return t.isEmpty ? fallback : t;
  }

  String _friendlyAcceptMessage(Object e) {
    return _friendlyMarketplaceError(
      e,
      fallback: 'تعذر قبول الطلب حالياً. حاول مرة أخرى.',
    );
  }

  String _friendlyLoadMessage(Object e) {
    return _friendlyMarketplaceError(
      e,
      fallback: 'صار خطأ أثناء تحميل الطلبات. حاول مرة أخرى.',
    );
  }

  /// ✅ ترتيب داخلي ثابت حسب createdAt (الجديد/القديم)
  List<MarketplaceRequestUiModel> _sortedByCreatedAt(
    List<MarketplaceRequestUiModel> items,
    MarketplaceSort sort,
  ) {
    final list = [...items];
    list.sort(
      (a, b) => sort == MarketplaceSort.newest
          ? b.createdAt.compareTo(a.createdAt)
          : a.createdAt.compareTo(b.createdAt),
    );
    return list;
  }

  Future<void> load({bool refresh = false}) async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearBanner: refresh,
      clearUiMessage: true,
      sessionExpired: false,
      page: 1,
      hasMore: false,
      isLoadingMore: false,
      loadMoreFailed: false,
      allRequests: refresh ? const [] : state.allRequests,
    );

    try {
      final result = await repo.getMarketplaceRequests(
        page: 1,
        limit: state.limit,
        filters: state.filters,
      );

      final ui =
          result.items.map(MarketplaceRequestUiModel.fromEntity).toList();

      // ✅ مهم: حتى لو السيرفر رتّب حسب تاريخ الخدمة
      final fixedSorted = _sortedByCreatedAt(ui, state.filters.sort);

      final hasMore = result.page < result.totalPages;

      state = state.copyWith(
        isLoading: false,
        sessionExpired: false,
        clearBanner: true,
        allRequests: fixedSorted,
        page: result.page,
        limit: result.limit,
        hasMore: hasMore,
        clearError: true,
      );
    } catch (e) {
      if (_isUnauthorized(e)) {
        _handleUnauthorized();
        state = state.copyWith(isLoading: false);
        return;
      }

      final msg = _friendlyLoadMessage(e);

      state = state.copyWith(
        isLoading: false,
        errorMessage: msg,
        bannerMessage: msg,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, loadMoreFailed: false);

    try {
      final nextPage = state.page + 1;

      final result = await repo.getMarketplaceRequests(
        page: nextPage,
        limit: state.limit,
        filters: state.filters,
      );

      final newUi =
          result.items.map(MarketplaceRequestUiModel.fromEntity).toList();

      // ✅ دمج ثم ترتيب حسب createdAt
      final merged = _sortedByCreatedAt(
        [...state.allRequests, ...newUi],
        state.filters.sort,
      );

      final hasMore = result.page < result.totalPages;

      state = state.copyWith(
        isLoadingMore: false,
        loadMoreFailed: false,
        sessionExpired: false,
        allRequests: merged,
        page: result.page,
        limit: result.limit,
        hasMore: hasMore,
      );
    } catch (e) {
      if (_isUnauthorized(e)) {
        _handleUnauthorized();
        state = state.copyWith(isLoadingMore: false);
        return;
      }

      final msg = _friendlyLoadMessage(e);

      state = state.copyWith(
        isLoadingMore: false,
        loadMoreFailed: true,
        bannerMessage: msg,
      );
    }
  }

  void setSearchQuery(String v) {
    state = state.copyWith(searchQuery: v);
  }

  Future<void> applyFilters(MarketplaceFilters filters) async {
    // ✅ حماية: نطاق سعر غير منطقي (min > max)
    if (filters.minBudget != null &&
        filters.maxBudget != null &&
        filters.minBudget! > filters.maxBudget!) {
      _emitUiMessage('نطاق السعر غير منطقي: "من" يجب أن تكون أقل أو تساوي "إلى".');
      return;
    }

    final old = state.filters;
    state = state.copyWith(filters: filters);

    final serverRelevantChanged =
        old.sort != filters.sort ||
        old.cityId != filters.cityId ||
        old.categoryId != filters.categoryId ||
        old.minBudget != filters.minBudget ||
        old.maxBudget != filters.maxBudget;

    if (serverRelevantChanged) {
      await load(refresh: true);
    }
  }

  Future<void> resetFilters() async {
    state = state.copyWith(
      filters: MarketplaceFilters.initial(),
      searchQuery: '', // ✅ كمان نرجّع البحث افتراضي
    );
    await load(refresh: true);
  }

  void dismiss(int requestId) {
    state = state.copyWith(
      allRequests: state.allRequests.where((r) => r.id != requestId).toList(),
    );
  }

  bool isAccepting(int requestId) => state.acceptingIds.contains(requestId);

  Future<void> accept(int requestId) async {
    if (state.acceptingIds.contains(requestId)) return;

    state = state.copyWith(
      acceptingIds: {...state.acceptingIds, requestId},
    );

    try {
      await repo.acceptRequest(requestId);

      dismiss(requestId);

      state = state.copyWith(
        acceptingIds: {...state.acceptingIds}..remove(requestId),
        sessionExpired: false,
      );

      _emitUiMessage('تم قبول الطلب بنجاح ✅ وتم إنشاء حجز لهذا الطلب.');
    } catch (e) {
      if (_isUnauthorized(e)) {
        _handleUnauthorized();
        state = state.copyWith(
          acceptingIds: {...state.acceptingIds}..remove(requestId),
        );
        return;
      }

      state = state.copyWith(
        acceptingIds: {...state.acceptingIds}..remove(requestId),
      );

      _emitUiMessage(_friendlyAcceptMessage(e));
    }
  }
}
