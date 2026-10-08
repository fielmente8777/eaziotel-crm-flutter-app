class AuthApiEndpoint {
  AuthApiEndpoint._();

  static const String login = '/eazotel/ceateuser';

  static const String signup = '/eazotel/createwebsite';

  static const String sendOtp = '/auth/send-otp';

  static const String verifyOtp = '/auth/verify-otp';

  static const String resendOtp = '/auth/resend-otp';

  static const String forgotPassword = '/auth/forgot-password';

  static const String resetPassword = '/auth/reset-password';

  static const String getUserProfile = '/eazotel/getuser';

  static const String UserProfile = '/user';

  static const String updateProfile = '/auth/profile';

  static const String deleteAccount = '/auth/delete-account';

  static const String refreshToken = '/auth/refresh-token';
}

// ============================================================
// DASHBOARD
// ============================================================

class DashboardApiEndpoint {
  DashboardApiEndpoint._();

  static const String analytics = '/api/v1/analytics/';
}

// ============================================================
// LEADS
// ============================================================

class LeadsApiEndpoint {
  LeadsApiEndpoint._();

  static const String getLeads = '/api/v1/leads/get';

  static String updateLead(String id) {
    return '/leads/$id';
  }
}

// ============================================================
// LEADS
// ============================================================

class analytics {
  analytics._();

  static const String getLeads = '/api/v1/analytics';

  static String updateLead(String id) {
    return '/leads/$id';
  }
}

// ============================================================
// BOOKING
// ============================================================

class BookingApiEndpoint {
  BookingApiEndpoint._();

  static const String getBookings = '/bookings';

  static const String createBooking = '/bookings';
}
// ============================================================
// WHATSAPP
// ============================================================

class WhatsappApiEndpoint {
  WhatsappApiEndpoint._();

  static const String getConversations = '/api/v1/whatsapp/conversations/all';

  static String getMessages(String conversationId) {
    return '/api/v1/whatsapp/conversations/$conversationId/messages';
  }

  static String markAsRead(String conversationId) {
    return '/api/v1/whatsapp/conversations/$conversationId/read';
  }

  static const String getIntegration = '/api/v1/integration/get';
  static const String sandmessages = '/api/v1/whatsapp/messages/send?hid=';
  static const String template = '/api/v1/whatsapp/message/template/get?hid=';
  static const String deltechat = '/api/v1/whatsapp/messages/delete';
  static const String deletWhatsappLeads =
      '/api/v1/whatsapp/conversations?hid=';
  static const String flow = '/api/v1/whatsapp/flow/get?hid=';
}

class AnalytisApiEndpoint {
  static const String analytics_data = '/google/analytics-data/';
  static const String traffic_sources = 'google/analytics-traffic-sources/';
  static const analytics_pages = 'google/analytics-pages/';
  static const analytics_conversions = 'google/analytics-conversions/';
  static const analytics_devices = 'google/analytics-devices/';
  static const analytics_geo = 'google/analytics-geo/';
static const analytics_audience = 'google/analytics-audience/';
}


class CallApiEndpoint {
  static const analytics = '/api/v1/call/analytics';

  // Calls Management list: ?hid=..&page=..&limit=..
  static const getAll = '/api/v1/call/getall';
  static const makeCall = '/api/v1/call/auth/make-call';

  // PUT: stage / segregation / guestType / priority badalna
  static String updateCall(String id) => '/api/v1/call/update-call/$id';

  // GET: call ki recording (audio). sid = call ka "sid"
  static String recording(String sid) => '/api/v1/call/recording/$sid';
}