// ============================================================
// GOOGLE ADS SUMMARY RESPONSE
// GET /api/v1/google-ads/metrics/summary/<id>?level=&startDate=&endDate=
//
//   result.totals  : impressions, clicks, cost, conversions, conversionsValue
//   result.derived : ctr, averageCpc, conversionRate, costPerConversion, roas,
//                    searchImpressionShare, searchImpressionShareApprox
//   result.series  : har din ka data (charts)
// ============================================================

import 'google_ads_common.dart';

class GoogleAdsSummaryResponse {
  final bool? success;
  final int? responseStatusCode;
  final String? responseMessage;
  final GoogleAdsRequest? request;
  final GoogleAdsSummary result;

  GoogleAdsSummaryResponse({
    this.success,
    this.responseStatusCode,
    this.responseMessage,
    this.request,
    this.result = const GoogleAdsSummary(),
  });

  factory GoogleAdsSummaryResponse.fromJson(Map<String, dynamic> json) {
    return GoogleAdsSummaryResponse(
      success: json['success'] as bool?,
      responseStatusCode: json['responseStatusCode'] as int?,
      responseMessage: json['responseMessage'] as String?,
      request: GoogleAdsRequest.tryParse(json['request']),
      result: json['result'] is Map
          ? GoogleAdsSummary.fromJson(Map<String, dynamic>.from(json['result']))
          : const GoogleAdsSummary(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'responseStatusCode': responseStatusCode,
      'responseMessage': responseMessage,
      'request': request?.toJson(),
      'result': result.toJson(),
    };
  }
}

class GoogleAdsSummary {
  final GoogleAdsTotals totals;
  final GoogleAdsDerived derived;
  final List<GoogleAdsDayPoint> series;

  const GoogleAdsSummary({
    this.totals = const GoogleAdsTotals(),
    this.derived = const GoogleAdsDerived(),
    this.series = const [],
  });

  /// Web jaisa: totals sab 0 ho to "data nahi"
  bool get hasData => !totals.isEmpty;

  factory GoogleAdsSummary.fromJson(Map<String, dynamic> json) {
    final series = json['series'];

    return GoogleAdsSummary(
      totals: json['totals'] is Map
          ? GoogleAdsTotals.fromJson(Map<String, dynamic>.from(json['totals']))
          : const GoogleAdsTotals(),
      derived: json['derived'] is Map
          ? GoogleAdsDerived.fromJson(
              Map<String, dynamic>.from(json['derived']),
            )
          : const GoogleAdsDerived(),
      series: series is List
          ? series
                .whereType<Map>()
                .map(
                  (e) =>
                      GoogleAdsDayPoint.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totals': totals.toJson(),
      'derived': derived.toJson(),
      'series': series.map((p) => p.toJson()).toList(),
    };
  }
}

class GoogleAdsTotals {
  final double impressions;
  final double clicks;
  final double cost;
  final double conversions;
  final double conversionsValue;

  const GoogleAdsTotals({
    this.impressions = 0,
    this.clicks = 0,
    this.cost = 0,
    this.conversions = 0,
    this.conversionsValue = 0,
  });

  bool get isEmpty => impressions == 0 && clicks == 0 && cost == 0;

  factory GoogleAdsTotals.fromJson(Map<String, dynamic> json) {
    return GoogleAdsTotals(
      impressions: adsNum(json['impressions']),
      clicks: adsNum(json['clicks']),
      cost: adsNum(json['cost']),
      conversions: adsNum(json['conversions']),
      conversionsValue: adsNum(json['conversionsValue']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'impressions': impressions,
      'clicks': clicks,
      'cost': cost,
      'conversions': conversions,
      'conversionsValue': conversionsValue,
    };
  }
}

class GoogleAdsDerived {
  /// 0.05 = 5%
  final double ctr;
  final double averageCpc;
  final double conversionRate;
  final double costPerConversion;
  final double roas;

  /// null = data nahi (ad level par nahi aata)
  final double? searchImpressionShare;
  final bool searchImpressionShareApprox;

  const GoogleAdsDerived({
    this.ctr = 0,
    this.averageCpc = 0,
    this.conversionRate = 0,
    this.costPerConversion = 0,
    this.roas = 0,
    this.searchImpressionShare,
    this.searchImpressionShareApprox = false,
  });

  factory GoogleAdsDerived.fromJson(Map<String, dynamic> json) {
    return GoogleAdsDerived(
      ctr: adsNum(json['ctr']),
      averageCpc: adsNum(json['averageCpc']),
      conversionRate: adsNum(json['conversionRate']),
      costPerConversion: adsNum(json['costPerConversion']),
      roas: adsNum(json['roas']),
      searchImpressionShare: json['searchImpressionShare'] == null
          ? null
          : adsNum(json['searchImpressionShare']),
      searchImpressionShareApprox: json['searchImpressionShareApprox'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ctr': ctr,
      'averageCpc': averageCpc,
      'conversionRate': conversionRate,
      'costPerConversion': costPerConversion,
      'roas': roas,
      'searchImpressionShare': searchImpressionShare,
      'searchImpressionShareApprox': searchImpressionShareApprox,
    };
  }
}

class GoogleAdsDayPoint {
  /// "2026-10-05"
  final String date;
  final double impressions;
  final double clicks;
  final double cost;
  final double conversions;
  final double conversionsValue;

  const GoogleAdsDayPoint({
    required this.date,
    this.impressions = 0,
    this.clicks = 0,
    this.cost = 0,
    this.conversions = 0,
    this.conversionsValue = 0,
  });

  /// Chart ke neeche: "10-05"
  String get label => date.length >= 10 ? date.substring(5, 10) : date;

  factory GoogleAdsDayPoint.fromJson(Map<String, dynamic> json) {
    return GoogleAdsDayPoint(
      date: adsStr(json['date']),
      impressions: adsNum(json['impressions']),
      clicks: adsNum(json['clicks']),
      cost: adsNum(json['cost']),
      conversions: adsNum(json['conversions']),
      conversionsValue: adsNum(json['conversionsValue']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'impressions': impressions,
      'clicks': clicks,
      'cost': cost,
      'conversions': conversions,
      'conversionsValue': conversionsValue,
    };
  }
}

/// Campaign Comparison table ki ek line (har campaign ka summary)
class GoogleAdsCampaignRow {
  final String campaignId;
  final String name;
  final GoogleAdsSummary summary;

  const GoogleAdsCampaignRow({
    required this.campaignId,
    required this.name,
    required this.summary,
  });
}
