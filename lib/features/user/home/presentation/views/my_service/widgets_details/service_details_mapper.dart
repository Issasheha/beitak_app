import 'package:beitak_app/core/utils/number_format.dart';
import 'package:beitak_app/features/user/home/presentation/views/my_service/models/booking_list_item.dart';
import 'package:beitak_app/features/user/home/presentation/views/my_service/widgets_details/service_details_formatters.dart';


class ServiceDetailsVm {
  final String status;

  final String bookingNumber;
  final String serviceName;

  final String date;
  final String time;
  final String location;
  final String priceText;

  final String? providerName;
  final String? providerPhone;

  final bool isCancelled;
  final bool isCompleted;
  final bool isIncomplete;
  final bool isPending;
  final bool isUpcoming;

  // provider->user rating
  final int? providerRating;
  final double? amountPaidProvider;
  final String providerResponse;
  final String? providerRatedAt;

  // user->provider rating
  final bool userHasRated;
  final int? userRatingValue;
  final String userReview;
  final double? userAmountPaid;
  final String userRatedAt;

  final String incompleteNote;

  const ServiceDetailsVm({
    required this.status,
    required this.bookingNumber,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.location,
    required this.priceText,
    required this.providerName,
    required this.providerPhone,
    required this.isCancelled,
    required this.isCompleted,
    required this.isIncomplete,
    required this.isPending,
    required this.isUpcoming,
    required this.providerRating,
    required this.amountPaidProvider,
    required this.providerResponse,
    required this.providerRatedAt,
    required this.userHasRated,
    required this.userRatingValue,
    required this.userReview,
    required this.userAmountPaid,
    required this.userRatedAt,
    required this.incompleteNote,
  });
}

class ServiceDetailsMapper {
  ServiceDetailsMapper._();

