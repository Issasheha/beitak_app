import 'package:flutter/foundation.dart';

import 'package:beitak_app/features/user/home/presentation/views/my_service/models/booking_list_item.dart';

/// نفس الترتيب القديم:
/// archive, pending, upcoming
enum MyServicesTab { archive, pending, upcoming }

@immutable
class TabBookingState {
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final List<BookingListItem> items;

  const TabBookingState({
    this.page = 1,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.items = const [],
  });

  TabBookingState copyWith({
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    List<BookingListItem>? items,
  }) {
    return TabBookingState(
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      items: items ?? this.items,
    );
  }
}

@immutable
class MyServicesState {
  final Map<MyServicesTab, TabBookingState> tabs;

  const MyServicesState({required this.tabs});

  factory MyServicesState.initial() {
    return const MyServicesState(
      tabs: {
        MyServicesTab.archive: TabBookingState(),
        MyServicesTab.pending: TabBookingState(),
        MyServicesTab.upcoming: TabBookingState(),
      },
    );
  }

  TabBookingState tab(MyServicesTab tabKey) => tabs[tabKey]!;

  MyServicesState copyWithTab(MyServicesTab tabKey, TabBookingState newState) {
    final updated = Map<MyServicesTab, TabBookingState>.from(tabs);
    updated[tabKey] = newState;
    return MyServicesState(tabs: updated);
  }

  List<BookingListItem> tabItems(MyServicesTab tabKey) => tab(tabKey).items;
}
