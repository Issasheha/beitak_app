import 'package:flutter/foundation.dart';

/// الفلاتر الثلاثة الموجودة في التابات
enum HistoryTab {
  completed,   // مكتمل
  notCompleted, // غير مكتمل
  cancelled,   // ملغي
}

/// موديل مبسط للعرض في كرت واحد
@immutable
class BookingHistoryItem {
  final int id;
  final String status;          // completed / confirmed / cancelled / ...
  final String serviceTitle;    // اسم الخدمة
  final String customerName;    // اسم العميل
  final String city;            // المدينة
  final String? area;           // المنطقة (اختياري)
  final String dateLabel;       // تاريخ بصيغة جاهزة للعرض
  final String timeLabel;       // وقت بصيغة جاهزة للعرض
  final double totalPrice;
  final String? cancellationReason;

  const BookingHistoryItem({
    required this.id,
    required this.status,
    required this.serviceTitle,
    required this.customerName,
    required this.city,
    required this.area,
    required this.dateLabel,
    required this.timeLabel,
    required this.totalPrice,
    required this.cancellationReason,
  });

  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isNotCompleted => !isCompleted && !isCancelled;
}

@immutable
class ProviderHistoryState {
  final List<BookingHistoryItem> bookings;
  final HistoryTab activeTab;

  /// من الـ API
  final int currentPage;
  final bool hasNext;
  final bool isLoadingMore;

  const ProviderHistoryState({
    required this.bookings,
    required this.activeTab,
    required this.currentPage,
    required this.hasNext,
    required this.isLoadingMore,
  });

  factory ProviderHistoryState.initial() => const ProviderHistoryState(
        bookings: [],
        activeTab: HistoryTab.completed,
        currentPage: 1,
        hasNext: false,
        isLoadingMore: false,
      );

  ProviderHistoryState copyWith({
    List<BookingHistoryItem>? bookings,
    HistoryTab? activeTab,
    int? currentPage,
    bool? hasNext,
    bool? isLoadingMore,
  }) {
    return ProviderHistoryState(
      bookings: bookings ?? this.bookings,
      activeTab: activeTab ?? this.activeTab,
      currentPage: currentPage ?? this.currentPage,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  /// لسهولة الوصول للـ lists حسب التاب
  List<BookingHistoryItem> get completed =>
      bookings.where((b) => b.isCompleted).toList();

  List<BookingHistoryItem> get cancelled =>
      bookings.where((b) => b.isCancelled).toList();

  List<BookingHistoryItem> get notCompleted =>
      bookings.where((b) => b.isNotCompleted).toList();
}
