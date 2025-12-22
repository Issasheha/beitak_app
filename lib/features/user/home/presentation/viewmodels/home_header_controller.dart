import 'package:beitak_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'home_header_state.dart';

class HomeHeaderController extends StateNotifier<HomeHeaderState> {
  HomeHeaderController() : super(const HomeHeaderState());

  final AuthLocalDataSourceImpl _authLocal = AuthLocalDataSourceImpl();

  /// ✅ تحديث فوري للاسم (بدون انتظار load/kash)
  void setDisplayName(String name) {
    final cleaned = name.trim();
    state = state.copyWith(
      isLoading: false,
      errorMessage: null,
      displayName: cleaned.isEmpty ? 'ضيف' : cleaned,
    );
  }

  /// ✅ إذا حبيت بعد تعديل الكاش تعمل reload سريع
  Future<void> reloadFromCache() async {
    await load();
  }

  Future<void> load() async {
    // نفس فكرة الكود القديم: الاسم الافتراضي "ضيف"
    String name = 'ضيف';

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final session = await _authLocal.getCachedAuthSession();
      final first = session?.user?.firstName.trim();
      final last = session?.user?.lastName.trim();

      final full = [first, last]
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .join(' ');

      if (full.isNotEmpty) {
        name = full;
      }
    } catch (e) {
      // ما نوقف الـ UI، بس نخزن الخطأ لو احتجناه لاحقاً
      state = state.copyWith(
        isLoading: false,
        displayName: name,
        errorMessage: e.toString(),
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      displayName: name,
    );
  }
}
