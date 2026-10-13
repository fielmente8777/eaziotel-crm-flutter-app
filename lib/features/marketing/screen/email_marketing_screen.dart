// ============================================================
// EMAIL MARKETING SCREEN  (Drawer > Marketing > Email Marketing)
//
// "EazoMail": Recipients / Campaigns / Templates
//   window : left side menu
//   phone  : upar chips
// Campaign par tap -> stats + email ka text (bottom sheet)
// ============================================================

import 'package:eazotel/utils/res/t_responsive_builder.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../setting_screen/screen/widgets/setting_section_card.dart';
import '../controller/email_marketing_controller.dart';
import '../models/marketing_models.dart';
import 'widgets/marketing_common.dart';

class EmailMarketingScreen extends StatelessWidget {
  const EmailMarketingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmailMarketingController());

    return Scaffold(
      appBar: AppBar(title: const Text('EazoMail')),
      body: SafeArea(
        child: TResponsiveBuilder(
          builder: (context, r) => Obx(() {
            final body = switch (controller.section.value) {
              EmailSection.recipients => _RecipientsView(
                controller: controller,
              ),
              EmailSection.campaigns => _CampaignsView(controller: controller),
              EmailSection.templates => const MarketingState(
                icon: Icons.dashboard_customize_outlined,
                message:
                    'Templates are coming soon.\nPlease use the web dashboard for now.',
              ),
            };

            if (r.isDesktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200,
                    child: _SideMenu(controller: controller),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: body),
                ],
              );
            }

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    r.pagePadding,
                    8,
                    r.pagePadding,
                    4,
                  ),
                  child: _ChipMenu(controller: controller),
                ),
                Expanded(child: body),
              ],
            );
          }),
        ),
      ),
    );
  }
}

String _countFor(EmailMarketingController c, EmailSection s) =>
    s == EmailSection.recipients ? '${c.recipientPage.value.total}' : '';

class _SideMenu extends StatelessWidget {
  const _SideMenu({required this.controller});

  final EmailMarketingController controller;

  @override
  Widget build(BuildContext context) {
    final icons = {
      EmailSection.recipients: Icons.people_outline,
      EmailSection.campaigns: Icons.send_outlined,
      EmailSection.templates: Icons.dashboard_customize_outlined,
    };

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        for (final s in EmailSection.values)
          ListTile(
            dense: true,
            selected: controller.section.value == s,
            leading: Icon(icons[s], size: 18),
            title: Text(s.label),
            trailing: Text(_countFor(controller, s)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onTap: () => controller.section.value = s,
          ),
      ],
    );
  }
}

class _ChipMenu extends StatelessWidget {
  const _ChipMenu({required this.controller});

  final EmailMarketingController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final s in EmailSection.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  [
                    s.label,
                    _countFor(controller, s),
                  ].where((e) => e.isNotEmpty).join(' '),
                ),
                selected: controller.section.value == s,
                onSelected: (_) => controller.section.value = s,
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// RECIPIENTS
// ============================================================

class _RecipientsView extends StatelessWidget {
  const _RecipientsView({required this.controller});

  final EmailMarketingController controller;

