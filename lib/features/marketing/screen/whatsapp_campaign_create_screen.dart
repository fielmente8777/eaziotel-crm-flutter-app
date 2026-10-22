// ============================================================
// NEW WHATSAPP CAMPAIGN SCREEN  (Campaign Management > + New Campaign)
//
//   (1) Name      : only you can see it
//   (2) Message   : Marketing | Utility  ->  choose an approved template
//                   -> fill the {{1}} {{2}} values (live preview on top)
//   (3) Audience  : contact source -> how many people + estimated cost
//   bottom        : "what is missing" + [Create campaign]
//
// Created -> Get.back(result: true) (the list reloads)
// ============================================================

import 'package:eazotel/features/whatsapp/models/whatsappTemaplateModle.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../setting_screen/screen/widgets/setting_section_card.dart';
import '../controller/whatsapp_campaign_create_controller.dart';
import '../models/marketing_models.dart';

class WhatsappCampaignCreateScreen extends StatefulWidget {
  const WhatsappCampaignCreateScreen({super.key});

  @override
  State<WhatsappCampaignCreateScreen> createState() =>
      _WhatsappCampaignCreateScreenState();
}

class _WhatsappCampaignCreateScreenState
    extends State<WhatsappCampaignCreateScreen> {
  // A fresh form every time (do not show the old filled one)
  final controller = Get.put(WhatsappCampaignCreateController());

  @override
  void dispose() {
    Get.delete<WhatsappCampaignCreateController>();
    super.dispose();
  }

  Future<void> _create() async {
    final ok = await controller.create(
      onError: (message) => Get.snackbar(
        'Could not create',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TAppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      ),
    );

    if (!ok) return;

    Get.back(result: true);
    Get.snackbar(
      'Campaign created',
      'Your WhatsApp campaign is on its way.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: TAppColors.success,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Scaffold(
      appBar: AppBar(title: const Text('New WhatsApp campaign')),
      bottomNavigationBar: _BottomBar(
        controller: controller,
        onCreate: _create,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Text(
                  'Send an approved template to a group of your contacts.',
                  style: TextStyle(color: p.subText, fontSize: 13),
                ),
                const SizedBox(height: 14),
                _Step(
                  number: 1,
                  title: 'Name',
                  child: TextField(
                    autofocus: true,
                    maxLength: 80,
                    onChanged: (v) => controller.name.value = v,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Diwali weekend offer',
                      helperText:
                          'Only you see this, it is not sent to contacts.',
                    ),
                  ),
                ),
                _Step(
                  number: 2,
                  title: 'Message',
                  child: _MessageStep(controller: controller),
                ),
                _Step(
                  number: 3,
                  title: 'Audience',
                  child: _AudienceStep(controller: controller),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// STEP CARD  ( (1) Name )
// ============================================================

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.title, required this.child});

  final int number;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.primary.withValues(alpha: .14),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: p.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: p.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ============================================================
// (2) MESSAGE
// ============================================================

class _MessageStep extends StatelessWidget {
  const _MessageStep({required this.controller});

  final WhatsappCampaignCreateController controller;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Obx(() {
      final c = controller;
      final chosen = c.template.value;

      Widget list;
      if (c.isTemplatesLoading.value) {
        list = const _TemplateShimmer();
      } else if (c.templatesError.value != null) {
        list = _Note(
          icon: Icons.error_outline,
          text: c.templatesError.value!,
          action: TextButton(
            onPressed: c.loadTemplates,
            child: const Text('Retry'),
          ),
        );
      } else if (c.templates.isEmpty) {
        list = _Note(
          icon: Icons.description_outlined,
          text:
              'No approved ${c.category.value.label.toLowerCase()} templates. '
              'Create one in Settings > WhatsApp > Message Templates.',
        );
      } else {
        list = Column(
          children: [
            for (final t in c.templates)
              _TemplateTile(
                template: t,
                selected: chosen?.id == t.id && chosen?.name == t.name,
                onTap: () => c.chooseTemplate(t),
              ),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Template type',
            style: TextStyle(color: p.subText, fontSize: 12.5),
          ),
          const SizedBox(height: 6),
          SegmentedButton<CampaignCategory>(
            segments: [
              for (final cat in CampaignCategory.values)
                ButtonSegment(value: cat, label: Text(cat.label)),
            ],
            selected: {c.category.value},
            onSelectionChanged: (s) => c.changeCategory(s.first),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 14),
          if (chosen == null)
            list
          else ...[
            _ChosenTemplate(controller: c, template: chosen),
          ],
        ],
      );
    });
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({
    required this.template,
    required this.selected,
    required this.onTap,
  });

  final WhatsappTemplate template;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final body =
        WhatsappCampaignCreateController.componentOf(template, 'BODY')?.text ??
        '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? p.primary.withValues(alpha: .08) : p.inner,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected ? p.primary : p.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 20,
                  color: selected ? p.primary : p.subText,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              template.name ?? '-',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: p.text,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            (template.language ?? '').toUpperCase(),
                            style: TextStyle(color: p.subText, fontSize: 11),
                          ),
                        ],
                      ),
                      if (body.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: p.subText,
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Selected template: live preview + {{n}} values
class _ChosenTemplate extends StatelessWidget {
  const _ChosenTemplate({required this.controller, required this.template});

  final WhatsappCampaignCreateController controller;
  final WhatsappTemplate template;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final c = controller;
    final header = WhatsappCampaignCreateController.componentOf(
      template,
      'HEADER',
    );
    final body = WhatsappCampaignCreateController.componentOf(template, 'BODY');
    final footer = WhatsappCampaignCreateController.componentOf(
      template,
      'FOOTER',
    );
    final headerIsText = (header?.format ?? 'TEXT').toUpperCase() == 'TEXT';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, size: 18, color: p.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                template.name ?? '-',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: p.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => c.chooseTemplate(null),
              icon: const Icon(Icons.swap_horiz, size: 18),
              label: const Text('Change'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ---------- Live preview (WhatsApp-style bubble) ----------
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.isDark ? const Color(0xFF0B141A) : const Color(0xFFEFEAE2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              decoration: BoxDecoration(
                color: p.isDark ? const Color(0xFF1F2C34) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (header != null && !headerIsText)
                    Container(
                      height: 90,
                      margin: const EdgeInsets.only(bottom: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: p.border.withValues(alpha: .5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        switch ((header.format ?? '').toUpperCase()) {
                          'VIDEO' => Icons.videocam_outlined,
                          'DOCUMENT' => Icons.description_outlined,
                          _ => Icons.image_outlined,
                        },
                        color: p.subText,
                        size: 32,
                      ),
                    ),
                  if (header != null &&
                      headerIsText &&
                      (header.text ?? '').isNotEmpty) ...[
                    Text(
                      WhatsappCampaignCreateController.fill(
                        header.text!,
                        c.headerValues,
                      ),
                      style: TextStyle(
                        color: p.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    WhatsappCampaignCreateController.fill(
                      body?.text ?? '',
                      c.bodyValues,
                    ),
                    style: TextStyle(
                      color: p.text,
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                  if ((footer?.text ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      footer!.text!,
                      style: TextStyle(color: p.subText, fontSize: 11.5),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // ---------- {{n}} values ----------
        if (c.headerValues.isNotEmpty || c.bodyValues.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            'Template values',
            style: TextStyle(color: p.subText, fontSize: 12.5),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < c.headerValues.length; i++)
            _ValueField(
              key: ValueKey('h_${template.name}_$i'),
              label: 'Header {{${i + 1}}}',
              initial: c.headerValues[i],
              onChanged: (v) => c.setHeaderValue(i, v),
            ),
          for (var i = 0; i < c.bodyValues.length; i++)
            _ValueField(
              key: ValueKey('b_${template.name}_$i'),
              label: 'Body {{${i + 1}}}',
              initial: c.bodyValues[i],
              onChanged: (v) => c.setBodyValue(i, v),
            ),
        ],
      ],
    );
  }
}

class _ValueField extends StatelessWidget {
  const _ValueField({
    super.key,
    required this.label,
    required this.initial,
    required this.onChanged,
  });

  final String label;
  final String initial;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        initialValue: initial,
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label, isDense: true),
      ),
    );
  }
}

// ============================================================
// (3) AUDIENCE
// ============================================================

class _AudienceStep extends StatelessWidget {
  const _AudienceStep({required this.controller});

  final WhatsappCampaignCreateController controller;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final numbers = NumberFormat.decimalPattern('en_IN');
    final rupees = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Obx(() {
      final c = controller;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: c.source.value,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Contacts from',
              prefixIcon: Icon(Icons.filter_alt_outlined, size: 20),
            ),
            items: [
              for (final s in LeadSource.all)
                DropdownMenuItem(value: s.value, child: Text(s.label)),
            ],
            onChanged: (v) => c.changeSource(v ?? ''),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (_, box) {
              final twoColumns = box.maxWidth >= 420;
              final tiles = [
                _SummaryItem(
                  icon: Icons.people_alt_outlined,
                  label: 'Contacts reached',
                  value: c.isAudienceLoading.value
                      ? null
                      : numbers.format(c.audience.value),
                ),
                _SummaryItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Estimated cost',
                  value: c.isAudienceLoading.value
                      ? null
                      : rupees.format(c.cost),
                ),
              ];

              return twoColumns
                  ? Row(
                      children: [
                        Expanded(child: tiles[0]),
                        const SizedBox(width: 10),
                        Expanded(child: tiles[1]),
                      ],
                    )
                  : Column(
                      children: [
                        tiles[0],
                        const SizedBox(height: 10),
                        tiles[1],
                      ],
                    );
            },
          ),
          if (c.overLimit) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TAppColors.warning.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: TAppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "This is more than WhatsApp's tier-1 limit of "
                      '${numbers.format(WhatsappCampaignCreateController.dailySendLimit)} '
                      'contacts a day. Messages past the limit may fail; '
                      'consider splitting the audience by source.',
                      style: TextStyle(color: p.text, fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.icon, required this.label, this.value});

  final IconData icon;
  final String label;

  /// null = still loading
  final String? value;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.inner,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: p.subText),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: p.subText, fontSize: 11.5)),
                const SizedBox(height: 2),
                value == null
                    ? Icon(
                        Icons.hourglass_top_rounded,
                        size: 16,
                        color: p.subText,
                      )
                    : Text(
                        value!,
                        style: TextStyle(
                          color: p.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BOTTOM BAR: what is missing + Create
// ============================================================

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.controller, required this.onCreate});

  final WhatsappCampaignCreateController controller;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Obx(() {
      final missing = controller.missing;
      final busy = controller.isCreating.value;

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: p.card,
          border: Border(top: BorderSide(color: p.border)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  missing ?? 'Ready to send',
                  maxLines: 2,
                  style: TextStyle(
                    color: missing == null ? TAppColors.success : p.subText,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: missing != null || busy ? null : onCreate,
                icon: Icon(
                  busy ? Icons.hourglass_top_rounded : Icons.send_rounded,
                  size: 18,
                ),
                label: Text(busy ? 'Creating…' : 'Create campaign'),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ============================================================
// SMALL
// ============================================================

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.inner,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: p.subText, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: p.subText, fontSize: 12.5),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

class _TemplateShimmer extends StatelessWidget {
  const _TemplateShimmer();

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Shimmer.fromColors(
      baseColor: p.border,
      highlightColor: Color.lerp(p.border, Colors.white, p.isDark ? .12 : .7)!,
      child: Column(
        children: [
          for (var i = 0; i < 3; i++)
            Container(
              height: 64,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
        ],
      ),
    );
  }
}
