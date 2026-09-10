class AuthApiEndpoint {
  AuthApiEndpoint._();

  // ============================================================
  // AUTH ENDPOINTS
  // ============================================================

  static const String login =
      '/eazotel/ceateuser';

  static const String signup =
      '/eazotel/createwebsite';

  static const String sendOtp =
      '/auth/send-otp';

  static const String verifyOtp =
      '/auth/verify-otp';

  static const String resendOtp =
      '/auth/resend-otp';

  static const String forgotPassword =
      '/auth/forgot-password';

  static const String resetPassword =
      '/auth/reset-password';

  static const String getUserProfile =
      '/eazotel/getuser';

  static const String updateProfile =
      '/auth/profile';

  static const String deleteAccount =
      '/auth/delete-account';

  static const String refreshToken =
      '/auth/refresh-token';
}


class DashboardApiEndpoint {
  DashboardApiEndpoint._();

  static const String analytics =
      '/api/v1/analytics/';
}


class LeadsApiEndpoint {
  LeadsApiEndpoint._();

  static const String getLeads =
      '/leads';

  static String updateLead(String id) {
    return '/leads/$id';
  }
}


class BookingApiEndpoint {
  BookingApiEndpoint._();

  static const String getBookings =
      '/bookings';

  static const String createBooking =
      '/bookings';
}