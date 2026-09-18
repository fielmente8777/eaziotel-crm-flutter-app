class UserResponseModel {
  final bool? status;
  final List<UserModel> data;

  UserResponseModel({
    this.status,
    this.data = const [],
  });

  factory UserResponseModel.fromJson(Map<String, dynamic> json) {
    return UserResponseModel(
      status: json['Status'],
      data: json['data'] != null
          ? List<UserModel>.from(
              json['data'].map(
                (x) => UserModel.fromJson(x),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Status': status,
      'data': data.map((x) => x.toJson()).toList(),
    };
  }
}

class UserModel {
  final String? id;
  final AccessScopeModel? accessScope;
  final String? accesskey;
  final String? createdAt;
  final String? displayName;
  final String? emailId;
  final String? googleId;
  final bool? isAdmin;
  final String? ndid;
  final bool? onboarding;
  final String? role;
  final String? userName;
  final String? phone;
  final List<AssignedLocationModel> assignedLocation;

  UserModel({
    this.id,
    this.accessScope,
    this.accesskey,
    this.createdAt,
    this.displayName,
    this.emailId, 
    this.googleId,
    this.isAdmin,
    this.ndid,
    this.onboarding,
    this.role,
    this.userName,
    this.phone,
    this.assignedLocation = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] is Map
          ? json['_id']['\$oid']?.toString()
          : json['_id']?.toString(),

      accessScope: json['accessScope'] != null
          ? AccessScopeModel.fromJson(
              Map<String, dynamic>.from(json['accessScope']),
            )
          : null,

      accesskey: json['accesskey']?.toString(),
      createdAt: json['createdAt']?.toString(),
      displayName: json['displayName']?.toString(),
      emailId: json['emailId']?.toString(),
      googleId: json['google_id']?.toString(),
      isAdmin: json['isAdmin'],
      ndid: json['ndid']?.toString(),
      onboarding: json['onboarding'],
      role: json['role']?.toString(),
      userName: json['userName']?.toString(),
      phone: json['phone']?.toString(),

      assignedLocation: json['assigned_location'] != null
          ? List<AssignedLocationModel>.from(
              json['assigned_location'].map(
                (x) => AssignedLocationModel.fromJson(
                  Map<String, dynamic>.from(x),
                ),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'accessScope': accessScope?.toJson(),
      'accesskey': accesskey,
      'createdAt': createdAt,
      'displayName': displayName,
      'emailId': emailId,
      'google_id': googleId,
      'isAdmin': isAdmin,
      'ndid': ndid,
      'onboarding': onboarding,
      'role': role,
      'userName': userName,
      'phone': phone,
      'assigned_location':
          assignedLocation.map((x) => x.toJson()).toList(),
    };
  }
}

class AssignedLocationModel {
  final AccessScopeModel? accessScope;
  final String? hid;

  AssignedLocationModel({
    this.accessScope,
    this.hid,
  });

  factory AssignedLocationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AssignedLocationModel(
      accessScope: json['accessScope'] != null
          ? AccessScopeModel.fromJson(
              Map<String, dynamic>.from(json['accessScope']),
            )
          : null,
      hid: json['hid']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessScope': accessScope?.toJson(),
      'hid': hid,
    };
  }
}

class AccessScopeModel {
  final bool analyticsandreporting;
  final bool bookingEngine;
  final bool channelManager;
  final bool cms;
  final bool conversationaltool;
  final bool eazobot;
  final bool emailmarketing;
  final bool enquiriesManagement;
  final bool foodManager;
  final bool frontDesk;
  final bool gatewayManager;
  final bool guestRequestManagement;
  final bool humanResourceManagement;
  final bool leadgenform;
  final bool reservationDesk;
  final bool seoManager;
  final bool smsmarketing;
  final bool socialMedia;
  final bool themes;
  final bool usermanagement;
  final bool whatsapp;
  final bool whatsappmarketing;

  AccessScopeModel({
    this.analyticsandreporting = false,
    this.bookingEngine = false,
    this.channelManager = false,
    this.cms = false,
    this.conversationaltool = false,
    this.eazobot = false,
    this.emailmarketing = false,
    this.enquiriesManagement = false,
    this.foodManager = false,
    this.frontDesk = false,
    this.gatewayManager = false,
    this.guestRequestManagement = false,
    this.humanResourceManagement = false,
    this.leadgenform = false,
    this.reservationDesk = false,
    this.seoManager = false,
    this.smsmarketing = false,
    this.socialMedia = false,
    this.themes = false,
    this.usermanagement = false,
    this.whatsapp = false,
    this.whatsappmarketing = false,
  });

  factory AccessScopeModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AccessScopeModel(
      analyticsandreporting:
          json['analyticsandreporting'] ?? false,
      bookingEngine: json['bookingEngine'] ?? false,
      channelManager: json['channelManager'] ?? false,
      cms: json['cms'] ?? false,
      conversationaltool:
          json['conversationaltool'] ?? false,
      eazobot: json['eazobot'] ?? false,
      emailmarketing: json['emailmarketing'] ?? false,
      enquiriesManagement:
          json['enquiriesManagement'] ?? false,
      foodManager: json['foodManager'] ?? false,
      frontDesk: json['frontDesk'] ?? false,
      gatewayManager: json['gatewayManager'] ?? false,
      guestRequestManagement:
          json['guestRequestManagement'] ?? false,
      humanResourceManagement:
          json['humanResourceManagement'] ?? false,
      leadgenform: json['leadgenform'] ?? false,
      reservationDesk: json['reservationDesk'] ?? false,
      seoManager: json['seoManager'] ?? false,
      smsmarketing: json['smsmarketing'] ?? false,
      socialMedia: json['socialMedia'] ?? false,
      themes: json['themes'] ?? false,
      usermanagement: json['usermanagement'] ?? false,
      whatsapp: json['whatsapp'] ?? false,
      whatsappmarketing:
          json['whatsappmarketing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analyticsandreporting': analyticsandreporting,
      'bookingEngine': bookingEngine,
      'channelManager': channelManager,
      'cms': cms,
      'conversationaltool': conversationaltool,
      'eazobot': eazobot,
      'emailmarketing': emailmarketing,
      'enquiriesManagement': enquiriesManagement,
      'foodManager': foodManager,
      'frontDesk': frontDesk,
      'gatewayManager': gatewayManager,
      'guestRequestManagement': guestRequestManagement,
      'humanResourceManagement': humanResourceManagement,
      'leadgenform': leadgenform,
      'reservationDesk': reservationDesk,
      'seoManager': seoManager,
      'smsmarketing': smsmarketing,
      'socialMedia': socialMedia,
      'themes': themes,
      'usermanagement': usermanagement,
      'whatsapp': whatsapp,
      'whatsappmarketing': whatsappmarketing,
    };
  }
}