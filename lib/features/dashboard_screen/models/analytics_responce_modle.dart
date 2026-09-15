class AnalyticsResponse {
  final bool? success;
  final int? responseStatusCode;
  final String? responseMessage;
  final AnalyticsRequest? request;
  final AnalyticsResult? result;

  AnalyticsResponse({
    this.success,
    this.responseStatusCode,
    this.responseMessage,
    this.request,
    this.result,
  });

  factory AnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return AnalyticsResponse(
      success: json['success'],
      responseStatusCode: json['responseStatusCode'],
      responseMessage: json['responseMessage'],
      request: json['request'] != null
          ? AnalyticsRequest.fromJson(json['request'])
          : null,
      result: json['result'] != null
          ? AnalyticsResult.fromJson(json['result'])
          : null,
    );
  }
}

class AnalyticsRequest {
  final String? method;
  final String? basesurl;
  final String? endpoint;

  AnalyticsRequest({
    this.method,
    this.basesurl,
    this.endpoint,
  });

  factory AnalyticsRequest.fromJson(Map<String, dynamic> json) {
    return AnalyticsRequest(
      method: json['method'],
      basesurl: json['basesurl'],
      endpoint: json['endpoint'],
    );
  }
}

class AnalyticsResult {
  final bool? success;
  final AnalyticsDocs? docs;

  AnalyticsResult({
    this.success,
    this.docs,
  });

  factory AnalyticsResult.fromJson(Map<String, dynamic> json) {
    return AnalyticsResult(
      success: json['success'],
      docs: json['docs'] != null
          ? AnalyticsDocs.fromJson(json['docs'])
          : null,
    );
  }
}

class AnalyticsDocs {
  final List<CountData>? totalLeads;
  final List<BreakdownData>? sourceBreakdown;
  final List<BreakdownData>? statusBreakdown;
  final List<CountData>? convertedLeads;
  final int? totalWhatsappConversations;
  final int? todayLeads;

  AnalyticsDocs({
    this.totalLeads,
    this.sourceBreakdown,
    this.statusBreakdown,
    this.convertedLeads,
    this.totalWhatsappConversations,
    this.todayLeads,
  });

  factory AnalyticsDocs.fromJson(Map<String, dynamic> json) {
    return AnalyticsDocs(
      totalLeads: (json['totalLeads'] as List?)
          ?.map((e) => CountData.fromJson(e))
          .toList(),

      sourceBreakdown: (json['sourceBreakdown'] as List?)
          ?.map((e) => BreakdownData.fromJson(e))
          .toList(),

      statusBreakdown: (json['statusBreakdown'] as List?)
          ?.map((e) => BreakdownData.fromJson(e))
          .toList(),

      convertedLeads: (json['convertedLeads'] as List?)
          ?.map((e) => CountData.fromJson(e))
          .toList(),

      totalWhatsappConversations: json['totalWhatsappConversations'],
      todayLeads: json['todayLeads'],
    );
  }
}

class CountData {
  final int? count;

  CountData({
    this.count,
  });

  factory CountData.fromJson(Map<String, dynamic> json) {
    return CountData(
      count: json['count'],
    );
  }
}

class BreakdownData {
  final String? id;
  final int? count;

  BreakdownData({
    this.id,
    this.count,
  });

  factory BreakdownData.fromJson(Map<String, dynamic> json) {
    return BreakdownData(
      id: json['_id']?.toString(),
      count: json['count'],
    );
  }
}