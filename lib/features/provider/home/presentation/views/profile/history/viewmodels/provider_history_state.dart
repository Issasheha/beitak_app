import 'package:flutter/foundation.dart';

enum HistoryTab { completed, incomplete, cancelled }

@immutable
class BookingHistoryItem {
  final int id;
  final String bookingNumber;
  final String status;

  final String serviceTitle;
  final String customerName;

  /// raw
  final String bookingDate; // YYYY-MM-DD
  final String bookingTime; // HH:mm:ss

  final double totalPrice;
  final String city;
  final String? area;

  final String? cancellationReason;
  final String? providerNotes;

  /// ✅ NEW: هل المزود قيّم هذا الحجز (من الباك)
  final bool providerRated;

  /// ✅ precomputed (performance)
  final DateTime dateTime;
  final String dateLabel; // dd/mm/yyyy
  final String timeLabel; // HH:mm

  const BookingHistoryItem({
    required this.id,
    required this.bookingNumber,
    required this.status,
    required this.serviceTitle,
    required this.customerName,
    required this.bookingDate,
    required this.bookingTime,
    required this.totalPrice,
    required this.city,
    required this.area,
    required this.cancellationReason,
    required this.providerNotes,
    required this.providerRated,
    required this.dateTime,
    required this.dateLabel,
    required this.timeLabel,
  });

  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled' || status == 'refunded';
  bool get isIncomplete => status == 'incomplete';
}

@immutable
class ProviderHistoryState {
  final HistoryTab activeTab;

  /// ✅ always sorted latest-first
  final List<BookingHistoryItem> bookings;

  /// ✅ pre-split lists (no filtering in UI each rebuild)
  final List<BookingHistoryItem> completed;
  final List<BookingHistoryItem> cancelled;
  final List<BookingHistoryItem> incomplete;

  final int currentPage;
  final bool hasNext;
  final bool isLoadingMore;

  /// ✅ تتبع إرسال التقييم (حتى نعطّل الزر ونغير النص/نخفيه)
  final Set<int> ratedBookingIds;
  final Set<int> submittingRatingIds;

  const ProviderHistoryState({
    required this.activeTab,
    required this.bookings,
    required this.completed,
    required this.cancelled,
    required this.incomplete,
    required this.currentPage,
    required this.hasNext,
    required this.isLoadingMore,
    required this.ratedBookingIds,
    required this.submittingRatingIds,
  });

  factory ProviderHistoryState.initial() {
    return const ProviderHistoryState(
      activeTab: HistoryTab.completed,
      bookings: <BookingHistoryItem>[],
      completed: <BookingHistoryItem>[],
      cancelled: <BookingHistoryItem>[],
      incomplete: <BookingHistoryItem>[],
      currentPage: 1,
      hasNext: false,
      isLoadingMore: false,
      ratedBookingIds: <int>{},
      submittingRatingIds: <int>{},
    );
  }

  ProviderHistoryState copyWith({
    HistoryTab? activeTab,
    List<BookingHistoryItem>? bookings,
    List<BookingHistoryItem>? completed,
    List<BookingHistoryItem>? cancelled,
    List<BookingHistoryItem>? incomplete,
    int? currentPage,
    bool? hasNext,
    bool? isLoadingMore,
    Set<int>? ratedBookingIds,
    Set<int>? submittingRatingIds,
  }) {
    final newBookings = bookings ?? this.bookings;

    List<BookingHistoryItem> c1 = completed ?? this.completed;
    List<BookingHistoryItem> c2 = cancelled ?? this.cancelled;
    List<BookingHistoryItem> c3 = incomplete ?? this.incomplete;

    if (bookings != null &&
        (completed == null && cancelled == null && incomplete == null)) {
      c1 = newBookings.where((b) => b.isCompleted).toList(growable: false);
      c2 = newBookings.where((b) => b.isCancelled).toList(growable: false);
      c3 = newBookings.where((b) => b.isIncomplete).toList(growable: false);
    }

    return ProviderHistoryState(
      activeTab: activeTab ?? this.activeTab,
      bookings: newBookings,
      completed: c1,
      cancelled: c2,
      incomplete: c3,
      currentPage: currentPage ?? this.currentPage,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      ratedBookingIds: ratedBookingIds ?? this.ratedBookingIds,
      submittingRatingIds: submittingRatingIds ?? this.submittingRatingIds,
    );
  }

  List<BookingHistoryItem> get visibleBookings {
    switch (activeTab) {
      case HistoryTab.completed:
        return completed;
      case HistoryTab.incomplete:
        return incomplete;
      case HistoryTab.cancelled:
        return cancelled;
    }
  }

  bool isRated(int bookingId) => ratedBookingIds.contains(bookingId);
  bool isSubmittingRating(int bookingId) => submittingRatingIds.contains(bookingId);
}
