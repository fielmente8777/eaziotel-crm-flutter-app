// ============================================================
// GOOGLE ADS MODELS
//
//   AdsOption      : Account / Campaign / Ad Group / Ad dropdown ki ek line
//   AdsAd          : ek ad (headline, description, link) -> Live Ad Preview
//   AdsTotals      : impressions, clicks, cost, conversions, conv. value
//   AdsDerived     : CTR, Avg CPC, Conv. Rate, Cost/Conv, ROAS, Impr. Share
//   AdsDayPoint    : chart ka ek din
//   AdsSummary     : totals + derived + series (metrics/summary API)
//   AdsDeviceSlice : device ke hisaab se clicks
//   AdsCampaignRow : Campaign Comparison table ki line
// ============================================================

double _num(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;

String _str(dynamic v) {
  final text = v?.toString().trim() ?? '';
  return text == 'null' ? '' : text;
}

/// Web jaisa: sirf ENABLED (ya "2") wale dikhte hain
bool isEnabledStatus(dynamic status) {
  final s = _str(status).toUpperCase();
  return s == 'ENABLED' || s == '2';
}

class AdsOption {
  const AdsOption({required this.id, required this.label});

  final String id;
  final String label;
}

class AdsAd {
  const AdsAd({
    required this.id,
    required this.headlines,
    required this.descriptions,
    required this.finalUrl,
  });

  final String id;
  final List<String> headlines;
  final List<String> descriptions;
  final String finalUrl;

  /// "www.example.com" (link na ho to khali)
  String get displayUrl => Uri.tryParse(finalUrl)?.host ?? '';

  factory AdsAd.fromJson(Map<String, dynamic> json) {
    // headline kabhi {"text": ".."} hota hai, kabhi seedha text
    List<String> texts(dynamic list) => list is List
        ? list
              .map((e) => e is Map ? _str(e['text']) : _str(e))
              .where((t) => t.isNotEmpty)
              .toList()
        : const [];

    final urls = json['finalUrls'];

    return AdsAd(
      id: _str(json['adId']),
      headlines: texts(json['headlines']),
      descriptions: texts(json['descriptions']),
      finalUrl: urls is List && urls.isNotEmpty ? _str(urls.first) : '',
    );
  }
}

class AdsTotals {
  const AdsTotals({
    this.impressions = 0,
    this.clicks = 0,
    this.cost = 0,
    this.conversions = 0,
    this.conversionsValue = 0,
  });

  final double impressions;
  final double clicks;
  final double cost;
  final double conversions;
  final double conversionsValue;

  bool get isEmpty => impressions == 0 && clicks == 0 && cost == 0;

  factory AdsTotals.fromJson(dynamic json) => json is Map
      ? AdsTotals(
          impressions: _num(json['impressions']),
          clicks: _num(json['clicks']),
          cost: _num(json['cost']),
          conversions: _num(json['conversions']),
          conversionsValue: _num(json['conversionsValue']),
        )
      : const AdsTotals();
}

class AdsDerived {
  const AdsDerived({
    this.ctr = 0,
    this.averageCpc = 0,
    this.conversionRate = 0,
    this.costPerConversion = 0,
    this.roas = 0,
    this.impressionShare,
    this.impressionShareApprox = false,
  });

  /// 0.05 = 5%
  final double ctr;
  final double averageCpc;
  final double conversionRate;
  final double costPerConversion;
  final double roas;

  /// null = data nahi
  final double? impressionShare;
  final bool impressionShareApprox;

  factory AdsDerived.fromJson(dynamic json) => json is Map
      ? AdsDerived(
          ctr: _num(json['ctr']),
          averageCpc: _num(json['averageCpc']),
          conversionRate: _num(json['conversionRate']),
          costPerConversion: _num(json['costPerConversion']),
          roas: _num(json['roas']),
          impressionShare: json['searchImpressionShare'] == null
              ? null
              : _num(json['searchImpressionShare']),
          impressionShareApprox: json['searchImpressionShareApprox'] == true,
        )
      : const AdsDerived();
}

class AdsDayPoint {
  const AdsDayPoint({
    required this.date,
    required this.clicks,
    required this.conversions,
    required this.cost,
    required this.conversionsValue,
  });

  /// "2026-10-05"
  final String date;
  final double clicks;
  final double conversions;
  final double cost;
  final double conversionsValue;

  /// "10-05"
  String get label => date.length >= 10 ? date.substring(5, 10) : date;

  factory AdsDayPoint.fromJson(Map<String, dynamic> json) => AdsDayPoint(
    date: _str(json['date']),
    clicks: _num(json['clicks']),
    conversions: _num(json['conversions']),
    cost: _num(json['cost']),
    conversionsValue: _num(json['conversionsValue']),
  );
}

class AdsSummary {
  const AdsSummary({
    this.totals = const AdsTotals(),
    this.derived = const AdsDerived(),
    this.series = const [],
  });

  final AdsTotals totals;
  final AdsDerived derived;
  final List<AdsDayPoint> series;

  /// Web jaisa: totals sab 0 ho to "data nahi"
  bool get hasData => !totals.isEmpty;

  factory AdsSummary.fromJson(dynamic json) {
    if (json is! Map) return const AdsSummary();

    final series = json['series'];

    return AdsSummary(
      totals: AdsTotals.fromJson(json['totals']),
      derived: AdsDerived.fromJson(json['derived']),
      series: series is List
          ? series
                .whereType<Map>()
                .map((e) => AdsDayPoint.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
    );
  }
}

class AdsDeviceSlice {
  const AdsDeviceSlice({required this.name, required this.clicks});

  final String name;
  final double clicks;

  /// Google ka device number -> naam
  static const Map<String, String> names = {
    '2': 'Mobile',
    '3': 'Tablet',
    '4': 'Desktop',
    '5': 'Smart TV',
    '6': 'Other',
  };

  /// API list -> device ke naam se jodi hui clicks (0 wale hata kar)
  static List<AdsDeviceSlice> group(List<dynamic> rows) {
    final map = <String, double>{};

    for (final row in rows.whereType<Map>()) {
      final name = names[_str(row['device'])] ?? 'Other';
      map[name] = (map[name] ?? 0) + _num(row['clicks']);
    }

    return [
      for (final e in map.entries)
        if (e.value > 0) AdsDeviceSlice(name: e.key, clicks: e.value),
    ];
  }
}

class AdsCampaignRow {
  const AdsCampaignRow({
    required this.id,
    required this.name,
    required this.totals,
    required this.derived,
  });

  final String id;
  final String name;
  final AdsTotals totals;
  final AdsDerived derived;
}
