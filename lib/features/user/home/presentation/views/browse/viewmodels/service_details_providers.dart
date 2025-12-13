import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'service_details_controller.dart';
import 'service_details_state.dart';

@immutable
class ServiceDetailsArgs {
  const ServiceDetailsArgs({
    required this.serviceId,
    this.lockedCityId,
  });

  final int serviceId;
  final int? lockedCityId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceDetailsArgs &&
          runtimeType == other.runtimeType &&
          serviceId == other.serviceId &&
          lockedCityId == other.lockedCityId;

  @override
  int get hashCode => Object.hash(serviceId, lockedCityId);
}

final serviceDetailsControllerProvider = StateNotifierProvider.autoDispose
    .family<ServiceDetailsController, ServiceDetailsState, ServiceDetailsArgs>(
  (ref, args) {
    final c = ServiceDetailsController(
      serviceId: args.serviceId,
      lockedCityId: args.lockedCityId,
    );
    c.loadAll();
    return c;
  },
);
