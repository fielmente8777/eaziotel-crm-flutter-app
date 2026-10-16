class LeadResponseModel {
  bool? success;
  int? responseStatusCode;
  String? responseMessage;
  LeadRequestModel? request;
  LeadResultModel? result;

  LeadResponseModel({
    this.success,
    this.responseStatusCode,
    this.responseMessage,
    this.request,
    this.result,
  });

  factory LeadResponseModel.fromJson(Map<String, dynamic> json) {
    return LeadResponseModel(
      success: json['success'],
      responseStatusCode: json['responseStatusCode'],
      responseMessage: json['responseMessage'],
      request: json['request'] != null
          ? LeadRequestModel.fromJson(json['request'])
          : null,
      result: json['result'] != null
          ? LeadResultModel.fromJson(json['result'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'responseStatusCode': responseStatusCode,
      'responseMessage': responseMessage,
      'request': request?.toJson(),
      'result': result?.toJson(),
    };
  }
}

// ============================================================
// REQUEST
// ============================================================

class LeadRequestModel {
  String? method;
  String? basesurl;
  String? endpoint;

  LeadRequestModel({this.method, this.basesurl, this.endpoint});

  factory LeadRequestModel.fromJson(Map<String, dynamic> json) {
    return LeadRequestModel(
      method: json['method'],
      basesurl: json['basesurl'],
      endpoint: json['endpoint'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'method': method, 'basesurl': basesurl, 'endpoint': endpoint};
  }
}

// ============================================================
// RESULT
// ============================================================

class LeadResultModel {
  LeadDocsModel? docs;
  LeadPaginationModel? pagination;

  LeadResultModel({this.docs, this.pagination});

  factory LeadResultModel.fromJson(Map<String, dynamic> json) {
    return LeadResultModel(
      docs: json['docs'] != null ? LeadDocsModel.fromJson(json['docs']) : null,
      pagination: json['pagination'] != null
          ? LeadPaginationModel.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'docs': docs?.toJson(), 'pagination': pagination?.toJson()};
  }
}

// ============================================================
// DOCS
// ============================================================

class LeadDocsModel {
  List<LeadModel>? leads;
  List<dynamic>? allCampaigns;

  LeadDocsModel({this.leads, this.allCampaigns});

  factory LeadDocsModel.fromJson(Map<String, dynamic> json) {
    return LeadDocsModel(
      leads: json['leads'] != null
          ? List<LeadModel>.from(
              json['leads'].map((x) => LeadModel.fromJson(x)),
            )
          : null,

      allCampaigns: json['allCampaigns'] != null
          ? List<dynamic>.from(json['allCampaigns'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leads': leads?.map((x) => x.toJson()).toList(),
      'allCampaigns': allCampaigns,
    };
  }
}

// ============================================================
// LEAD
// ============================================================

class LeadModel {
  String? id;
  String? ndid;
  String? hId;
  String? name;
  String? guestId;
  String? contact;
  String? email;
  String? subject;
  String? message;
  String? checkIn;
  String? checkOut;
  String? location;
  String? createdAt;
  String? createdFrom;
  String? status;
  String? turnAwayCode;
  String? updatedAt;
  bool? isConvertable;
  bool? isConverted;
  String? convertedBy;
  String? sourceUrl;
  String? remark;
  String? conversationId;

  List<LeadChatModel>? chats;

  LeadRequestMetadataModel? requestMetadata;

  String? hid;
  String? leadId;

  List<LeadNoteModel>? notes;

  String? assignee;
  String? assigneeEmail;
  String? assigneeNumber;

  Map<String, dynamic>? otherDetails;

  String? followUpDate;
  String? metaCreatedDate;
  String? createdAtDate;
  String? sortDate;

  LeadModel({
    this.id,
    this.ndid,
    this.hId,
    this.name,
    this.guestId,
    this.contact,
    this.email,
    this.subject,
    this.message,
    this.checkIn,
    this.checkOut,
    this.location,
    this.createdAt,
    this.createdFrom,
    this.status,
    this.updatedAt,
    this.isConvertable,
    this.isConverted,
    this.convertedBy,
    this.sourceUrl,
    this.remark,
    this.chats,
    this.requestMetadata,
    this.hid,
    this.leadId,
    this.notes,
    this.assignee,
    this.assigneeEmail,
    this.assigneeNumber,
    this.otherDetails,
    this.followUpDate,
    this.metaCreatedDate,
    this.createdAtDate,
    this.sortDate,
    this.conversationId,
    this.turnAwayCode,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['_id'],
      turnAwayCode: json['turnAwayCode'],
      ndid: json['ndid'],
      conversationId: json['conversationId'],
      hId: json['hId'],
      name: json['Name'],
      guestId: json['guest_id'],
      contact: json['Contact'],
      email: json['Email'],
      subject: json['Subject'],
      message: json['Message'],
      checkIn: json['check_in'],
      checkOut: json['check_out'],
      location: json['location'],
      createdAt: json['Created_at'],
      createdFrom: json['created_from'],
      status: json['status'],
      updatedAt: json['updated_at'],
      isConvertable: json['is_convertable'],
      isConverted: json['is_converted'],
      convertedBy: json['converted_by'],
      sourceUrl: json['source_url'],
      remark: json['Remark'],

      chats: json['chats'] != null
          ? List<LeadChatModel>.from(
              json['chats'].map((x) => LeadChatModel.fromJson(x)),
            )
          : null,

      requestMetadata: json['request_metadata'] != null
          ? LeadRequestMetadataModel.fromJson(json['request_metadata'])
          : null,

      hid: json['hid'],
      leadId: json['leadId'],

      notes: json['notes'] != null
          ? List<LeadNoteModel>.from(
              json['notes'].map((x) => LeadNoteModel.fromJson(x)),
            )
          : null,

      assignee: json['assignee'],
      assigneeEmail: json['assigneeEmail'],
      assigneeNumber: json['assigneeNumber'],

      otherDetails: json['other_details'] != null
          ? Map<String, dynamic>.from(json['other_details'])
          : null,

      followUpDate: json['followUpDate'],
      metaCreatedDate: json['metaCreatedDate'],
      createdAtDate: json['createdAtDate'],
      sortDate: json['sortDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'ndid': ndid,
      'conversationId': conversationId,
      'ndid': ndid,
      'hId': hId,
      'Name': name,
      'guest_id': guestId,
      'Contact': contact,
      'Email': email,
      'Subject': subject,
      'Message': message,
      'check_in': checkIn,
      'check_out': checkOut,
      'location': location,
      'Created_at': createdAt,
      'created_from': createdFrom,
      'status': status,
      'updated_at': updatedAt,
      'is_convertable': isConvertable,
      'is_converted': isConverted,
      'converted_by': convertedBy,
      'source_url': sourceUrl,
      'Remark': remark,

      'chats': chats?.map((x) => x.toJson()).toList(),

      'request_metadata': requestMetadata?.toJson(),

      'hid': hid,
      'leadId': leadId,

      'notes': notes?.map((x) => x.toJson()).toList(),

      'assignee': assignee,
      'assigneeEmail': assigneeEmail,
      'assigneeNumber': assigneeNumber,

      'other_details': otherDetails,

      'followUpDate': followUpDate,
      'metaCreatedDate': metaCreatedDate,
      'createdAtDate': createdAtDate,
      'sortDate': sortDate,
    };
  }
}
// ============================================================
// REQUEST METADATA
// ============================================================

class LeadRequestMetadataModel {
  String? ip;
  String? userAgent;
  String? referer;
  String? origin;
  String? host;
  String? acceptLanguage;
  LeadGeoModel? geo;

  LeadRequestMetadataModel({
    this.ip,
    this.userAgent,
    this.referer,
    this.origin,
    this.host,
    this.acceptLanguage,
    this.geo,
  });

  factory LeadRequestMetadataModel.fromJson(Map<String, dynamic> json) {
    return LeadRequestMetadataModel(
      ip: json['ip'],
      userAgent: json['user_agent'],
      referer: json['referer'],
      origin: json['origin'],
      host: json['host'],
      acceptLanguage: json['accept_language'],

      geo: json['geo'] != null ? LeadGeoModel.fromJson(json['geo']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ip': ip,
      'user_agent': userAgent,
      'referer': referer,
      'origin': origin,
      'host': host,
      'accept_language': acceptLanguage,
      'geo': geo?.toJson(),
    };
  }
}

// ============================================================
// GEO
// ============================================================

class LeadGeoModel {
  String? ip;
  String? city;
  String? region;
  String? country;
  String? loc;
  String? org;
  String? postal;
  String? timezone;
  String? readme;

  LeadGeoModel({
    this.ip,
    this.city,
    this.region,
    this.country,
    this.loc,
    this.org,
    this.postal,
    this.timezone,
    this.readme,
  });

  factory LeadGeoModel.fromJson(Map<String, dynamic> json) {
    return LeadGeoModel(
      ip: json['ip'],
      city: json['city'],
      region: json['region'],
      country: json['country'],
      loc: json['loc'],
      org: json['org'],
      postal: json['postal'],
      timezone: json['timezone'],
      readme: json['readme'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ip': ip,
      'city': city,
      'region': region,
      'country': country,
      'loc': loc,
      'org': org,
      'postal': postal,
      'timezone': timezone,
      'readme': readme,
    };
  }
}

// ============================================================
// CHAT
// ============================================================

class LeadChatModel {
  String? senderType;
  String? message;
  String? createdAt;

  LeadChatModel({this.senderType, this.message, this.createdAt});

  factory LeadChatModel.fromJson(Map<String, dynamic> json) {
    return LeadChatModel(
      senderType: json['senderType'],
      message: json['message'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderType': senderType,
      'message': message,
      'created_at': createdAt,
    };
  }
}

// ============================================================
// NOTES
// ============================================================

class LeadNoteModel {
  String? activitySource;
  String? message;
  String? createdAt;

  LeadNoteModel({this.activitySource, this.message, this.createdAt});

  factory LeadNoteModel.fromJson(Map<String, dynamic> json) {
    return LeadNoteModel(
      activitySource: json['activitySource'],
      message: json['message'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activitySource': activitySource,
      'message': message,
      'createdAt': createdAt,
    };
  }
}

// ============================================================
// PAGINATION
// ============================================================

class LeadPaginationModel {
  int? total;
  int? page;
  int? limit;
  int? totalPages;
  bool? hasNextPage;
  bool? hasPrevPage;

  LeadPaginationModel({
    this.total,
    this.page,
    this.limit,
    this.totalPages,
    this.hasNextPage,
    this.hasPrevPage,
  });

  factory LeadPaginationModel.fromJson(Map<String, dynamic> json) {
    return LeadPaginationModel(
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      totalPages: json['totalPages'],
      hasNextPage: json['hasNextPage'],
      hasPrevPage: json['hasPrevPage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
      'hasPrevPage': hasPrevPage,
    };
  }
}
