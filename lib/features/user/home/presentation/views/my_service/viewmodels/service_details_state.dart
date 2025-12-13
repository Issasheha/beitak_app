import 'package:flutter/foundation.dart';

@immutable
class ServiceDetailsState {
  final bool isLoading;
  final bool isCancelling;
  final String? error;
  final Map<String, dynamic>? data;

  const ServiceDetailsState({
    this.isLoading = false,
    this.isCancelling = false,
    this.error,
    this.data,
  });

  ServiceDetailsState copyWith({
    bool? isLoading,
    bool? isCancelling,
    String? error,
    Map<String, dynamic>? data,
  }) {
    return ServiceDetailsState(
      isLoading: isLoading ?? this.isLoading,
      isCancelling: isCancelling ?? this.isCancelling,
      error: error,
      data: data ?? this.data,
    );
  }

  static const empty = ServiceDetailsState();
}
