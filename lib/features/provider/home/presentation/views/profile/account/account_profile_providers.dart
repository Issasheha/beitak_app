import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'account_edit_controller.dart';
import 'account_edit_state.dart';

final accountEditControllerProvider =
    StateNotifierProvider.autoDispose<AccountEditController, AsyncValue<AccountEditState>>(
  (ref) => AccountEditController(),
);
