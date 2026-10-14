// ============================================================
// SEO INSIGHT  (API nahi, keywords se banta hai - web jaisa)
//
//   mapsGap     : zyada search wala keyword, Map 3-Pack me nahi
//   almostThere : organic rank 4-10 (top 3 ke paas)
//   defend      : Map 3-Pack me hai, bachaye rakho
// ============================================================

import 'seo_intelligence_response.dart';

enum SeoInsightType { mapsGap, almostThere, defend }

class SeoInsight {
  final SeoInsightType type;
  final SeoKeyword keyword;

  const SeoInsight(this.type, this.keyword);

  static List<SeoInsight> build(List<SeoKeyword> keywords) {
    final out = <SeoInsight>[];

    final gap =
        keywords
            .where(
              (k) =>
                  (k.searchVolume ?? 0) >= 30 &&
                  (k.liveGmbRank == null || k.liveGmbRank! > 3),
            )
            .toList()
          ..sort(
            (a, b) => (b.searchVolume ?? 0).compareTo(a.searchVolume ?? 0),
          );
    if (gap.isNotEmpty) out.add(SeoInsight(SeoInsightType.mapsGap, gap.first));

    final close =
        keywords
            .where(
              (k) =>
                  k.liveOrganicRank != null &&
                  k.liveOrganicRank! > 3 &&
                  k.liveOrganicRank! <= 10,
            )
            .toList()
          ..sort((a, b) => a.liveOrganicRank!.compareTo(b.liveOrganicRank!));
    if (close.isNotEmpty) {
      out.add(SeoInsight(SeoInsightType.almostThere, close.first));
    }

    final defend =
        keywords
            .where((k) => k.liveGmbRank != null && k.liveGmbRank! <= 3)
            .toList()
          ..sort(
            (a, b) => (b.searchVolume ?? 0).compareTo(a.searchVolume ?? 0),
          );
    if (defend.isNotEmpty) {
      out.add(SeoInsight(SeoInsightType.defend, defend.first));
    }

    return out;
  }
}
