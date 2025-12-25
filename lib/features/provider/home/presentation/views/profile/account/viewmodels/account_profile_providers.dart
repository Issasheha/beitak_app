import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'account_edit_controller.dart';
import 'account_edit_state.dart';

final accountEditControllerProvider =
    StateNotifierProvider.autoDispose<AccountEditController, AsyncValue<AccountEditState>>(
  (ref) {
    // ✅ خليه عايش شوي حتى لو طلعت من الصفحة ورجعت بسرعة
    // هذا يقلل reload + API calls ويخفف الثقل
    final link = ref.keepAlive();

    // مدة الكاش (عدّلها براحتك)
    final timer = Timer(const Duration(minutes: 2), link.close);

    ref.onDispose(timer.cancel);

    return AccountEditController(ref);
  },
);
