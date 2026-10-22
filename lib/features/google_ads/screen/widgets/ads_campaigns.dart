// ============================================================
// ADS CAMPAIGNS
//
//   CampaignComparison : campaigns by spend (tap -> that campaign)
//                        table on window/tablet, card on phone
//   AdPreviewCard      : preview of the ad like Google Search
// ============================================================

import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../setting_screen/screen/widgets/setting_section_card.dart';
import '../../models/google_ads_ad_response.dart';
import '../../models/google_ads_summary_response.dart';
import 'ads_common.dart';

class CampaignComparison extends StatelessWidget {
  const CampaignComparison({
    super.key,
    required this.rows,
    required this.wide,
    required this.onTap,
  });

  final List<GoogleAdsCampaignRow> rows;
  final bool wide;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const EmptyMini(
        text: 'No campaign rollup available yet. Try a Sync.',
      );
    }

    return wide ? _table(context) : _cards(context);
  }

  Widget _roas(double roas) {
    if (roas <= 0) {
      return const Text('N/A', style: TextStyle(fontSize: 12));
    }

    final color = roas >= 1 ? TAppColors.success : TAppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${AdsFormat.decimal(roas)}×',
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _table(BuildContext context) {
    final p = SettingPalette(context);

    Widget cell(String text, {int flex = 2, bool right = true, Color? color}) =>
        Expanded(
          flex: flex,
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: right ? TextAlign.right : TextAlign.left,
            style: TextStyle(color: color ?? p.subText, fontSize: 12.5),
          ),
        );

    final head = TextStyle(
      color: p.subText,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(flex: 5, child: Text('CAMPAIGN', style: head)),
              for (final h in [
                'IMPR.',
                'CLICKS',
                'CTR',
                'COST',
                'CONV.',
                'ROAS',
              ])
                Expanded(
                  flex: 2,
                  child: Text(h, textAlign: TextAlign.right, style: head),
                ),
            ],
          ),
        ),
        for (final r in rows)
          InkWell(
            onTap: () => onTap(r.campaignId),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: p.border)),
              ),
              child: Row(
                children: [
                  cell(r.name, flex: 5, right: false, color: p.text),
                  cell(AdsFormat.compact(r.summary.totals.impressions)),
                  cell(AdsFormat.compact(r.summary.totals.clicks)),
                  cell(AdsFormat.percent(r.summary.derived.ctr)),
                  cell(AdsFormat.moneyCompact(r.summary.totals.cost)),
                  cell(AdsFormat.number(r.summary.totals.conversions)),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _roas(r.summary.derived.roas),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _cards(BuildContext context) {
    final p = SettingPalette(context);

    Widget stat(String label, String value) => Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: p.text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(label, style: TextStyle(color: p.subText, fontSize: 10.5)),
        ],
      ),
    );

    return Column(
      children: [
        for (final r in rows)
          InkWell(
            onTap: () => onTap(r.campaignId),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.inner,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          r.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: p.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _roas(r.summary.derived.roas),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      stat(
                        'Impr.',
                        AdsFormat.compact(r.summary.totals.impressions),
                      ),
                      stat(
                        'Clicks',
                        AdsFormat.compact(r.summary.totals.clicks),
                      ),
                      stat('CTR', AdsFormat.percent(r.summary.derived.ctr)),
                      stat(
                        'Cost',
                        AdsFormat.moneyCompact(r.summary.totals.cost),
                      ),
                      stat(
                        'Conv.',
                        AdsFormat.number(r.summary.totals.conversions),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class AdPreviewCard extends StatelessWidget {
  const AdPreviewCard({super.key, required this.ad});

  final GoogleAdsAd ad;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final link = p.isDark ? const Color(0xFF8AB4F8) : const Color(0xFF1A0DAB);

    if (ad.headlines.isEmpty) {
      return const EmptyMini(
        text: 'Display / image ad preview is not supported yet.',
        height: 110,
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Sponsored',
                style: TextStyle(
                  color: p.text,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ad.displayUrl.isEmpty ? 'www.website.com' : ad.displayUrl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: p.subText, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: ad.finalUrl.isEmpty
                ? null
                : () => launchUrl(
                    Uri.parse(ad.finalUrl),
                    mode: LaunchMode.externalApplication,
                  ),
            child: Text(
              ad.headlines.take(3).join(' | '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: link,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ad.descriptions.take(2).join(' - '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: p.subText, fontSize: 12.5, height: 1.4),
          ),
        ],
      ),
    );
  }
}
