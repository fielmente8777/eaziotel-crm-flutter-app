// ============================================================
// EMAIL CAMPAIGN DETAIL SCREEN  (EazoMail > Campaigns > tap)
//
//   Subject + status + from + date
//   Sent | Delivered | Failed | Opened | Clicked | Unsubscribed
//   [All] [Pending] [Sent] [Failed] [Opened] [Clicked]
//   recipients (page by page)
//   Email content (jaisa gaya waisa)
// ============================================================

import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../setting_screen/screen/widgets/setting_section_card.dart';
import '../controller/email_marketing_controller.dart';
import 'widgets/email_html_preview.dart';
import 'widgets/marketing_common.dart';

class EmailCampaignDetailScreen extends StatelessWidget {
  const EmailCampaignDetailScreen({super.key});

  static const _statusTabs = [
    ('', 'All'),
    ('pending', 'Pending'),
    ('sent', 'Sent'),
    ('failed', 'Failed'),
    ('opened', 'Opened'),
    ('clicked', 'Clicked'),
  ];

  static const _stats = [
    ('Sent', 'sent', TAppColors.success),
    ('Delivered', 'delivered', TAppColors.success),
    ('Failed', 'failed', TAppColors.error),
    ('Opened', 'opened', Color(0xFF8B5CF6)),
    ('Clicked', 'clicked', TAppColors.info),
    ('Unsubscribed', 'unsubscribed', TAppColors.warning),
  ];

  @override
  Widget build(BuildContext context) {
    final c = Get.find<EmailMarketingController>();
    final p = SettingPalette(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Campaign')),
      body: SafeArea(
        child: Obx(() {
          final campaign = c.detail.value;
          if (campaign == null) {
            return const MarketingState(
              icon: Icons.send_outlined,
              message: 'Campaign not found',
            );
          }

          final list = c.detailRecipients;

          Widget recipients;
          if (c.isDetailLoading.value) {
            recipients = const MarketingState(
              icon: Icons.people_outline,
              message: 'Loading recipients...',
              loading: true,
            );
          } else if (c.detailError.value != null) {
            recipients = MarketingState(
              icon: Icons.error_outline,
              message: c.detailError.value!,
              onRetry: () => c.loadDetailRecipients(c.detailPage.value.page),
            );
          } else if (list.isEmpty) {
            recipients = const MarketingState(
              icon: Icons.people_outline,
              message: 'No recipients in this list',
            );
          } else {
            recipients = Column(
              children: [
                for (final r in list)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: p.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: p.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: p.primary.withValues(alpha: .14),
                          child: Text(
                            (r.name.isNotEmpty ? r.name : r.email)
                                .characters
                                .first
                                .toUpperCase(),
                            style: TextStyle(color: p.primary, fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.name.isEmpty ? r.email : r.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: p.text,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (r.name.isNotEmpty)
                                Text(
                                  r.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: p.subText,
                                    fontSize: 12,
                                  ),
                                ),
                              if (r.error.isNotEmpty)
                                Text(
                                  r.error,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: TAppColors.error,
                                    fontSize: 11.5,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            StatusPill(status: r.status),
                            if (r.sentAt != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                formatDateTime(r.sentAt),
                                style: TextStyle(
                                  color: p.subText,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }

          return RefreshIndicator(
            onRefresh: () => c.loadDetailRecipients(c.detailPage.value.page),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  children: [
                    Text(
                      campaign.subject,
                      style: TextStyle(
                        color: p.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusPill(status: campaign.status),
                        Text(
                          '${campaign.recipientCount} recipients  •  '
                          '${formatDateTime(campaign.createdAt)}',
                          style: TextStyle(color: p.subText, fontSize: 12),
                        ),
                      ],
                    ),
                    if (campaign.fromEmail.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'From: ${campaign.fromEmail}',
                        style: TextStyle(color: p.subText, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 14),
                    LayoutBuilder(
                      builder: (_, box) {
                        final columns = box.maxWidth > 560 ? 6 : 3;
                        final width =
                            (box.maxWidth - 8 * (columns - 1)) / columns;

                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final (label, key, color) in _stats)
                              SizedBox(
                                width: width,
                                child: StatTile(
                                  label: label,
                                  value: campaign.stat(key),
                                  color: color,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Recipients',
                      style: TextStyle(
                        color: p.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final (value, label) in _statusTabs)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(label),
                                selected: c.detailStatus.value == value,
                                onSelected: (_) => c.changeDetailStatus(value),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    recipients,
                    if (list.isNotEmpty)
                      PagerBar(
                        page: c.detailPage.value,
                        shown: list.length,
                        onPage: c.loadDetailRecipients,
                      ),
                    const SizedBox(height: 18),
                    Text(
                      'Email content',
                      style: TextStyle(
                        color: p.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (campaign.html.isNotEmpty)
                      EmailHtmlPreview(html: campaign.html)
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: p.inner,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SelectableText(
                          campaign.text.isEmpty ? '-' : campaign.text,
                          style: TextStyle(
                            color: p.text,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