  static ServiceDetailsVm build({
    required BookingListItem base,
    required Map<String, dynamic>? details,
  }) {
    String readString(Map<String, dynamic> j, List<String> keys,
        {String fallback = ''}) {
      for (final k in keys) {
        final v = j[k];
        if (v == null) continue;
        final s = v.toString().trim();
        if (s.isNotEmpty) return s;
      }
      return fallback;
    }

    double? readNum(Map<String, dynamic> j, List<String> keys) {
      for (final k in keys) {
        final v = j[k];
        if (v is num) return v.toDouble();
        final parsed = double.tryParse('$v');
        if (parsed != null) return parsed;
      }
      return null;
    }

    int? readInt(Map<String, dynamic> j, List<String> keys) {
      for (final k in keys) {
        final v = j[k];
        if (v is int) return v;
        if (v is num) return v.toInt();
        final parsed = int.tryParse('$v');
        if (parsed != null) return parsed;
      }
      return null;
    }

    final status = details != null
        ? readString(details, ['status'], fallback: base.status)
        : base.status;

    final isCancelled = status == 'cancelled' || status == 'refunded';
    final isCompleted = status == 'completed';
    final isIncomplete = status == 'incomplete';
    final isPending =
        status == 'pending_provider_accept' || status == 'pending';
    final isUpcoming = const {
      'confirmed',
      'provider_on_way',
      'provider_arrived',
      'in_progress',
    }.contains(status);

    // ✅ service name (prefer ar)
    String serviceName = base.serviceName;
    if (details != null) {
      final service = details['service'];
      if (service is Map<String, dynamic>) {
        final ar = readString(
          service,
          ['name_ar', 'nameAr', 'name_localized', 'nameLocalized'],
          fallback: '',
        );
        if (ar.isNotEmpty && ServiceDetailsFormatters.hasArabic(ar)) {
          serviceName = ar;
        }
      }
    }

    // ✅ booking number
    final bookingNumberRaw = base.bookingNumber.startsWith('#')
        ? base.bookingNumber
        : '#${base.bookingNumber}';
    final bookingNumber = NumberFormat.smart(bookingNumberRaw);

    // ✅ date
    String date = details != null
        ? readString(details, ['booking_date'], fallback: base.date)
        : base.date;
    date = NumberFormat.smart(date);

    // ✅ time (Prefix دائماً: "ص 3:00" / "م 2:30")
    final baseTime = base.time.trim();
    final timeRaw = details != null
        ? readString(details, ['booking_time'], fallback: baseTime)
        : baseTime;
    final time = ServiceDetailsFormatters.timePrefix(
      baseTime.isNotEmpty ? baseTime : timeRaw,
    );

    // ✅ location (city فقط بالعربي)
    String city =
        details != null ? readString(details, ['service_city']) : '';
    city = ServiceDetailsFormatters.onlyArabicCity(city);
    final location = city.isEmpty ? '' : city;

    // ✅ price (Prefix دائماً: "د.أ 50")
    final price = details != null
        ? (readNum(details, ['total_price', 'base_price']) ?? base.price)
        : base.price;
    final priceText =
        price == null ? 'غير محدد' : ServiceDetailsFormatters.moneyJodPrefix(price);

    // ✅ provider name/phone
    String? providerName = base.providerName;
    String? providerPhone = base.providerPhone;

    if (details != null) {
      final provider = details['provider'];
      if (provider is Map<String, dynamic>) {
        final user = provider['user'];
        if (user is Map<String, dynamic>) {
          final fn = readString(user, ['first_name'], fallback: '');
          final ln = readString(user, ['last_name'], fallback: '');
          final full = ('$fn $ln').trim();
          if (full.isNotEmpty) providerName = full;

          final ph = user['phone'];
          if (ph != null) {
            final p = ph.toString().trim();
            if (p.isNotEmpty) providerPhone = p;
          }
        }
      }
    }

    // ✅ incomplete note
    final rawProviderNotes =
        details == null ? '' : readString(details, ['provider_notes']);
    final incompleteNote = isIncomplete
        ? ServiceDetailsFormatters.incompleteNoteArabic(rawProviderNotes)
        : '';

    // ✅ provider->user rating (from rating map OR booking)
    Map<String, dynamic>? ratingMap;
    if (details != null && details['rating'] is Map<String, dynamic>) {
      ratingMap = details['rating'] as Map<String, dynamic>;
    }

    final providerRating = details == null
        ? null
        : readInt(ratingMap ?? details, ['provider_rating', 'providerRating']);

    final amountPaidProvider = details == null
        ? null
        : readNum(ratingMap ?? details, ['amount_paid', 'amountPaid']);

    final providerResponse = details == null
        ? ''
        : readString(
            ratingMap ?? details,
            ['provider_response', 'providerResponse'],
            fallback: '',
          );

    final providerRatedAt = details == null
        ? null
        : readString(
            ratingMap ?? details,
            ['provider_response_at', 'providerResponseAt'],
            fallback: '',
          ).trim();

    // ✅ user->provider rating
    final userRatingMap = _readUserRatingMap(details);
    final userHasRated = _hasUserRated(userRatingMap);

    final userRatingValue =
        userRatingMap == null ? null : readInt(userRatingMap, ['rating']);
    final userReview = userRatingMap == null
        ? ''
        : readString(userRatingMap, ['review'], fallback: '');
    final userAmountPaid = userRatingMap == null
        ? null
        : readNum(userRatingMap, ['user_amount_paid', 'amount_paid']);
    final userRatedAt = userRatingMap == null
        ? ''
        : readString(userRatingMap, ['created_at', 'createdAt'], fallback: '');

    return ServiceDetailsVm(
      status: status,
      bookingNumber: bookingNumber,
      serviceName: serviceName,
      date: date,
      time: time,
      location: location,
      priceText: priceText,
      providerName: providerName,
      providerPhone: providerPhone,
      isCancelled: isCancelled,
      isCompleted: isCompleted,
      isIncomplete: isIncomplete,
      isPending: isPending,
      isUpcoming: isUpcoming,
      providerRating: providerRating,
      amountPaidProvider: amountPaidProvider,
      providerResponse: providerResponse,
      providerRatedAt: providerRatedAt,
      userHasRated: userHasRated,
      userRatingValue: userRatingValue,
      userReview: userReview,
      userAmountPaid: userAmountPaid,
      userRatedAt: userRatedAt,
      incompleteNote: incompleteNote,
    );
  }

  static Map<String, dynamic>? _readUserRatingMap(Map<String, dynamic>? booking) {
    if (booking == null) return null;
    final r = booking['rating'];
    if (r is Map<String, dynamic>) {
      final ur = r['rating'];
      final review = r['review'];
      if ((ur is num && ur.toInt() > 0) ||
          (review != null && review.toString().trim().isNotEmpty)) {
        return r;
      }
    }
    return null;
  }

  static bool _hasUserRated(Map<String, dynamic>? userRatingMap) {
    if (userRatingMap == null) return false;
    final r = userRatingMap['rating'];
    final review = userRatingMap['review'];
    final amount =
        userRatingMap['user_amount_paid'] ?? userRatingMap['amount_paid'];
    final rated = (r is num && r.toInt() > 0);
    final hasText = review != null && review.toString().trim().isNotEmpty;
    final hasAmount = amount != null && '$amount'.trim().isNotEmpty;
    return rated || hasText || hasAmount;
  }
}
