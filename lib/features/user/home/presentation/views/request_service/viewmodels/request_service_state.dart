// lib/features/user/home/presentation/views/request_service/viewmodels/request_service_state.dart

import 'dart:io';

import '../models/city_model.dart';
import '../models/location_models.dart' show AreaModel;
import '../models/service_type_option.dart';
import '../widgets/date_selection_section.dart';

const _sentinel = Object();

class RequestServiceState {
  // Session / user
  final bool sessionLoading;
  final bool isGuest;
  final String? sessionName;
  final String? sessionPhone;

  // Submit loading
  final bool submitting;

  // Service type
  final ServiceTypeOption? selectedServiceType;
  final Map<String, int> slugToCategoryId;
  final String? categoryError;

  // Date & time
  final ServiceDateType dateType;
  final DateTime? otherDate;
  final String? selectedHour; // "HH:00"

  // Cities
  final bool citiesLoading;
  final String? citiesError;
  final List<CityModel> cities;
  final CityModel? selectedCity;

  // Areas
  final bool areasLoading;
  final String? areasError;
  final List<AreaModel> areas;
  final AreaModel? selectedArea;

  // Attachments
  final List<File> files;

  const RequestServiceState({
    this.sessionLoading = false,
    this.isGuest = true,
    this.sessionName,
    this.sessionPhone,
    this.submitting = false,
    this.selectedServiceType,
    this.slugToCategoryId = const {},
    this.categoryError,
    this.dateType = ServiceDateType.today,
    this.otherDate,
    this.selectedHour,
    this.citiesLoading = false,
    this.citiesError,
    this.cities = const [],
    this.selectedCity,
    this.areasLoading = false,
    this.areasError,
    this.areas = const [],
    this.selectedArea,
    this.files = const [],
  });

  RequestServiceState copyWith({
    bool? sessionLoading,
    bool? isGuest,
    Object? sessionName = _sentinel,
    Object? sessionPhone = _sentinel,
    bool? submitting,
    Object? selectedServiceType = _sentinel,
    Map<String, int>? slugToCategoryId,
    Object? categoryError = _sentinel,
    ServiceDateType? dateType,
    Object? otherDate = _sentinel,
    Object? selectedHour = _sentinel,
    bool? citiesLoading,
    Object? citiesError = _sentinel,
    List<CityModel>? cities,
    Object? selectedCity = _sentinel,
    bool? areasLoading,
    Object? areasError = _sentinel,
    List<AreaModel>? areas,
    Object? selectedArea = _sentinel,
    List<File>? files,
  }) {
    return RequestServiceState(
      sessionLoading: sessionLoading ?? this.sessionLoading,
      isGuest: isGuest ?? this.isGuest,
      sessionName:
          sessionName == _sentinel ? this.sessionName : sessionName as String?,
      sessionPhone:
          sessionPhone == _sentinel ? this.sessionPhone : sessionPhone as String?,
      submitting: submitting ?? this.submitting,
      selectedServiceType: selectedServiceType == _sentinel
          ? this.selectedServiceType
          : selectedServiceType as ServiceTypeOption?,
      slugToCategoryId: slugToCategoryId ?? this.slugToCategoryId,
      categoryError: categoryError == _sentinel
          ? this.categoryError
          : categoryError as String?,
      dateType: dateType ?? this.dateType,
      otherDate: otherDate == _sentinel ? this.otherDate : otherDate as DateTime?,
      selectedHour:
          selectedHour == _sentinel ? this.selectedHour : selectedHour as String?,
      citiesLoading: citiesLoading ?? this.citiesLoading,
      citiesError: citiesError == _sentinel
          ? this.citiesError
          : citiesError as String?,
      cities: cities ?? this.cities,
      selectedCity: selectedCity == _sentinel
          ? this.selectedCity
          : selectedCity as CityModel?,
      areasLoading: areasLoading ?? this.areasLoading,
      areasError:
          areasError == _sentinel ? this.areasError : areasError as String?,
      areas: areas ?? this.areas,
      selectedArea: selectedArea == _sentinel
          ? this.selectedArea
          : selectedArea as AreaModel?,
      files: files ?? this.files,
    );
  }

  bool get showNameField => isGuest || sessionName == null;
  bool get showPhoneField => isGuest || sessionPhone == null;
}
