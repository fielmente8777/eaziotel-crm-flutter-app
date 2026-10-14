// ============================================================
// SEO INTELLIGENCE RESPONSE
// GET /api/v1/seo/seo-intelligence
//
//   result.keywords      : saare keyword (targetUrl hai = Website SEO,
//                          nahi hai = Local SEO)
//   result.localConfig   : property, shehar, radius, website url
//   result.geoGrid       : map coverage ke 25 point (rank ke saath)
//   result.gridMeta      : scan status (pending/scanning/done/failed)
//   result.trend         : roz ka average rank
//   result.summary       : totalKeywords, opportunities
//   result.staleKeywords : kitne keyword ka data purana hai
// ============================================================

import 'seo_common.dart';

class SeoIntelligenceResponse {
  final bool? success;
  final int? responseStatusCode;
  final String? responseMessage;
  final SeoRequest? request;
  final SeoIntelligence result;

  SeoIntelligenceResponse({
    this.success,
    this.responseStatusCode,
    this.responseMessage,
    this.request,
    this.result = const SeoIntelligence(),
  });

  factory SeoIntelligenceResponse.fromJson(Map<String, dynamic> json) {
    return SeoIntelligenceResponse(
      success: json['success'] as bool?,
      responseStatusCode: json['responseStatusCode'] as int?,
      responseMessage: json['responseMessage'] as String?,
      request: SeoRequest.tryParse(json['request']),
      result: SeoIntelligence.fromJson(seoBody(json)),
    );
  }