  @override
  Widget build(BuildContext context) {
    // Search / loading / page badalne par dobara bane
    return Obx(() {
      final p = SettingPalette(context);
      final c = controller;
      final list = c.visibleRecipients;

      Widget content;
      if (c.isRecipientsLoading.value) {
        content = const MarketingState(
          icon: Icons.people_outline,
          message: 'Loading recipients...',
          loading: true,
        );
      } else if (c.recipientsError.value != null) {
        content = MarketingState(
          icon: Icons.error_outline,
          message: c.recipientsError.value!,
          onRetry: () => c.loadRecipients(c.recipientPage.value.page),
        );
      } else if (list.isEmpty) {
        content = const MarketingState(
          icon: Icons.people_outline,
          message: 'No recipients found',
        );
      } else {
        content = Column(
          children: [
            for (final r in list)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: p.primary.withValues(alpha: 0.15),
                  child: Text(
                    r.name.isEmpty ? '?' : r.name[0].toUpperCase(),
                    style: TextStyle(color: p.primary, fontSize: 13),
                  ),
                ),
                title: Text(
                  r.name.isEmpty ? '-' : r.name,
                  style: TextStyle(color: p.text, fontSize: 13.5),
                ),
                subtitle: Text(
                  r.email,
                  style: TextStyle(color: p.subText, fontSize: 12),
                ),
              ),
          ],
        );
      }

      return RefreshIndicator(
        onRefresh: () => c.loadRecipients(c.recipientPage.value.page),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            TextField(
              onChanged: (v) => c.recipientSearch.value = v,
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Search recipients by name or email',
                prefixIcon: Icon(Icons.search, size: 18),
              ),
            ),
            const SizedBox(height: 8),
            content,
            const Divider(),
            PagerBar(
              page: c.recipientPage.value,
              shown: c.recipients.length,
              onPage: c.loadRecipients,
            ),
          ],
        ),
      );
    });
  }
}

// ============================================================
// CAMPAIGNS
// ============================================================

class _CampaignsView extends StatelessWidget {
  const _CampaignsView({required this.controller});

  final EmailMarketingController controller;

  @override
  Widget build(BuildContext context) {
    // Search / loading / page badalne par dobara bane
    return Obx(() {
      final p = SettingPalette(context);
      final c = controller;

      Widget content;
      if (c.isCampaignsLoading.value) {
        content = const MarketingState(
          icon: Icons.send_outlined,
          message: 'Loading campaigns...',
          loading: true,
        );
      } else if (c.campaignsError.value != null) {
        content = MarketingState(
          icon: Icons.error_outline,
          message: c.campaignsError.value!,
          onRetry: () => c.loadCampaigns(c.campaignPage.value.page),
        );
      } else if (c.campaigns.isEmpty) {
        content = const MarketingState(
          icon: Icons.send_outlined,
          message: 'No campaigns found',
        );
      } else {
        content = Column(
          children: [
            for (final campaign in c.campaigns)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: p.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: p.border),
                ),
                child: ListTile(
                  onTap: () => _showCampaign(context, campaign),
                  title: Text(
                    campaign.subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: p.text, fontSize: 13.5),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${campaign.recipientCount} recipients  •  '
                      'Sent ${campaign.stat('sent')}  •  '
                      'Failed ${campaign.stat('failed')}  •  '
                      '${formatDateTime(campaign.createdAt)}',
                      style: TextStyle(color: p.subText, fontSize: 11.5),
                    ),
                  ),
                  trailing: StatusPill(status: campaign.status),
                ),
              ),
          ],
        );
      }

      return RefreshIndicator(
        onRefresh: () => c.loadCampaigns(c.campaignPage.value.page),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            content,
            const Divider(),
            PagerBar(
              page: c.campaignPage.value,
              shown: c.campaigns.length,
              onPage: c.loadCampaigns,
            ),
          ],
        ),
      );
    });
  }

  void _showCampaign(BuildContext context, EmailCampaign campaign) {
    final p = SettingPalette(context);

    final stats = [
      ('Sent', 'sent', TAppColors.success),
      ('Delivered', 'delivered', TAppColors.success),
      ('Failed', 'failed', TAppColors.error),
      ('Opened', 'opened', const Color(0xFF8B5CF6)),
      ('Clicked', 'clicked', TAppColors.info),
      ('Unsubscribed', 'unsubscribed', TAppColors.warning),
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: p.card,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (_, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              campaign.subject,
              style: TextStyle(
                color: p.text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
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
                final columns = box.maxWidth > 500 ? 6 : 3;
                final width = (box.maxWidth - 8 * (columns - 1)) / columns;

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (label, key, color) in stats)
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
            const SizedBox(height: 16),
            Text(
              'Email content',
              style: TextStyle(color: p.text, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.inner,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                campaign.text.isEmpty ? '-' : campaign.text,
                style: TextStyle(color: p.text, fontSize: 13, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
