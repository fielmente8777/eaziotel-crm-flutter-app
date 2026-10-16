class ProfileResponseModel {
  final AccessModel access;
  final bool admin;
  final DataModel data;
  final ProfileModel profile;
  final bool status;
  final SubscriptionDetailsModel subscriptionDetails;

  /// Login kiye hue user ka email (`User.emailId`).
  /// WhatsApp "Take over" me yahi bheja jaata hai.
  final String userEmail;

  ProfileResponseModel({
    required this.access,
    required this.admin,
    required this.data,
    required this.profile,
    required this.status,
    required this.subscriptionDetails,
    this.userEmail = '',
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    final user = json['User'];

    return ProfileResponseModel(
      userEmail: user is Map ? (user['emailId']?.toString().trim() ?? '') : '',
      access: AccessModel.fromJson(json['Access'] ?? {}),
      admin: json['Admin'] ?? false,
      data: DataModel.fromJson(json['Data'] ?? {}),
      profile: ProfileModel.fromJson(json['Profile'] ?? {}),
      status: json['Status'] ?? false,
      subscriptionDetails: SubscriptionDetailsModel.fromJson(
        json['SubscriptionDetails'] ?? {},
      ),
    );
  }
}

// ============================================================
// ACCESS
// ============================================================

class AccessModel {
  final bool analyticsAndReporting;
  final bool bookingEngine;
  final bool channelManager;
  final bool cms;
  final bool conversationalTool;
  final bool eazobot;
  final bool emailMarketing;
  final bool enquiriesManagement;
  final bool foodManager;
  final bool frontDesk;
  final bool gatewayManager;
  final bool guestRequestManagement;
  final bool humanResourceManagement;
  final bool leadgenform;
  final bool reservationDesk;
  final bool seoManager;
  final bool smsMarketing;
  final bool socialMedia;
  final bool themes;
  final bool userManagement;
  final bool whatsapp;
  final bool whatsappMarketing;

  AccessModel({
    required this.analyticsAndReporting,
    required this.bookingEngine,
    required this.channelManager,
    required this.cms,
    required this.conversationalTool,
    required this.eazobot,
    required this.emailMarketing,
    required this.enquiriesManagement,
    required this.foodManager,
    required this.frontDesk,
    required this.gatewayManager,
    required this.guestRequestManagement,
    required this.humanResourceManagement,
    required this.leadgenform,
    required this.reservationDesk,
    required this.seoManager,
    required this.smsMarketing,
    required this.socialMedia,
    required this.themes,
    required this.userManagement,
    required this.whatsapp,
    required this.whatsappMarketing,
  });

  factory AccessModel.fromJson(Map<String, dynamic> json) {
    return AccessModel(
      analyticsAndReporting: json['analyticsandreporting'] ?? false,
      bookingEngine: json['bookingEngine'] ?? false,
      channelManager: json['channelManager'] ?? false,
      cms: json['cms'] ?? false,
      conversationalTool: json['conversationaltool'] ?? false,
      eazobot: json['eazobot'] ?? false,
      emailMarketing: json['emailmarketing'] ?? false,
      enquiriesManagement: json['enquiriesManagement'] ?? false,
      foodManager: json['foodManager'] ?? false,
      frontDesk: json['frontDesk'] ?? false,
      gatewayManager: json['gatewayManager'] ?? false,
      guestRequestManagement: json['guestRequestManagement'] ?? false,
      humanResourceManagement: json['humanResourceManagement'] ?? false,
      leadgenform: json['leadgenform'] ?? false,
      reservationDesk: json['reservationDesk'] ?? false,
      seoManager: json['seoManager'] ?? false,
      smsMarketing: json['smsmarketing'] ?? false,
      socialMedia: json['socialMedia'] ?? false,
      themes: json['themes'] ?? false,
      userManagement: json['usermanagement'] ?? false,
      whatsapp: json['whatsapp'] ?? false,
      whatsappMarketing: json['whatsappmarketing'] ?? false,
    );
  }
}

// ============================================================
// DATA
// ============================================================

class DataModel {
  final String id;
  final String bookingEngineLink;
  final String dashboardLink;
  final int dataId;
  final String ndid;
  final String websiteLink;

  DataModel({
    required this.id,
    required this.bookingEngineLink,
    required this.dashboardLink,
    required this.dataId,
    required this.ndid,
    required this.websiteLink,
  });

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      id: _stringValue(json['_id']),
      bookingEngineLink: _stringValue(json['bookingEngineLink']),
      dashboardLink: _stringValue(json['dashboardLink']),
      dataId: _intValue(json['id']),
      ndid: _stringValue(json['ndid']),
      websiteLink: _stringValue(json['websiteLink']),
    );
  }
}

