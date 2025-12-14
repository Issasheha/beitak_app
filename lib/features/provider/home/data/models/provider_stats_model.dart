class ProviderStatsModel {
  /// Kept for backward compatibility (old UI used it).
  /// We will not rely on it for "إجمالي الطلبات" anymore.
  final int todayBookings;

  final double rating;
  final int ratingCount;

  final double thisMonthEarnings;

  // ✅ NEW (حسب الـ API عندك)
  final int totalBookings;
  final int completedBookings;
  final int upcomingBookings;
  final double totalEarnings;

  const ProviderStatsModel({
    required this.todayBookings,
    required this.rating,
    required this.ratingCount,
    required this.thisMonthEarnings,
    required this.totalBookings,
    required this.completedBookings,
    required this.upcomingBookings,
    required this.totalEarnings,
  });

  factory ProviderStatsModel.fromJson(Map<String, dynamic> json) {
    double asDouble(dynamic v) {
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? 0.0;
    }

    int asInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;

    return ProviderStatsModel(
      // ✅ old
      todayBookings: asInt(json['today_bookings']),
      rating: asDouble(json['rating']),
      ratingCount: asInt(json['rating_count']),
      thisMonthEarnings: asDouble(json['this_month_earnings']),

      // ✅ new
      totalBookings: asInt(json['total_bookings']),
      completedBookings: asInt(json['completed_bookings']),
      upcomingBookings: asInt(json['upcoming_bookings']),
      totalEarnings: asDouble(json['total_earnings']),
    );
  }

  static const empty = ProviderStatsModel(
    todayBookings: 0,
    rating: 0,
    ratingCount: 0,
    thisMonthEarnings: 0,

    totalBookings: 0,
    completedBookings: 0,
    upcomingBookings: 0,
    totalEarnings: 0,
  );
}
