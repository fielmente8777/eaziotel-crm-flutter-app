class AuthApiEndpoint {
  AuthApiEndpoint._();

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


      static const String UserProfile =
      '/user';

  static const String updateProfile =
      '/auth/profile';

  static const String deleteAccount =
      '/auth/delete-account';

  static const String refreshToken =
      '/auth/refresh-token';
}

// ============================================================
// DASHBOARD
// ============================================================

class DashboardApiEndpoint {
  DashboardApiEndpoint._();

  static const String analytics =
      '/api/v1/analytics/';
}

// ============================================================
// LEADS
// ============================================================

class LeadsApiEndpoint {
  LeadsApiEndpoint._();

  static const String getLeads =
      '/api/v1/leads/get';

  static String updateLead(String id) {
    return '/leads/$id';
  }
}


// ============================================================
// LEADS
// ============================================================

class analytics {
  analytics._();

  static const String getLeads =
      '/api/v1/analytics';

  static String updateLead(String id) {
    return '/leads/$id';
  }
}

// ============================================================
// BOOKING
// ============================================================

class BookingApiEndpoint {
  BookingApiEndpoint._();

  static const String getBookings =
      '/bookings';

  static const String createBooking =
      '/bookings';
}