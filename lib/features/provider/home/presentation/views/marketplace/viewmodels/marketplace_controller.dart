import 'package:beitak_app/features/provider/home/data/datasources/marketplace_remote_data_source_impl.dart';
import 'package:beitak_app/features/provider/home/domain/repositories/marketplace_repository.dart';
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
    state = state.copyWith(uiMessage: null);
  }

  void _emitUiMessage(String msg) {
    final m = msg.trim();
    if (m.isEmpty) return;
    state = state.copyWith(uiMessage: m);
  }

  String _joinNonNullValues(List<dynamic>? values) {
    if (values == null || values.isEmpty) return '';
    final cleaned = values
        .where((e) => e != null)
        .map((e) => e.toString().trim())
        .where((s) => s.isNotEmpty && s.toLowerCase() != 'null')
        .toList();
    return cleaned.join('، ');
  }

  String _prettyDate(String iso) {
    final p = iso.split('-');
    if (p.length != 3) return iso;
    return '${p[2]}/${p[1]}/${p[0]}';
  }

  bool _looksArabic(String s) => RegExp(r'[\u0600-\u06FF]').hasMatch(s);

  String _friendlyAcceptMessage(Object e) {
    if (e is MarketplaceApiException) {
      final code = (e.code ?? '').trim();
      final msg = e.message.trim();

      // لو الباك رجّع عربي (جاهز)
      if (msg.isNotEmpty && _looksArabic(msg)) return msg;

      switch (code) {
        case 'OUTDATED_REQUEST':
          return 'هذا الطلب قديم: تاريخ الخدمة انتهى ولا يمكن قبوله.';

        case 'OUTDATED_REQUEST_TIME':
          return 'هذا الطلب قديم: وقت الخدمة المحدد مرّ بالفعل ولا يمكن قبوله.';

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
          final yourCats = _joinNonNullValues(e.yourCategories);

          final reqCat = reqCatRaw.toLowerCase() == 'null' ? '' : reqCatRaw;

          // ✅ الحالة اللي عندك باللوج: الاثنين فاضيين فعلياً
          if (reqCat.isEmpty && yourCats.isEmpty) {
            return 'تعذّر قبول الطلب لأن فئة الطلب أو فئات خدماتك غير محددة حالياً.\n'
                'جرّب طلبًا أحدث، أو تأكد من إنشاء خدماتك من جديد بعد تحديث التصنيفات.';
          }

          // إذا الطلب بدون فئة
          if (reqCat.isEmpty) {
            return 'تعذّر قبول الطلب لأن الطلب الحالي لا يحتوي على فئة خدمة محددة.\n'
                'جرّب طلبًا آخر أو تواصل مع الدعم.';
          }

          // إذا المزود بدون فئات
          if (yourCats.isEmpty) {
            return 'لا يمكنك قبول هذا الطلب لأن حسابك غير مرتبط بأي فئة خدمات.\n'
                'اذهب إلى: خدماتي → أنشئ خدمة واحدة على الأقل داخل فئة صحيحة ثم أعد المحاولة.';
          }

          return 'لا يمكنك قبول هذا الطلب لأن فئة الطلب لا تطابق فئات خدماتك.\n'
              'فئة الطلب: $reqCat\n'
              'فئاتك: $yourCats\n'
              'عدّل فئات خدماتك أو اختر طلبًا ضمن نفس الفئة.';

        default:
          // لا نطلع إنجليزي للمستخدم
          return 'تعذر قبول الطلب حالياً. حاول مرة أخرى.';
      }
    }

    return 'فشل قبول الطلب، حاول مرة أخرى';
  }

  Future<void> load({bool refresh = false}) async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      uiMessage: null,
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
      final hasMore = result.page < result.totalPages;

      state = state.copyWith(
        isLoading: false,
        errorMessage: null,
        allRequests: ui,
        page: result.page,
        limit: result.limit,
        hasMore: hasMore,
      );
    } catch (e) {
      final msg = (e is MarketplaceApiException)
          ? (e.message.isNotEmpty ? e.message : 'صار خطأ أثناء تحميل الطلبات')
          : 'صار خطأ أثناء تحميل الطلبات';

      state = state.copyWith(
        isLoading: false,
        errorMessage: msg,
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
      final merged = [...state.allRequests, ...newUi];
      final hasMore = result.page < result.totalPages;

      state = state.copyWith(
        isLoadingMore: false,
        loadMoreFailed: false,
        allRequests: merged,
        page: result.page,
        limit: result.limit,
        hasMore: hasMore,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingMore: false,
        loadMoreFailed: true,
      );
    }
  }

  void setSearchQuery(String v) {
    state = state.copyWith(searchQuery: v);
  }

  Future<void> applyFilters(MarketplaceFilters filters) async {
  final old = state.filters;
  state = state.copyWith(filters: filters);

  final serverRelevantChanged =
      old.sort != filters.sort ||
      old.cityId != filters.cityId ||
      old.categoryId != filters.categoryId ||       // ✅ مهم
      old.minBudget != filters.minBudget ||         // ✅ مهم
      old.maxBudget != filters.maxBudget;           // ✅ مهم

  if (serverRelevantChanged) {
    await load(refresh: true);
  }
}


  Future<void> resetFilters() async {
    state = state.copyWith(filters: MarketplaceFilters.initial());
    await load(refresh: true);
  }

  void dismiss(int requestId) {
    state = state.copyWith(
      allRequests: state.allRequests.where((r) => r.id != requestId).toList(),
    );
  }

  Future<void> accept(int requestId) async {
    try {
      await repo.acceptRequest(requestId);

      dismiss(requestId);

      _emitUiMessage('تم قبول الطلب بنجاح ✅ وتم إنشاء حجز لهذا الطلب.');
    } catch (e) {
      _emitUiMessage(_friendlyAcceptMessage(e));
    }
  }
}
