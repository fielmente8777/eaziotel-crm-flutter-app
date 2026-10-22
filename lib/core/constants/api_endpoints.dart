class AuthApiEndpoint {
  AuthApiEndpoint._();

  static const String login = '/eazotel/ceateuser';

  static const String changePassword = '/eazotel/edit/password';

  static const String signup = '/eazotel/createwebsite';

  static const String sendOtp = '/auth/send-otp';

  static const String verifyOtp = '/auth/verify-otp';

  static const String resendOtp = '/auth/resend-otp';

  /// POST { email } -> 6-digit code by email (BaseUrl.production2, no login)
  static const String forgotPassword = '/api/v1/auth/forgot-password';

  /// POST { email, otp, password } (BaseUrl.production2, no login)
  static const String resetPassword = '/api/v1/auth/reset-password';

  static const String getUserProfile = '/eazotel/getuser';

  static const String UserProfile = '/user';

  // Details of the logged-in user (User.emailId) — with Bearer token
  static const String userDetails = '/user/user-details';

  /// Owner: all client accounts (data[])
  static const String allClients = '/admin/get-all-clients';

  /// Owner: go into a client account. POST { Email } -> { Status, Token }
  static const String switchAccount = '/admin/switch-account';

  static const String updateProfile = '/auth/profile';

  /// Hotel location (gian). POST = new, PUT/DELETE = /<hotelId>
  /// Answer: result.hotels = { hotelId: { local, city, ... } } (the full new list)
  static const String profileHotels = '/api/v1/profile/hotels';

  static String profileHotel(String hotelId) =>
      '/api/v1/profile/hotels/${Uri.encodeComponent(hotelId)}';

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

  // Chat: who will reply (AI or a team member)
  static String takeOver(String conversationId) =>
      '/api/v1/whatsapp/conversations/$conversationId/takeover';
  static String release(String conversationId) =>
      '/api/v1/whatsapp/conversations/$conversationId/release';

  // Chat: whether an automated flow (form) is running
  static const String flowSession = '/api/v1/whatsapp/flow-session';

  // Settings > WhatsApp tab
  static const String accountDetails =
      '/api/v1/whatsapp/account/connection/details';
  static const String businessProfile = '/api/v1/whatsapp/profile';
  static const String updateBusinessProfile = '/api/v1/whatsapp/profile/update';
  static const String chatbotFlow = '/api/v1/whatsapp/flow';
  static const String billing = '/api/v1/whatsapp/billing';
  static const String billingTransactions =
      '/api/v1/whatsapp/billing/transactions';

  // Settings > WhatsApp > Message Templates (form-data, ?hid=)
  static const String createTemplate =
      '/api/v1/whatsapp/message/template/create';
  static String updateTemplate(String id) =>
      '/api/v1/whatsapp/message/template/$id';

  /// DELETE, body {templateName, language}
  static const String deleteTemplate =
      '/api/v1/whatsapp/message/template/delete';

  /// PUT: auto message + notification, ya AI configuration
  static String autoMessageConfig(String phoneNumberId) =>
      '/api/v1/whatsapp/account/$phoneNumberId/automessageConfig/update';

  /// POST {flowName, screens, category} (?hid=)
  static const String createFlow = '/api/v1/whatsapp/flow/create';

  /// To view a photo uploaded in a WhatsApp Flow (chatbot) (?ndid=)
  static String media(String mediaId) => '/api/v1/whatsapp/media/$mediaId';

  /// Upload a carousel card photo (form-data "file") -> result.doc.imageUrl
  static const String imageUpload = '/api/v1/image/upload';
}

/// Drawer > Meta Insights. Base: BaseUrl.production2
class MetaApiEndpoint {
  MetaApiEndpoint._();

  /// GET ?hid=&period=day|week|28_days|90_days -> result.doc
  static const String pageOverview = '/api/v1/meta/page/overview';
}

/// Drawer > Social Media: external portal (opens in the browser)
class SocialMediaLinks {
  SocialMediaLinks._();

  static const String portal = 'https://social.eazotel.com';
  static const String login =
      'https://social.eazotel.com/client/eazotel/clientlogin.do';
}

/// Settings > WhatsApp > Quick Replies. Base: BaseUrl.production2 (?hid=)
class QuickReplyApiEndpoint {
  QuickReplyApiEndpoint._();

  /// GET list, POST create (form-data)
  static const String list = '/api/v1/quick-reply';

  /// PUT update (form-data), DELETE
  static String byId(String id) => '/api/v1/quick-reply/$id';
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