// ============================================================
// PROFILE
// ============================================================

class ProfileModel {
  final String id;
  final String currency;
  final DinabiteTokenModel dinabiteToken;
  final String domain;
  final String hotelDescription;
  final String hotelEmail;
  final String hotelName;
  final String hotelPhone;

  // 🔥 HOTEL IS NOW LIST
  final List<HotelModel> hotels;

  final bool isVerified;
  final String ndid;
  final String onboardingDate;
  final PlanModel plan;
  final String subscriptionId;
  final String template;
  final String uid;
  final WatiCredsModel watiCreds;

  final UrlsModel urls;

  ProfileModel({
    required this.id,
    required this.currency,
    required this.dinabiteToken,
    required this.domain,
    required this.hotelDescription,
    required this.hotelEmail,
    required this.hotelName,
    required this.hotelPhone,
    required this.hotels,
    required this.isVerified,
    required this.ndid,
    required this.onboardingDate,
    required this.plan,
    required this.subscriptionId,
    required this.template,
    required this.uid,
    required this.watiCreds,
    required this.urls,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final hotelMap = json['hotels'] as Map<String, dynamic>? ?? {};

    final hotelList = hotelMap.entries.map((entry) {
      return HotelModel.fromJson(
        entry.key,
        entry.value is Map<String, dynamic> ? entry.value : {},
      );
    }).toList();

    return ProfileModel(
      id: _stringValue(json['_id']),
      currency: _stringValue(json['currency']),
      dinabiteToken: DinabiteTokenModel.fromJson(json['dinabiteToken'] ?? {}),
      domain: _stringValue(json['domain']),
      hotelDescription: _stringValue(json['hotelDescription']),
      hotelEmail: _stringValue(json['hotelEmail']),
      hotelName: _stringValue(json['hotelName']),
      hotelPhone: _stringValue(json['hotelPhone']),
      hotels: hotelList,
      isVerified: json['isVerified'] ?? false,
      ndid: _stringValue(json['ndid']),
      onboardingDate: _stringValue(json['onBoardinDate']),
      plan: PlanModel.fromJson(json['plan'] ?? {}),
      subscriptionId: _stringValue(json['subscriptionId']),
      template: _stringValue(json['template']),
      uid: _stringValue(json['uId']),
      watiCreds: WatiCredsModel.fromJson(json['watiCreds'] ?? {}),
      urls: UrlsModel.fromJson(json['urls'] ?? {}),
    );
  }
}

// ============================================================
// HOTEL
// ============================================================

class HotelModel {
  final String hotelId;
  final String city;
  final String country;
  final String local;
  final String pinCode;
  final String state;

  HotelModel({
    required this.hotelId,
    required this.city,
    required this.country,
    required this.local,
    required this.pinCode,
    required this.state,
  });

  factory HotelModel.fromJson(String hotelId, Map<String, dynamic> json) {
    return HotelModel(
      hotelId: hotelId,
      city: _stringValue(json['city']),
      country: _stringValue(json['country']),
      local: _stringValue(json['local']),
      pinCode: _stringValue(json['pinCode']),
      state: _stringValue(json['state']),
    );
  }
}

// ============================================================
// DINABITE TOKEN
// ============================================================

class DinabiteTokenModel {
  final String accessToken;

  DinabiteTokenModel({required this.accessToken});

  factory DinabiteTokenModel.fromJson(Map<String, dynamic> json) {
    return DinabiteTokenModel(accessToken: _stringValue(json['access_token']));
  }
}

// ============================================================
// PLAN
// ============================================================

class PlanModel {
  final String activationDate;
  final String expiryDate;
  final String name;

  PlanModel({
    required this.activationDate,
    required this.expiryDate,
    required this.name,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      activationDate: _stringValue(json['activationDate']),
      expiryDate: _stringValue(json['expiryDate']),
      name: _stringValue(json['name']),
    );
  }
}

// ============================================================
// WATI CREDENTIALS
// ============================================================

class WatiCredsModel {
  final String tenantId;
  final String watiAccessToken;

  WatiCredsModel({required this.tenantId, required this.watiAccessToken});

