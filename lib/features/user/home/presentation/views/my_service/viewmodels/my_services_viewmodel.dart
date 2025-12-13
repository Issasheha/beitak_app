// import 'dart:io';
// import 'package:dio/dio.dart';

// import 'package:beitak_app/core/error/exceptions.dart';
// import 'package:beitak_app/core/network/api_client.dart';
// import 'package:beitak_app/features/auth/data/datasources/auth_local_datasource.dart';
// import 'package:beitak_app/features/user/home/presentation/views/my_service/models/booking_list_item.dart';

// enum MyServicesTab { archive, pending, upcoming }

// class _TabState {
//   int page = 1;
//   bool hasMore = true;
//   bool isLoading = false;
//   bool isLoadingMore = false;
//   String? error;

//   final List<BookingListItem> items = [];
// }

// class MyServicesViewModel {
//   final Dio _dio;
//   final AuthLocalDataSource _local;

//   final Map<MyServicesTab, _TabState> _tabs = {
//     MyServicesTab.archive: _TabState(),
//     MyServicesTab.pending: _TabState(),
//     MyServicesTab.upcoming: _TabState(),
//   };

//   MyServicesViewModel({Dio? dio, AuthLocalDataSource? local})
//       : _dio = dio ?? ApiClient.dio,
//         _local = local ?? AuthLocalDataSourceImpl();

//   _TabState state(MyServicesTab tab) => _tabs[tab]!;

//   List<BookingListItem> getTabItems(MyServicesTab tab) =>
//       List<BookingListItem>.from(state(tab).items);

//   Future<String?> _getToken() async {
//     final session = await _local.getCachedAuthSession();
//     return session?.token;
//   }

//   Future<void> loadInitial(MyServicesTab tab, {int limit = 20}) async {
//     final s = state(tab);
//     s.isLoading = true;
//     s.error = null;
//     s.page = 1;
//     s.hasMore = true;
//     s.items.clear();

//     try {
//       await _fetch(tab: tab, page: 1, limit: limit, append: false);
//     } finally {
//       s.isLoading = false;
//     }
//   }

//   Future<void> loadMore(MyServicesTab tab, {int limit = 20}) async {
//     final s = state(tab);
//     if (s.isLoadingMore || !s.hasMore) return;

//     s.isLoadingMore = true;
//     s.error = null;

//     try {
//       await _fetch(tab: tab, page: s.page + 1, limit: limit, append: true);
//     } finally {
//       s.isLoadingMore = false;
//     }
//   }

//   Future<void> _fetch({
//     required MyServicesTab tab,
//     required int page,
//     required int limit,
//     required bool append,
//   }) async {
//     final token = await _getToken();
//     if (token == null || token.isEmpty) {
//       state(tab).error = 'Access token required';
//       state(tab).hasMore = false;
//       return;
//     }

//     try {
//       final query = <String, dynamic>{
//         'page': page,
//         'limit': limit,
//       };

//       // ✅ لو الباك يدعم status filter
//       if (tab == MyServicesTab.pending) query['status'] = 'pending_provider_accept';

//       final res = await _dio.get(
//         '/bookings/my',
//         queryParameters: query,
//         options: Options(headers: {
//           HttpHeaders.authorizationHeader: 'Bearer $token',
//           HttpHeaders.acceptHeader: 'application/json',
//         }),
//       );

//       final code = res.statusCode ?? 0;
//       final body = res.data;

//       if (body is! Map<String, dynamic>) {
//         throw ServerException(
//           message: 'Invalid response format',
//           statusCode: code,
//         );
//       }

//       final success = body['success'] as bool? ?? (code >= 200 && code < 300);
//       if (!success) {
//         throw ServerException(
//           message: body['message']?.toString() ?? 'Request failed',
//           statusCode: code,
//           errors: body['errors'] is Map<String, dynamic>
//               ? body['errors'] as Map<String, dynamic>
//               : null,
//         );
//       }

//       final data = body['data'];
//       if (data is! Map<String, dynamic>) {
//         throw const ServerException(message: 'Invalid bookings response format');
//       }

//       final bookingsJson = data['bookings'];
//       if (bookingsJson is! List) {
//         throw const ServerException(message: 'Invalid bookings list format');
//       }

//       final pagination = data['pagination'];
//       final hasNext = (pagination is Map<String, dynamic>)
//           ? (pagination['has_next'] as bool? ?? false)
//           : false;

//       final mapped = bookingsJson
//           .whereType<Map<String, dynamic>>()
//           .map<BookingListItem>(_mapBookingToItem)
//           .toList();

//       final visible = _applyTabFilter(tab, mapped);

//       final s = state(tab);
//       if (!append) s.items.clear();
//       s.items.addAll(visible);

