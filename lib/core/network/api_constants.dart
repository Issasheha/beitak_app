class ApiConstants {
  static const String baseUrl =
      'https://instrument-earned-police-pure.trycloudflare.com';
  static const String apiBase = '$baseUrl/api';

  // =========================
  // Auth
  // =========================
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String authProfile = '/auth/profile';
  static const String changePassword = '/auth/change-password';

  // =========================
  // User
  // =========================
  static const String userProfile = '/users/profile';
  static const String userProfileActivity = '/users/profile/activity';
  static const String userProfileImage = '/users/profile/image';

  /// List bookings (user scope)
  static const String userBookings = '/users/bookings';

  /// ✅ NEW: cancel booking (user)
  /// POST /users/bookings/:id/cancel
  static String userBookingCancel(int id) => '/users/bookings/$id/cancel';

  // =========================
  // Provider
  // =========================
  static const String providerRegister = '/providers/register';
  static const String providerCompleteProfile = '/providers/complete-profile';
  static const String providerDashboardStats = '/providers/dashboard/stats';
  static const String providerProfile = '/providers/profile';
  static const String providerProfilePatch = '/providers/profile';

  static const String providerRequestPhoneOtp =
      '/providers/profile/phone/request-otp';
  static const String providerVerifyPhoneOtp =
      '/providers/profile/phone/verify-otp';

  static String providerById(int id) => '/providers/$id';

  static String providerBookingRating(int bookingId) =>
      '/providers/bookings/$bookingId/provider-rating';

  // =========================
  // Bookings (generic)
  // =========================
  static const String bookingsMy = '/bookings/my';
  static const String bookingsCreate = '/bookings';
  static const String bookingsSendOtp = '/bookings/send-otp';

  static String bookingDetails(int id) => '/bookings/$id';

  static String bookingProviderAction(int id) =>
      '/bookings/$id/provider-action';
  static String bookingProviderComplete(int id) =>
      '/bookings/$id/provider-complete';
  static String bookingProviderCancel(int id) =>
      '/bookings/$id/provider-cancel';

  /// Provider pending action (accept / reject)
  static String providerBookingAction(int bookingId) =>
      '/bookings/$bookingId/provider-action';
  // Provider Activate/Deactivate
  static const String providerActivate = '/providers/activate';
  static const String providerDeactivate = '/providers/deactivate';

  // =========================
  // Services
  // =========================
  static const String services = '/services';
  static String serviceDetails(int id) => '/services/$id';
  static const String providerMyServices = '/services/my/services';

  // =========================
  // Requests (Guest)
  // =========================
  static const String serviceRequestsGuest = '/service-requests/guest';
  static const String sendServiceReqOtp = '/auth/send-service-req-otp';
  static const String verifyServiceReqOtp = '/auth/verify-service-req-otp';

  // =========================
  // Locations
  // =========================
  static const String cities = '/locations/cities';
  static const String areasByCity = '/locations/areas';
  static const String areas = '/locations/areas';

  // =========================
  // Others
  // =========================
  static const String categories = '/categories';
  static const String search = '/search';

  // =========================
  // Ratings
  // =========================
  static const String providerMyReviews = '/ratings/my-reviews';
  static String providerRatings(int providerId) =>
      '/ratings/provider/$providerId';

  // =========================
  // Availability
  // =========================
  static const String providerAvailability = '/providers/availability';
  static String providerAvailableDays(int providerId) =>
      '/available-days/$providerId';
  static String availableDays(int providerId) =>
      '/bookings/available-days/$providerId';

  // =========================
  // ✅ Uploads paths (IMPORTANT)
  // =========================
  static const String uploadsBase = '$baseUrl/uploads';
  static const String uploadsProfiles = '$uploadsBase/profiles';
  static const String uploadsServices = '$uploadsBase/services';
  static const String uploadsPortfolios = '$uploadsBase/portfolios';
  static const String uploadsBookings = '$uploadsBase/bookings';
  static const String uploadsVerifications = '$uploadsBase/verifications';
  static const String uploadsRequests = '$uploadsBase/requests';

  /// ✅ الافتراضي لوثائق مزود الخدمة (هوية/رخصة/عدم محكومية)
  static String providerDocUrl(String fileName) {
    final safeName = Uri.encodeComponent(fileName.trim());
    return '$uploadsVerifications/$safeName';
  }
}
