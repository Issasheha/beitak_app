import 'package:flutter_riverpod/legacy.dart';

import 'home_header_controller.dart';
import 'home_header_state.dart';

final homeHeaderControllerProvider =
    StateNotifierProvider<HomeHeaderController, HomeHeaderState>(
  (ref) => HomeHeaderController()..load(),
);
