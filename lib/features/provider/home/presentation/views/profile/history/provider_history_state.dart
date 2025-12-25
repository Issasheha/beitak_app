import 'package:flutter/foundation.dart';

enum HistoryTab { completed, incomplete, cancelled }

@immutable
class BookingHistoryItem {
  final int id;
  final String bookingNumber;
  final String status;

  final String serviceTitle;
  final String customerName;

  /// YYYY-MM-DD
  final String bookingDate;

  /// HH:mm:ss
  final String bookingTime;

  final double totalPrice;

  final String city;
  final String? area;

  final String? cancellationReason;

  /// ✅ NEW: to show reason/notes for incomplete
  final String? providerNotes;

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
  });

  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled' || status == 'refunded';
  bool get isIncomplete => status == 'incomplete';

  /// ✅ used for sorting latest first
  DateTime get dateTime {
    try {
      final d = bookingDate.split('-').map((e) => int.tryParse(e) ?? 0).toList();
      final t = bookingTime.split(':').map((e) => int.tryParse(e) ?? 0).toList();

      return DateTime(
        d.isNotEmpty ? d[0] : 1970,
        d.length > 1 ? d[1] : 1,
        d.length > 2 ? d[2] : 1,
        t.isNotEmpty ? t[0] : 0,
        t.length > 1 ? t[1] : 0,
        t.length > 2 ? t[2] : 0,
      );
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  String get dateLabel {
    final parts = bookingDate.split('-');
    if (parts.length == 3) {
      final yyyy = parts[0];
      final mm = parts[1];
      final dd = parts[2];
      if (yyyy.isNotEmpty && mm.isNotEmpty && dd.isNotEmpty) {
        return '$dd/$mm/$yyyy';
      }
    }
    return bookingDate;
  }

  String get timeLabel {
    final parts = bookingTime.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return bookingTime;
  }
}

@immutable
class ProviderHistoryState {
  final HistoryTab activeTab;
  final List<BookingHistoryItem> bookings;

  final int currentPage;
  final bool hasNext;
  final bool isLoadingMore;

  const ProviderHistoryState({
    required this.activeTab,
    required this.bookings,
    required this.currentPage,
    required this.hasNext,
    required this.isLoadingMore,
  });

  factory ProviderHistoryState.initial() {
    return const ProviderHistoryState(
      activeTab: HistoryTab.completed,
      bookings: <BookingHistoryItem>[],
      currentPage: 1,
      hasNext: false,
      isLoadingMore: false,
    );
  }

  ProviderHistoryState copyWith({
    HistoryTab? activeTab,
    List<BookingHistoryItem>? bookings,
    int? currentPage,
    bool? hasNext,
    bool? isLoadingMore,
  }) {
    return ProviderHistoryState(
      activeTab: activeTab ?? this.activeTab,
      bookings: bookings ?? this.bookings,
      currentPage: currentPage ?? this.currentPage,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  List<BookingHistoryItem> get completed =>
      bookings.where((b) => b.isCompleted).toList();

  List<BookingHistoryItem> get cancelled =>
      bookings.where((b) => b.isCancelled).toList();

  /// ✅ NOW: incomplete only (not "anything else")
  List<BookingHistoryItem> get incomplete =>
      bookings.where((b) => b.isIncomplete).toList();
}
