import 'package:flutter_riverpod/legacy.dart';

import 'service_details_controller.dart';
import 'service_details_state.dart';

final serviceDetailsControllerProvider =
    StateNotifierProvider<ServiceDetailsController, ServiceDetailsState>(
  (ref) => ServiceDetailsController(),
);