  // POST: Exotel credentials save (Settings > Integration > Exotel Connect)
  static const connectExotel = '/api/v1/call/auth/connect';

  // PUT: stage / segregation / guestType / priority badalna
  static String updateCall(String id) => '/api/v1/call/update-call/$id';

  // GET: call recording (audio). sid = the call's "sid"
  static String recording(String sid) => '/api/v1/call/recording/$sid';
}

class SubscriptionApiEndpoint {
  SubscriptionApiEndpoint._();

  /// GET /api/v1/subscription/my   (baseUrl: BaseUrl.production2)
  static const String mySubscription = '/api/v1/subscription/my';

  /// GET -> result.data { plans[], apps[] }  (no login needed)
  static const String plans = '/api/v1/subscription/plans';

  /// POST { planId, appIds, validFor, discount, teamCount, teamCost, gst }
  /// -> result.doc { orderId, amount }  (Razorpay order)
  static const String createOrder = '/api/v1/subscription/create-order';

  /// POST { razorpay_payment_id, razorpay_order_id, razorpay_signature,
  ///        validFor, planId, appIds }
  static const String verifyPayment = '/api/v1/subscription/verify-payment';
}

/// Settings > Team Management (base: BaseUrl.production)
class TeamApiEndpoint {
  TeamApiEndpoint._();

  static String createUser(String token) => '/user/create/$token';

  static String editUser(String token) => '/user/edit/$token';

  static String deleteUser(String emailId) => '/user/delete/$emailId';
}

/// Settings > Notification tab (base: BaseUrl.production2)
class SettingApiEndpoint {
  SettingApiEndpoint._();

  static const String getConfig = '/api/v1/setting/get-config';
  static const String updateConfig = '/api/v1/setting/update-config';
}

/// Settings > Integration tab (base: BaseUrl.production)
class IntegrationApiEndpoint {
  IntegrationApiEndpoint._();

  /// GET `/google/status/<hid>`  -> {"connected": true, "email": "..."}
  static String googleStatus(String hid) => '/google/status/$hid';

  /// GET  /google/gsc-settings/<propertyId>  (base: production)
  static String gscSettings(String propertyId) =>
      '/google/gsc-settings/$propertyId';

  /// POST /google/save-gsc-settings  (base: production)
  static const String saveGscSettings = '/google/save-gsc-settings';

  /// GET  /api/v1/google-ads/auth/google/start?ndid=  (base: production2)
  /// -> {"googleAuthUrl": "https://accounts.google.com/..."}
  static const String googleAdsStart = '/api/v1/google-ads/auth/google/start';
}

/// Settings > Eazbot tab (base: BaseUrl.production)
class EazbotApiEndpoint {
  EazbotApiEndpoint._();

  /// POST ?hid=  -> creates or updates the bot
  static const String create = '/leadeazbot/create';
}

/// Marketing (WhatsApp + Email). Base: BaseUrl.production2
class MarketingApiEndpoint {
  MarketingApiEndpoint._();

  /// GET ?hid=  -> result.docs.campaigns
  static const String whatsappCampaigns = '/api/v1/whatsapp/campaign';

  /// GET ?page=&limit=  -> result.doc {campaign, recipients, pagination}
  static String whatsappCampaignDetail(String id) =>
      '/api/v1/whatsapp/campaign/broadcast/$id';

  /// GET ?hid=&page=&limit=  -> result.doc (list) + result.pagination
  static const String emailRecipients = '/api/v1/email-marketing/recipients';

  /// GET ?hid=&page=&limit=  -> result.doc (list) + result.pagination
  /// POST multipart (create a new campaign)
  static const String emailCampaigns = '/api/v1/email-marketing/campaigns';

  // ---------- WhatsApp: new campaign ----------

  /// POST ?hid=  { campaignName, template, source? }
  static const String whatsappCreateCampaign =
      '/api/v1/whatsapp/campaign/create';

  /// GET ?hid=&source=  -> result.totalUsers (how many people it will reach)
  static const String whatsappCampaignAudience =
      '/api/v1/whatsapp/campaign/users';

  // ---------- Email: recipient batch (who to send to) ----------

  /// POST { hid, leadIds }
  static const String emailBatchLeads =
      '/api/v1/email-marketing/recipient-batches/leads';

  /// POST { hid, search }  (all leads matching the search)
  static const String emailBatchAllLeads =
      '/api/v1/email-marketing/recipient-batches/leads/all';