  factory WatiCredsModel.fromJson(Map<String, dynamic> json) {
    return WatiCredsModel(
      tenantId: _stringValue(json['tenantId']),
      watiAccessToken: _stringValue(json['watiAccessToken']),
    );
  }
}

// ============================================================
// SUBSCRIPTION DETAILS
// ============================================================

class SubscriptionDetailsModel {
  final String id;
  final AppAccessModel appAccess;
  final List<AppModel> apps;
  final bool autoRenew;
  final dynamic cancelledAt;
  final String createdAt;
  final String currentOrderId;
  final String endDate;
  final String lastPaymentId;
  final String ndid;
  final String planId;
  final String startDate;
  final String status;
  final String updatedAt;

  SubscriptionDetailsModel({
    required this.id,
    required this.appAccess,
    required this.apps,
    required this.autoRenew,
    required this.cancelledAt,
    required this.createdAt,
    required this.currentOrderId,
    required this.endDate,
    required this.lastPaymentId,
    required this.ndid,
    required this.planId,
    required this.startDate,
    required this.status,
    required this.updatedAt,
  });

  factory SubscriptionDetailsModel.fromJson(Map<String, dynamic> json) {
    final appsJson = json['apps'] as List<dynamic>? ?? [];

    return SubscriptionDetailsModel(
      id: _stringValue(json['_id']),
      appAccess: AppAccessModel.fromJson(json['appAccess'] ?? {}),
      apps: appsJson
          .whereType<Map<String, dynamic>>()
          .map(AppModel.fromJson)
          .toList(),
      autoRenew: json['autoRenew'] ?? false,
      cancelledAt: json['cancelledAt'],
      createdAt: _stringValue(json['createdAt']),
      currentOrderId: _stringValue(json['currentOrderId']),
      endDate: _stringValue(json['endDate']),
      lastPaymentId: _stringValue(json['lastPaymentId']),
      ndid: _stringValue(json['ndid']),
      planId: _stringValue(json['planId']),
      startDate: _stringValue(json['startDate']),
      status: _stringValue(json['status']),
      updatedAt: _stringValue(json['updatedAt']),
    );
  }
}

// ============================================================
// APP ACCESS
// ============================================================

class AppAccessModel {
  final bool bookingEngine;
  final bool eazbot;
  final bool exotel;
  final bool googleAnalytics;
  final bool googleAdsInsights;
  final bool grm;
  final bool leadManagement;
  final bool meta;
  final bool whatsapp;

  AppAccessModel({
    required this.bookingEngine,
    required this.eazbot,
    required this.exotel,
    required this.googleAnalytics,
    required this.googleAdsInsights,
    required this.grm,
    required this.leadManagement,
    required this.meta,
    required this.whatsapp,
  });

  factory AppAccessModel.fromJson(Map<String, dynamic> json) {
    return AppAccessModel(
      bookingEngine: json['booking_engine'] ?? false,
      eazbot: json['eazbot'] ?? false,
      exotel: json['exotel'] ?? false,
      googleAnalytics: json['google_analytics'] ?? false,
      googleAdsInsights: json['googleadsinsights'] ?? false,
      grm: json['grm'] ?? false,
      leadManagement: json['lead_management'] ?? false,
      meta: json['meta'] ?? false,
      whatsapp: json['whatsapp'] ?? false,
    );
  }
}

// ============================================================
// APP
// ============================================================

class AppModel {
  final String id;
  final String appId;
  final String endDate;
  final bool isTrial;
  final String startDate;

  AppModel({
    required this.id,
    required this.appId,
    required this.endDate,
    required this.isTrial,
    required this.startDate,
  });

  factory AppModel.fromJson(Map<String, dynamic> json) {
    return AppModel(
      id: _stringValue(json['_id']),
      appId: _stringValue(json['appId']),
      endDate: _stringValue(json['endDate']),
      isTrial: json['isTrial'] ?? false,
      startDate: _stringValue(json['startDate']),
    );
  }
}

// ============================================================
// SAFE PARSING HELPERS
// ============================================================

String _stringValue(dynamic value) {
  if (value == null) {
    return '';
  }

  if (value is String) {
    return value;
  }

  if (value is Map) {
    if (value['\$oid'] != null) {
      return value['\$oid'].toString();
    }

    if (value['\$date'] != null) {
      return value['\$date'].toString();
    }
  }

  return value.toString();
}

int _intValue(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '') ?? 0;
}

class UrlsModel {
  final List<String> landingPages;
  final List<String> websites;

  UrlsModel({required this.landingPages, required this.websites});

  factory UrlsModel.fromJson(Map<String, dynamic> json) {
    return UrlsModel(
      landingPages: List<String>.from(json['landingPages'] ?? []),
      websites: List<String>.from(json['websites'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {'landingPages': landingPages, 'websites': websites};
  }
}
