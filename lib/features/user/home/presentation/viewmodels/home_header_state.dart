import 'package:flutter/foundation.dart';

@immutable
class HomeHeaderState {
  /// هل ما زال بتحميل الاسم من الكاش؟
  final bool isLoading;

  /// اسم المستخدم الظاهر في الهيدر
  final String displayName;

  /// ممكن نستخدمها لاحقاً لو حابين نظهر رسالة خطأ
  final String? errorMessage;

  const HomeHeaderState({
    this.isLoading = false,
    this.displayName = '...',
    this.errorMessage,
  });

  HomeHeaderState copyWith({
    bool? isLoading,
    String? displayName,
    String? errorMessage,
  }) {
    return HomeHeaderState(
      isLoading: isLoading ?? this.isLoading,
      displayName: displayName ?? this.displayName,
      errorMessage: errorMessage,
    );
  }
}
