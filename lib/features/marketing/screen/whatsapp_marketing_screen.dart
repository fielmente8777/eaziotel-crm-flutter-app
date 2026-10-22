// ============================================================
// WHATSAPP MARKETING SCREEN  (Drawer > Marketing > WhatsApp Marketing)
//
// "Campaign Management": All / Sent / Scheduled / In Progress + Refresh.
//   phone          : a card for each campaign
//   tablet / window: table
// Tap a campaign -> WhatsappCampaignDetailScreen
// ============================================================

import 'package:eazotel/utils/res/t_responsive_builder.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../setting_screen/screen/widgets/setting_section_card.dart';
import '../controller/whatsapp_marketing_controller.dart';
import '../models/marketing_models.dart';
import 'whatsapp_campaign_create_screen.dart';
import 'whatsapp_campaign_detail_screen.dart';
import 'widgets/marketing_common.dart';

class WhatsappMarketingScreen extends StatelessWidget {
  const WhatsappMarketingScreen({super.key});

  void _open(WhatsappMarketingController controller, WhatsappCampaign c) {
    controller.openCampaign(c);
    Get.to(() => const WhatsappCampaignDetailScreen());
  }

  /// New campaign screen; if created, reload the list
  Future<void> _create(WhatsappMarketingController controller) async {
    final created = await Get.to<bool>(
      () => const WhatsappCampaignCreateScreen(),
    );
    if (created == true) controller.load();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WhatsappMarketingController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign Management'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: controller.load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(controller),
        icon: const Icon(Icons.add),
        label: const Text('New Campaign'),
      ),
      body: SafeArea(
        child: TResponsiveBuilder(
          builder: (context, r) => Obx(() {
            final list = controller.visibleCampaigns;

            Widget content;
            if (controller.isLoading.value) {
              content = const MarketingState(
                icon: Icons.campaign_outlined,
                message: 'Loading campaigns...',
                loading: true,
              );
            } else if (controller.errorMessage.value != null) {
              content = MarketingState(
                icon: Icons.error_outline,
                message: controller.errorMessage.value!,
                onRetry: controller.load,
              );
            } else if (list.isEmpty) {
              content = const MarketingState(
                icon: Icons.campaign_outlined,
                message: 'No campaigns found',
              );
            } else if (r.isPhone) {
              content = Column(
                children: [
                  for (final c in list)
                    _CampaignCard(
                      campaign: c,
                      onTap: () => _open(controller, c),
                    ),
                ],
              );
            } else {
              content = _CampaignTable(
                campaigns: list,
                onTap: (c) => _open(controller, c),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.load,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  r.pagePadding,
                  r.pagePadding,
                  r.pagePadding,
                  90,
                ),
                children: [
                  if (controller.campaigns.isNotEmpty) ...[
                    _Summary(controller: controller),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    onChanged: (v) => controller.search.value = v,
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Search campaign or template',
                      prefixIcon: Icon(Icons.search, size: 18),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FilterChips(controller: controller),
                  const SizedBox(height: 12),
                  content,
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.controller});

  final WhatsappMarketingController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final f in CampaignFilter.values)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f.label),
                  selected: controller.filter.value == f,
                  onSelected: (_) => controller.filter.value = f,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One campaign on phones
class _CampaignCard extends StatelessWidget {
  const _CampaignCard({required this.campaign, required this.onTap});

  final WhatsappCampaign campaign;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final c = campaign;

    Widget count(String label, int value, Color color) => Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(label, style: TextStyle(color: p.subText, fontSize: 10.5)),
        ],
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: p.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: p.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: p.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  StatusPill(status: c.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${c.templateName}  •  ${formatDateTime(c.createdAt)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: p.subText, fontSize: 11.5),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  count('Audience', c.total, p.text),
                  count('Sent', c.sent, p.text),
                  count('Delivered', c.delivered, TAppColors.success),
                  count('Read', c.read, TAppColors.info),
                  count('Failed', c.failed, TAppColors.error),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Table on tablet / window
class _CampaignTable extends StatelessWidget {
  const _CampaignTable({required this.campaigns, required this.onTap});

  final List<WhatsappCampaign> campaigns;
  final ValueChanged<WhatsappCampaign> onTap;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    TextStyle head = TextStyle(
      color: p.primary,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );

    Widget cell(String text, {int flex = 2, Color? color}) => Expanded(
      flex: flex,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: color ?? p.text, fontSize: 12.5),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                SizedBox(width: 32, child: Text('#', style: head)),
                Expanded(flex: 3, child: Text('Campaign', style: head)),
                Expanded(flex: 4, child: Text('Template', style: head)),
                Expanded(flex: 2, child: Text('Audience', style: head)),
                Expanded(flex: 2, child: Text('Sent', style: head)),
                Expanded(flex: 2, child: Text('Failed', style: head)),
                Expanded(flex: 2, child: Text('Delivered', style: head)),
                Expanded(flex: 2, child: Text('Read', style: head)),
                Expanded(flex: 4, child: Text('Date', style: head)),
                Expanded(flex: 3, child: Text('Status', style: head)),
              ],
            ),
          ),
          for (var i = 0; i < campaigns.length; i++)
            InkWell(
              onTap: () => onTap(campaigns[i]),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: p.border)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${i + 1}'.padLeft(2, '0'),
                        style: TextStyle(color: p.subText, fontSize: 12.5),
                      ),
                    ),
                    cell(campaigns[i].name, flex: 3, color: p.primary),
                    cell(campaigns[i].templateName, flex: 4),
                    cell('${campaigns[i].total}'),
                    cell(campaigns[i].sentLabel),
                    cell('${campaigns[i].failed}', color: TAppColors.error),
                    cell(
                      '${campaigns[i].delivered}',
                      color: TAppColors.success,
                    ),
                    cell('${campaigns[i].read}', color: TAppColors.success),
                    cell(formatDateTime(campaigns[i].createdAt), flex: 4),
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: StatusPill(status: campaigns[i].status),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// SUMMARY (total of all campaigns)
//   Campaigns | Messages sent | Delivery rate | Read rate
// ============================================================

class _Summary extends StatelessWidget {
  const _Summary({required this.controller});

  final WhatsappMarketingController controller;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final c = controller;

    final tiles = [
      (Icons.campaign_rounded, 'Campaigns', '${c.campaigns.length}', p.primary),
      (Icons.send_rounded, 'Messages sent', '${c.totalSent}', TAppColors.info),
      (
        Icons.done_all_rounded,
        'Delivery rate',
        '${c.deliveryRate}%',
        TAppColors.success,
      ),
      (
        Icons.visibility_rounded,
        'Read rate',
        '${c.readRate}%',
        const Color(0xFF8B5CF6),
      ),
    ];

    return LayoutBuilder(
      builder: (_, box) {
        final columns = box.maxWidth >= 640 ? 4 : 2;
        final width = (box.maxWidth - 10 * (columns - 1)) / columns;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final (icon, label, value, color) in tiles)
              Container(
                width: width,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: p.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: p.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, size: 19, color: color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            value,
                            maxLines: 1,
                            style: TextStyle(
                              color: p.text,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: p.subText, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
