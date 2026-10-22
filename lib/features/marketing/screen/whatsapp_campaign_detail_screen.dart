// ============================================================
// WHATSAPP CAMPAIGN DETAIL SCREEN
//
//   top    : Audience / Sent / Delivered / Read / Failed + Delivery Funnel
//   neeche : numbers ki list (Name, Phone, Status, Sent, Delivered, Read,
//            Failed At / Reason), filter + search + page
// Tap a number -> the in-app WhatsApp chat for that number
// ============================================================

import 'package:eazotel/features/whatsapp/services/whatsapp_chat_opener.dart';
import 'package:eazotel/utils/res/t_responsive_builder.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../setting_screen/screen/widgets/setting_section_card.dart';
import '../controller/whatsapp_marketing_controller.dart';
import '../models/marketing_models.dart';
import 'widgets/marketing_common.dart';

class WhatsappCampaignDetailScreen extends StatelessWidget {
  const WhatsappCampaignDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WhatsappMarketingController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final c = controller.detail.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c?.name ?? 'Campaign'),
              if (c != null)
                Text(
                  c.templateName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          );
        }),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () =>
                controller.loadRecipients(controller.recipientPage.value.page),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: TResponsiveBuilder(
          builder: (context, r) => Obx(() {
            final c = controller.detail.value;
            if (c == null) return const SizedBox.shrink();

            return ListView(
              padding: EdgeInsets.all(r.pagePadding),
              children: [
                _Stats(campaign: c, columns: r.isPhone ? 2 : 5),
                const SizedBox(height: 12),
                _Funnel(campaign: c),
                const SizedBox(height: 12),
                _Recipients(controller: controller, wide: !r.isPhone),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.campaign, required this.columns});

  final WhatsappCampaign campaign;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final c = campaign;

    final tiles = [
      StatTile(
        label: 'Audience',
        value: c.total,
        color: SettingPalette(context).text,
        note: 'Total recipients',
      ),
      StatTile(
        label: 'Sent',
        value: c.sent,
        color: TAppColors.primary,
        note: 'Messages dispatched',
      ),
      StatTile(
        label: 'Delivered',
        value: c.delivered,
        color: TAppColors.success,
        note: '${c.percentOf(c.delivered)}% delivery rate',
      ),
      StatTile(
        label: 'Read',
        value: c.read,
        color: TAppColors.info,
        note: '${c.percentOf(c.read)}% read rate',
      ),
      StatTile(
        label: 'Failed',
        value: c.failed,
        color: TAppColors.error,
        note: 'Could not deliver',
      ),
    ];

    return LayoutBuilder(
      builder: (context, box) {
        const gap = 10.0;
        final width = (box.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final tile in tiles) SizedBox(width: width, child: tile),
          ],
        );
      },
    );
  }
}

/// One strip for Read / Delivered / Failed / Pending
class _Funnel extends StatelessWidget {
  const _Funnel({required this.campaign});

  final WhatsappCampaign campaign;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final c = campaign;

    final read = c.read;
    final delivered = (c.delivered - c.read).clamp(0, c.total);
    final failed = c.failed;
    final pending = (c.total - read - delivered - failed).clamp(0, c.total);