  /// POST { hid, emails }
  static const String emailBatchManual =
      '/api/v1/email-marketing/recipient-batches/manual';

  // ---------- Email: campaign ----------

  static String emailCampaign(String id) =>
      '/api/v1/email-marketing/campaigns/$id';

  /// GET ?hid=&page=&limit=&status=
  static String emailCampaignRecipients(String id) =>
      '/api/v1/email-marketing/campaigns/$id/recipients';

  /// POST { hid }
  static String emailCampaignSend(String id) =>
      '/api/v1/email-marketing/campaigns/$id/send';

  // ---------- Email: templates ----------

  /// GET ?hid=&page=&limit=&search=   POST { hid, name, subject, html ... }
  static const String emailTemplates = '/api/v1/email-marketing/templates';

  /// PATCH / DELETE ?hid=
  static String emailTemplate(String id) =>
      '/api/v1/email-marketing/templates/$id';

  /// POST ?hid=  { prompt, tone, brandName, ... }  (AI, 20-60 sec)
  static const String emailTemplateGenerate =
      '/api/v1/email-marketing/templates/generate';
}

/// Google Ads Insights (drawer). Base: BaseUrl.production2
class GoogleAdsApiEndpoint {
  GoogleAdsApiEndpoint._();

  /// Pulls fresh data from Google into the DB (?startDate=&endDate=&targetAccountId=)
  static const String sync = '/api/v1/google-ads/sync';
  static const String accounts = '/api/v1/google-ads/accounts';
  static String campaigns(String accountId) =>
      '/api/v1/google-ads/campaigns/$accountId';
  static String adGroups(String campaignId) =>
      '/api/v1/google-ads/adgroups/$campaignId';
  static String ads(String adGroupId) => '/api/v1/google-ads/ads/$adGroupId';

  /// ?level=account|campaign|ad&startDate=&endDate=
  static String summary(String entityId) =>
      '/api/v1/google-ads/metrics/summary/$entityId';
  static String devices(String entityId) =>
      '/api/v1/google-ads/metrics/devices/$entityId';
}

/// SEO (drawer > SEO > Local Seo / Website Seo). Base: BaseUrl.production2
/// No hid needed; the user is identified from the token.
class SeoApiEndpoint {
  SeoApiEndpoint._();

  static const String _base = '/api/v1/seo/seo-intelligence';

  /// GET: all keywords + local config + geo grid + trend
  static const String intelligence = _base;

  /// GET: credits (balance) + pricing
  static const String tokens = '$_base/tokens';

  // ---------- Local SEO ----------

  /// POST {keywords, selfDomain, selfHotelName}
  static const String track = '$_base/track';

  /// POST {businessType, city, district, state}
  static const String suggestKeywords = '$_base/suggest-keywords';

  /// POST {businessName, lat, lng, radiusKm, city, district, ...}
  static const String onboarding = '$_base/onboarding';

  /// POST {} (scan the map coverage again)
  static const String triggerGridScan = '$_base/trigger-grid-scan';

  /// POST {radiusKm}
  static const String updateRadius = '$_base/update-radius';

  /// POST {keyword}
  static const String updateGridKeyword = '$_base/update-grid-keyword';

  // ---------- Website SEO ----------

  /// POST {websiteUrl} (only once, cannot be changed)
  static const String setWebsite = '$_base/set-website';

  /// POST {country}
  static const String updateWebsiteCountry = '$_base/update-website-country';

  /// POST {keywords}
  static const String trackLink = '$_base/track-link';

  // ---------- Both ----------

  /// POST {keyword}
  static const String refreshKeyword = '$_base/refresh-keyword';

  /// DELETE
  static String untrack(String keyword) =>
      '$_base/${Uri.encodeComponent(keyword)}';
}

// ============================================================
// ONBOARDING (new account, no hotel yet) - like the web OnboardingForm
// ============================================================

class OnboardingApiEndpoint {
  OnboardingApiEndpoint._();

  /// POST (BaseUrl.production). The token goes in the body.
  /// Creates the hotel profile + website + first location.
  /// -> { Status, hId, Message }
  static const String createWebsite = '/eazotel/createwebsite';

  /// POST { propertyDetails } (BaseUrl.production2, Bearer)
  /// Starts the 14-day free trial. Returns 409 if already done.
  static const String complete = '/api/v1/onboarding';

  /// Country / state / city lists (the web uses the same)
  static const String placesUrl =
      'https://countriesnow.space/api/v0.1/countries';
}