//       s.page = page;
//       s.hasMore = hasNext;
//     } on DioException catch (e) {
//       final s = state(tab);
//       if (e.response?.data is Map<String, dynamic>) {
//         s.error = (e.response!.data as Map<String, dynamic>)['message']
//                 ?.toString() ??
//             'Server error';
//       } else {
//         s.error = 'Network error';
//       }
//       s.hasMore = false;
//     } on ServerException catch (e) {
//       final s = state(tab);
//       s.error = e.message;
//       s.hasMore = false;
//     } catch (_) {
//       final s = state(tab);
//       s.error = 'حدث خطأ غير متوقع';
//       s.hasMore = false;
//     }
//   }

//   List<BookingListItem> _applyTabFilter(
//     MyServicesTab tab,
//     List<BookingListItem> items,
//   ) {
//     return items.where((it) {
//       if (tab == MyServicesTab.pending) return it.isPending;
//       if (tab == MyServicesTab.upcoming) return it.isUpcoming;

//       // ✅ الأرشيف = مكتملة + ملغاة + refunded
//       if (tab == MyServicesTab.archive) return it.isCompleted || it.isCancelled;

//       return true;
//     }).toList();
//   }

//   BookingListItem _mapBookingToItem(Map<String, dynamic> json) {
//     final bookingId = (json['id'] is int) ? json['id'] as int : int.tryParse('${json['id']}') ?? 0;
//     final bookingNumber = (json['booking_number'] ?? json['id'] ?? '').toString();
//     final status = (json['status'] ?? '').toString();

//     // service name
//     String serviceName = 'خدمة';
//     final service = json['service'];
//     if (service is Map<String, dynamic>) {
//       serviceName = (service['name_localized'] ??
//               service['name_ar'] ??
//               service['name'] ??
//               'خدمة')
//           .toString();
//     }

//     final date = json['booking_date']?.toString() ?? '';
//     final time = _formatTime(json['booking_time']?.toString() ?? '');

//     final city = json['service_city']?.toString() ?? '';
//     final area = json['service_area']?.toString() ?? '';
//     final address = json['service_address']?.toString() ?? '';
//     final loc = [city, area, address]
//         .where((e) => e.trim().isNotEmpty)
//         .join('، ');

//     // price (قد تكون في booking أو service)
//     double? price;
//     final rawPrice = json['total_price'] ?? json['base_price'];
//     if (rawPrice is num) price = rawPrice.toDouble();
//     if (price == null && service is Map<String, dynamic>) {
//       final sp = service['base_price'];
//       if (sp is num) price = sp.toDouble();
//     }

//     // provider info (قد تكون null/مخفية قبل التأكيد)
//     String? providerName;
//     String? providerPhone;

//     final provider = json['provider'];
//     if (provider is Map<String, dynamic>) {
//       final user = provider['user'];
//       if (user is Map<String, dynamic>) {
//         final fn = (user['first_name'] ?? '').toString().trim();
//         final ln = (user['last_name'] ?? '').toString().trim();
//         final full = ('$fn $ln').trim();
//         providerName = full.isEmpty ? null : full;

//         final ph = user['phone'];
//         if (ph != null) {
//           final p = ph.toString().trim();
//           providerPhone = p.isEmpty ? null : p;
//         }
//       }
//     }

//     return BookingListItem(
//       bookingId: bookingId,
//       bookingNumber: bookingNumber,
//       status: status,
//       typeLabel: _statusToType(status),
//       serviceName: serviceName,
//       date: date,
//       time: time,
//       location: loc,
//       price: price,
//       currency: 'JOD',
//       providerName: providerName,
//       providerPhone: providerPhone,
//     );
//   }

//   String _statusToType(String status) {
//     switch (status) {
//       case 'pending_provider_accept':
//       case 'pending':
//         return 'قيد الانتظار';
//       case 'confirmed':
//       case 'provider_on_way':
//       case 'provider_arrived':
//       case 'in_progress':
//         return 'قادمة';
//       case 'completed':
//         return 'مكتملة';
//       case 'cancelled':
//       case 'refunded':
//         return 'ملغاة';
//       default:
//         return 'قيد الانتظار';
//     }
//   }

//   String _formatTime(String raw) {
//     if (raw.isEmpty) return '';
//     final parts = raw.split(':');
//     if (parts.length < 2) return raw;

//     int h = int.tryParse(parts[0]) ?? 0;
//     final m = parts[1];

//     final isPm = h >= 12;
//     final suffix = isPm ? 'م' : 'ص';
//     h = h % 12;
//     if (h == 0) h = 12;

//     return '$h:$m $suffix';
//     }
// }