    final parts = [
      ('Read', read, TAppColors.info),
      ('Delivered', delivered, TAppColors.success),
      ('Failed', failed, TAppColors.error),
      ('Pending', pending, p.border),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Delivery Funnel',
                  style: TextStyle(color: p.text, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${c.total} total',
                style: TextStyle(color: p.subText, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: c.total == 0
                  ? Container(color: p.border)
                  : Row(
                      children: [
                        for (final (_, value, color) in parts)
                          if (value > 0)
                            Expanded(
                              flex: value,
                              child: Container(color: color),
                            ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 14,
            children: [
              for (final (label, _, color) in parts)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 4, backgroundColor: color),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(color: p.subText, fontSize: 11.5),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Recipients extends StatelessWidget {
  const _Recipients({required this.controller, required this.wide});

  final WhatsappMarketingController controller;
  final bool wide;

  void _openChat(BuildContext context, CampaignRecipient r) {
    WhatsappChatOpener.open(context, phone: r.phone, hid: controller.hid);
  }

  @override
  Widget build(BuildContext context) {
    // This part rebuilds when the filter / search / page changes
    return Obx(() {
      final p = SettingPalette(context);
      final list = controller.visibleRecipients;

      Widget body;
      if (controller.isDetailLoading.value) {
        body = const MarketingState(
          icon: Icons.people_outline,
          message: 'Loading recipients...',
          loading: true,
        );
      } else if (controller.detailError.value != null) {
        body = MarketingState(
          icon: Icons.error_outline,
          message: controller.detailError.value!,
          onRetry: () =>
              controller.loadRecipients(controller.recipientPage.value.page),
        );
      } else if (list.isEmpty) {
        body = const MarketingState(
          icon: Icons.search_off,
          message: 'No recipients match your filter',
        );
      } else {
        body = Column(
          children: [
            if (wide) const _RecipientHeader(),
            for (final r in list)
              wide
                  ? _RecipientRow(
                      recipient: r,
                      onTap: () => _openChat(context, r),
                    )
                  : _RecipientTile(
                      recipient: r,
                      onTap: () => _openChat(context, r),
                    ),
          ],
        );
      }

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: p.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Filter chips (with this page's counts) ----------
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final (key, label) in const [
                    ('', 'All'),
                    ('sent', 'Sent'),
                    ('delivered', 'Delivered'),
                    ('read', 'Read'),
                    ('failed', 'Failed'),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(
                          key.isEmpty
                              ? label
                              : '$label (${controller.countOf(key)})',
                        ),
                        selected: controller.recipientFilter.value == key,
                        onSelected: (_) =>
                            controller.recipientFilter.value = key,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              onChanged: (v) => controller.recipientSearch.value = v,
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Search name or phone',
                prefixIcon: Icon(Icons.search, size: 18),
              ),
            ),
            const SizedBox(height: 10),
            body,
            const Divider(),
            PagerBar(
              page: controller.recipientPage.value,
              shown: controller.recipients.length,
              onPage: controller.loadRecipients,
            ),
          ],
        ),
      );
    });
  }
}

String _timeAgo(DateTime? date) {
  if (date == null) return '-';
  final diff = DateTime.now().difference(date);
  if (diff.inDays >= 30) return '${diff.inDays ~/ 30} months ago';
  if (diff.inDays >= 1) return '${diff.inDays} days ago';
  if (diff.inHours >= 1) return '${diff.inHours} hours ago';
  return '${diff.inMinutes} min ago';
}

String _failedText(CampaignRecipient r) {
  if (r.status != 'failed') return '-';
  final when = r.failedAt == null ? '' : formatDateTime(r.failedAt);
  return [when, r.error].where((s) => s.isNotEmpty).join(' • ');
}

class _RecipientHeader extends StatelessWidget {
  const _RecipientHeader();

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final style = TextStyle(
      color: p.primary,
      fontSize: 11.5,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text('NAME', style: style)),
          Expanded(flex: 3, child: Text('PHONE', style: style)),
          Expanded(flex: 2, child: Text('STATUS', style: style)),
          Expanded(flex: 2, child: Text('SENT', style: style)),
          Expanded(flex: 2, child: Text('DELIVERED', style: style)),
          Expanded(flex: 2, child: Text('READ', style: style)),
          Expanded(flex: 4, child: Text('FAILED AT / REASON', style: style)),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 15,
      backgroundColor: const Color(0xFF8B5CF6),
      child: Text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

class _RecipientRow extends StatelessWidget {
  const _RecipientRow({required this.recipient, required this.onTap});

  final CampaignRecipient recipient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final r = recipient;

    Widget cell(String text, int flex) => Expanded(
      flex: flex,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: p.subText, fontSize: 12),
      ),
    );

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: p.border)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  _Avatar(name: r.name),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      r.name.isEmpty ? 'Unknown' : r.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: r.name.isEmpty ? p.subText : p.text,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            cell(r.phone, 3),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: StatusPill(status: r.status),
              ),
            ),
            cell(_timeAgo(r.sentAt), 2),
            cell(_timeAgo(r.deliveredAt), 2),
            cell(_timeAgo(r.readAt), 2),
            cell(_failedText(r), 4),
          ],
        ),
      ),
    );
  }
}

/// One number on phones
class _RecipientTile extends StatelessWidget {
  const _RecipientTile({required this.recipient, required this.onTap});

  final CampaignRecipient recipient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final r = recipient;

    final lines = [
      'Sent ${_timeAgo(r.sentAt)}',
      if (r.deliveredAt != null) 'Delivered ${_timeAgo(r.deliveredAt)}',
      if (r.readAt != null) 'Read ${_timeAgo(r.readAt)}',
      if (r.status == 'failed') 'Failed: ${_failedText(r)}',
    ];

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: _Avatar(name: r.name),
      title: Text(
        r.name.isEmpty ? 'Unknown' : r.name,
        style: TextStyle(color: r.name.isEmpty ? p.subText : p.text),
      ),
      subtitle: Text(
        '${r.phone}\n${lines.join(' • ')}',
        style: TextStyle(color: p.subText, fontSize: 11.5),
      ),
      isThreeLine: true,
      trailing: StatusPill(status: r.status),
    );
  }
}
