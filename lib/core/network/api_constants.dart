class ApiConstants {
  static const String baseUrl = 'http://192.168.1.29:3026';
  static const String apiBase = '$baseUrl/api';

  // auth endpoints
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
  // provider endpoints
  static const String providerRegister = '/providers/register';
  static const String providerCompleteProfile = '/providers/complete-profile';
  static const String providerDashboardStats = '/providers/dashboard/stats';

  // ✅ bookings
  static const String bookingsMy = '/bookings/my';
  static String bookingProviderAction(int id) => '/bookings/$id/provider-action';

  // ✅ NEW: guest booking OTP + create booking
  static const String bookingsSendOtp = '/bookings/send-otp';
  static const String bookingsCreate = '/bookings';
  static const String serviceRequestsGuest = '/service-requests/guest'; // ✅

  // ✅ services (public + details)
  static const String services = '/services';
  static String serviceDetails(int id) => '/services/$id';

  // ✅ NEW: provider "My Services"
  static const String providerMyServices = '/services/my/services';

  // NEW: provider available days
  static String providerAvailableDays(int providerId) => '/available-days/$providerId';
  static String availableDays(int providerId) => '/available-days/$providerId';

  static const String cities = '/locations/cities';
  static const String areasByCity = '/locations/areas';

  static const String sendServiceReqOtp = '/auth/send-service-req-otp';
  static const String verifyServiceReqOtp = '/auth/verify-service-req-otp';
  static String bookingProviderComplete(int id) => '/bookings/$id/provider-complete';
  static String bookingProviderCancel(int id) => '/bookings/$id/provider-cancel';
  static const String providerProfile = '/providers/profile';
  static const String providerMyReviews = '/ratings/my-reviews';

}
