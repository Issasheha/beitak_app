import 'package:flutter_riverpod/legacy.dart';

import 'my_services_controller.dart';
import 'my_services_state.dart';

final myServicesControllerProvider =
    StateNotifierProvider<MyServicesController, MyServicesState>(
  (ref) => MyServicesController(),
);