  /// Screen par turant badlav dikhane ke liye (API ke baad)
  SeoIntelligenceResponse copyWith({SeoIntelligence? result}) {
    return SeoIntelligenceResponse(
      success: success,
      responseStatusCode: responseStatusCode,
      responseMessage: responseMessage,
      request: request,
      result: result ?? this.result,
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

class SeoIntelligence {
  final SeoSummary summary;
  final List<SeoTrendPoint> trend;
  final List<SeoKeyword> keywords;
  final String provider;
  final List<SeoGridPoint> geoGrid;
  final SeoGridMeta gridMeta;
  final SeoLocalConfig? localConfig;
  final int staleKeywords;

  const SeoIntelligence({
    this.summary = const SeoSummary(),
    this.trend = const [],
    this.keywords = const [],
    this.provider = 'dataforseo',
    this.geoGrid = const [],
    this.gridMeta = const SeoGridMeta(),
    this.localConfig,
    this.staleKeywords = 0,
  });

  /// Local SEO page ke keyword (bina website link)
  List<SeoKeyword> get localKeywords =>
      keywords.where((k) => !k.isWebsite).toList();

  /// Website SEO page ke keyword
  List<SeoKeyword> get websiteKeywords =>
      keywords.where((k) => k.isWebsite).toList();

  factory SeoIntelligence.fromJson(Map<String, dynamic> json) {
    final config = json['localConfig'];
    final provider = seoStr(json['provider']);

    return SeoIntelligence(
      summary: SeoSummary.fromJson(seoMap(json['summary'])),
      trend: seoMaps(json['trend']).map(SeoTrendPoint.fromJson).toList(),
      keywords: seoMaps(json['keywords']).map(SeoKeyword.fromJson).toList(),
      provider: provider.isEmpty ? 'dataforseo' : provider,
      geoGrid: seoMaps(
        json['geoGrid'],
      ).map(SeoGridPoint.fromJson).where((p) => p.isValid).toList(),
      gridMeta: SeoGridMeta.fromJson(seoMap(json['gridMeta'])),
      localConfig: config is Map
          ? SeoLocalConfig.fromJson(seoMap(config))
          : null,
      staleKeywords: seoNum(json['staleKeywords']).round(),
    );
  }

  SeoIntelligence copyWith({
    List<SeoKeyword>? keywords,
    SeoGridMeta? gridMeta,
    SeoLocalConfig? localConfig,
  }) {
    return SeoIntelligence(
      summary: summary,
      trend: trend,
      keywords: keywords ?? this.keywords,
      provider: provider,
      geoGrid: geoGrid,
      gridMeta: gridMeta ?? this.gridMeta,
      localConfig: localConfig ?? this.localConfig,
      staleKeywords: staleKeywords,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary.toJson(),
      'trend': trend.map((t) => t.toJson()).toList(),
      'keywords': keywords.map((k) => k.toJson()).toList(),
      'provider': provider,
      'geoGrid': geoGrid.map((g) => g.toJson()).toList(),
      'gridMeta': gridMeta.toJson(),
      'localConfig': localConfig?.toJson(),
      'staleKeywords': staleKeywords,
    };
  }
}

class SeoSummary {
  final int? totalKeywords;
  final int? opportunities;

  const SeoSummary({this.totalKeywords, this.opportunities});

  factory SeoSummary.fromJson(Map<String, dynamic> json) {
    return SeoSummary(
      totalKeywords: seoNumOrNull(json['totalKeywords'])?.round(),
      opportunities: seoNumOrNull(json['opportunities'])?.round(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'totalKeywords': totalKeywords, 'opportunities': opportunities};
  }
}

class SeoTrendPoint {
  /// "2026-10-05"
  final String date;
  final double avgRank;

  const SeoTrendPoint({required this.date, required this.avgRank});

  /// Chart ke neeche: "10-05"
  String get label => date.length >= 10 ? date.substring(5, 10) : date;

  factory SeoTrendPoint.fromJson(Map<String, dynamic> json) {
    return SeoTrendPoint(
      date: seoStr(json['date']),
      avgRank: seoNum(json['avgRank']),
    );
  }

  Map<String, dynamic> toJson() => {'date': date, 'avgRank': avgRank};
}

class SeoKeyword {
  final String id;
  final String keyword;
  final double? searchVolume;
  final double? cpc;

  /// Google Maps (GMB) par rank
  final double? liveGmbRank;

  /// Google search (organic) par rank
  final double? liveOrganicRank;

  /// 0 - 100
  final double? keywordDifficulty;

  /// TARGET / OPTIMIZE / DEFEND / RESEARCH
  final String actionBadge;

  /// Website SEO wale keyword me website link
  final String targetUrl;
  final String topCompetitor;
  final List<SeoRankSnapshot> rankHistory;

  const SeoKeyword({
    required this.id,
    required this.keyword,
    this.searchVolume,
    this.cpc,
    this.liveGmbRank,
    this.liveOrganicRank,
    this.keywordDifficulty,
    this.actionBadge = 'RESEARCH',
    this.targetUrl = '',
    this.topCompetitor = '',
    this.rankHistory = const [],
  });

  bool get isWebsite => targetUrl.isNotEmpty;

  /// Ek list me pehchan (id na ho to keyword)
  String get key => id.isNotEmpty ? id : keyword;

  factory SeoKeyword.fromJson(Map<String, dynamic> json) {
    final badge = seoStr(json['actionBadge']).toUpperCase();

    return SeoKeyword(
      id: seoStr(json['_id']),
      keyword: seoStr(json['keyword']),
      searchVolume: seoNumOrNull(json['searchVolume']),
      cpc: seoNumOrNull(json['cpc']),
      liveGmbRank: seoNumOrNull(json['liveGmbRank']),
      liveOrganicRank: seoNumOrNull(json['liveOrganicRank']),
      keywordDifficulty: seoNumOrNull(json['keywordDifficulty']),
      actionBadge: badge.isEmpty ? 'RESEARCH' : badge,
      targetUrl: seoStr(json['targetUrl']),
      topCompetitor: seoStr(json['topCompetitor']),
      rankHistory: seoMaps(
        json['rankHistory'],
      ).map(SeoRankSnapshot.fromJson).where((s) => s.rank != null).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'keyword': keyword,
      'searchVolume': searchVolume,
      'cpc': cpc,
      'liveGmbRank': liveGmbRank,
      'liveOrganicRank': liveOrganicRank,
      'keywordDifficulty': keywordDifficulty,
      'actionBadge': actionBadge,
      'targetUrl': targetUrl,
      'topCompetitor': topCompetitor,
      'rankHistory': rankHistory.map((s) => s.toJson()).toList(),
    };
  }
}

class SeoRankSnapshot {
  final String date;
  final double? rank;

  const SeoRankSnapshot({required this.date, this.rank});

  /// "2026-10-05T..." -> "10-05"
  String get label => date.length >= 10 ? date.substring(5, 10) : date;

  factory SeoRankSnapshot.fromJson(Map<String, dynamic> json) {
    return SeoRankSnapshot(
      date: seoStr(json['date']),
      rank: seoNumOrNull(json['rank']),
    );
  }

  Map<String, dynamic> toJson() => {'date': date, 'rank': rank};
}

class SeoGridPoint {
  final double lat;
  final double lng;
  final double? rank;
  final int row;
  final int col;

  const SeoGridPoint({
    required this.lat,
    required this.lng,
    required this.row,
    required this.col,
    this.rank,
  });

  bool get isValid => lat != 0 || lng != 0;

  /// "#4" / "20+" / "—"
  String get label {
    final r = rank;
    if (r == null) return '—';
    if (r >= 20) return '20+';
    return '#${r.round()}';
  }

  factory SeoGridPoint.fromJson(Map<String, dynamic> json) {
    return SeoGridPoint(
      lat: seoNum(json['lat']),
      lng: seoNum(json['lng']),
      rank: seoNumOrNull(json['rank']),
      row: seoNum(json['row']).round(),
      col: seoNum(json['col']).round(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'lat': lat, 'lng': lng, 'rank': rank, 'row': row, 'col': col};
  }
}

class SeoGridMeta {
  final String? lastScanned;

  /// idle / pending / scanning / done / failed
  final String status;
  final String keyword;
  final int gridSize;

  const SeoGridMeta({
    this.lastScanned,
    this.status = 'idle',
    this.keyword = '',
    this.gridSize = 5,
  });

  DateTime? get lastScannedAt =>
      lastScanned == null ? null : DateTime.tryParse(lastScanned!)?.toLocal();

  factory SeoGridMeta.fromJson(Map<String, dynamic> json) {
    final status = seoStr(json['status']);
    final size = seoNum(json['gridSize']).round();

    return SeoGridMeta(
      lastScanned: json['lastScanned'] == null
          ? null
          : seoStr(json['lastScanned']),
      status: status.isEmpty ? 'idle' : status,
      keyword: seoStr(json['keyword']),
      gridSize: size > 0 ? size : 5,
    );
  }

  SeoGridMeta copyWith({String? status, String? keyword}) {
    return SeoGridMeta(
      lastScanned: lastScanned,
      status: status ?? this.status,
      keyword: keyword ?? this.keyword,
      gridSize: gridSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastScanned': lastScanned,
      'status': status,
      'keyword': keyword,
      'gridSize': gridSize,
    };
  }
}

class SeoLocalConfig {
  final String businessName;
  final String city;
  final String district;
  final String state;
  final int radiusKm;
  final double? lat;
  final double? lng;
  final bool onboardingComplete;
  final String selfDomain;

  /// Website SEO: lock kiya hua link
  final String websiteUrl;

  /// Website SEO: IN / US / ... / WORLD
  final String websiteCountry;

  const SeoLocalConfig({
    this.businessName = '',
    this.city = '',
    this.district = '',
    this.state = '',
    this.radiusKm = 5,
    this.lat,
    this.lng,
    this.onboardingComplete = false,
    this.selfDomain = '',
    this.websiteUrl = '',
    this.websiteCountry = '',
  });

  bool get hasLocation => lat != null && lng != null && (lat != 0 || lng != 0);

  /// "Indirapuram, Ghaziabad"
  String get area =>
      [district, city].where((s) => s.trim().isNotEmpty).join(', ');

  factory SeoLocalConfig.fromJson(Map<String, dynamic> json) {
    final radius = seoNum(json['radiusKm']).round();

    return SeoLocalConfig(
      businessName: seoStr(json['businessName']),
      city: seoStr(json['city']),
      district: seoStr(json['district']),
      state: seoStr(json['state']),
      radiusKm: radius > 0 ? radius : 5,
      lat: seoNumOrNull(json['lat']),
      lng: seoNumOrNull(json['lng']),
      onboardingComplete: json['onboardingComplete'] == true,
      selfDomain: seoStr(json['selfDomain']),
      websiteUrl: seoStr(json['websiteUrl']),
      websiteCountry: seoStr(json['websiteCountry']),
    );
  }

  SeoLocalConfig copyWith({int? radiusKm}) {
    return SeoLocalConfig(
      businessName: businessName,
      city: city,
      district: district,
      state: state,
      radiusKm: radiusKm ?? this.radiusKm,
      lat: lat,
      lng: lng,
      onboardingComplete: onboardingComplete,
      selfDomain: selfDomain,
      websiteUrl: websiteUrl,
      websiteCountry: websiteCountry,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'city': city,
      'district': district,
      'state': state,
      'radiusKm': radiusKm,
      'lat': lat,
      'lng': lng,
      'onboardingComplete': onboardingComplete,
      'selfDomain': selfDomain,
      'websiteUrl': websiteUrl,
      'websiteCountry': websiteCountry,
    };
  }
}
