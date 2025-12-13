import 'package:beitak_app/features/user/home/presentation/views/browse/widgets/service_details_models.dart';
import '../widgets_service_details/location_models.dart';

class ServiceDetailsState {
  final bool loading;
  final String? error;
  final ServiceDetails? service;

  final DateTime? selectedDate;
  final String? selectedPackageName; // null = بدون باقة

  final bool locLoading;
  final UserLocationProfile? profileLoc;
  final List<CityOption> cities;
  final List<AreaOption> areas;
  final CityOption? selectedCity;
  final AreaOption? selectedArea;

  final bool bookingLoading;
  final String? bookingError;

  const ServiceDetailsState({
    required this.loading,
    required this.error,
    required this.service,
    required this.selectedDate,
    required this.selectedPackageName,
    required this.locLoading,
    required this.profileLoc,
    required this.cities,
    required this.areas,
    required this.selectedCity,
    required this.selectedArea,
    required this.bookingLoading,
    required this.bookingError,
  });

  factory ServiceDetailsState.initial() => const ServiceDetailsState(
        loading: true,
        error: null,
        service: null,
        selectedDate: null,
        selectedPackageName: null,
        locLoading: false,
        profileLoc: null,
        cities: [],
        areas: [],
        selectedCity: null,
        selectedArea: null,
        bookingLoading: false,
        bookingError: null,
      );

  ServiceDetailsState copyWith({
    bool? loading,
    String? error,
    ServiceDetails? service,
    DateTime? selectedDate,
    String? selectedPackageName,
    bool? locLoading,
    UserLocationProfile? profileLoc,
    List<CityOption>? cities,
    List<AreaOption>? areas,
    CityOption? selectedCity,
    AreaOption? selectedArea,
    bool? bookingLoading,
    String? bookingError,
    bool clearError = false,
    bool clearBookingError = false,
  }) {
    return ServiceDetailsState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      service: service ?? this.service,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedPackageName: selectedPackageName ?? this.selectedPackageName,
      locLoading: locLoading ?? this.locLoading,
      profileLoc: profileLoc ?? this.profileLoc,
      cities: cities ?? this.cities,
      areas: areas ?? this.areas,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedArea: selectedArea ?? this.selectedArea,
      bookingLoading: bookingLoading ?? this.bookingLoading,
      bookingError: clearBookingError ? null : (bookingError ?? this.bookingError),
    );
  }

  ServicePackage? get selectedPackage {
    final s = service;
    final name = selectedPackageName;
    if (s == null || name == null) return null;
    try {
      return s.packages.firstWhere((p) => p.name.trim() == name.trim());
    } catch (_) {
      return null;
    }
  }
}
