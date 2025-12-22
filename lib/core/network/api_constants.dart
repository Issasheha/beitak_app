class ApiConstants {
  static const String baseUrl =
      'https://config-granny-cincinnati-additions.trycloudflare.com';
  static const String apiBase = '$baseUrl/api';
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String authProfile = '/auth/profile';
  static const String userProfile = '/users/profile';
  static const String userProfileActivity = '/users/profile/activity';
  static const String changePassword = '/auth/change-password';
  static const String userProfileImage = '/users/profile/image';
  static const String userBookings = '/users/bookings';
  static const String providerRegister = '/providers/register';
  static const String providerCompleteProfile = '/providers/complete-profile';
  static const String providerDashboardStats = '/providers/dashboard/stats';
  static const String bookingsMy = '/bookings/my';
  static String bookingProviderAction(int id) =>
      '/bookings/$id/provider-action';
  static const String bookingsSendOtp = '/bookings/send-otp';
  static const String bookingsCreate = '/bookings';
  static const String serviceRequestsGuest = '/service-requests/guest';
  static const String services = '/services';
  static String serviceDetails(int id) => '/services/$id';
  static const String providerMyServices = '/services/my/services';
  static String providerAvailableDays(int providerId) =>
      '/available-days/$providerId';
  static String availableDays(int providerId) =>
      '/bookings/available-days/$providerId';
  static const String cities = '/locations/cities';
  static const String areasByCity = '/locations/areas';
  static const String sendServiceReqOtp = '/auth/send-service-req-otp';
  static const String verifyServiceReqOtp = '/auth/verify-service-req-otp';
  static String bookingProviderComplete(int id) =>
      '/bookings/$id/provider-complete';
  static String bookingProviderCancel(int id) =>
      '/bookings/$id/provider-cancel';
  static const String providerProfile = '/providers/profile';
  static const String providerMyReviews = '/ratings/my-reviews';
  static String providerRatings(int providerId) =>
      '/ratings/provider/$providerId';
  static const String providerAvailability = '/providers/availability';
  static const String categories = '/categories';
  static const String areas = '/locations/areas';
  static const String search = '/search';
}
