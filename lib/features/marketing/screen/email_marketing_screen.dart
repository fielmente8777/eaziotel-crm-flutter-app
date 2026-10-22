// ============================================================
// EMAIL MARKETING SCREEN  (Drawer > Marketing > Email Marketing)
//
// "EazoMail": Recipients / Campaigns / Templates   (same as the web dashboard)
//   window : side menu on the left      phone : chips on top
//
// RECIPIENTS : search, select (one / page / all search results)
//              [Send to selected]  ⋮ Import from Excel / CSV
// CAMPAIGNS  : list -> tap = detail (stats + recipients + email)
// TEMPLATES  : saved / AI templates: Use, Edit with AI, Delete
// Compose    : button at the bottom (write an email to anyone)
// ============================================================

import 'package:eazotel/utils/res/t_responsive_builder.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../setting_screen/screen/widgets/setting_section_card.dart';
import '../controller/email_marketing_controller.dart';
import '../models/marketing_models.dart';
import '../services/email_import.dart';
import 'email_ai_template_screen.dart';
import 'email_campaign_detail_screen.dart';
import 'email_compose_screen.dart';
import 'email_import_screen.dart';
import 'widgets/email_html_preview.dart';
import 'widgets/marketing_common.dart';

class EmailMarketingScreen extends StatelessWidget {
  const EmailMarketingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmailMarketingController());

    return Scaffold(
      appBar: AppBar(title: const Text('EazoMail')),
      floatingActionButton: Obx(
        () => controller.section.value == EmailSection.templates
            ? FloatingActionButton.extended(
                heroTag: 'eazomail_ai',
                onPressed: () => EmailActions.newAiTemplate(controller),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('New with AI'),
              )
            : FloatingActionButton.extended(
                heroTag: 'eazomail_compose',
                onPressed: () => EmailActions.compose(controller),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Compose'),
              ),
      ),
      body: SafeArea(
        child: TResponsiveBuilder(
          builder: (context, r) => Obx(() {
            final body = switch (controller.section.value) {
              EmailSection.recipients => _RecipientsView(
                controller: controller,
              ),
              EmailSection.campaigns => _CampaignsView(controller: controller),
              EmailSection.templates => _TemplatesView(controller: controller),
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

// ============================================================
// ACTIONS (compose, Excel import, AI template ...)
// ============================================================

class EmailActions {
  EmailActions._();

  static void _toast(String title, String message, {bool error = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: error ? TAppColors.error : null,
      colorText: error ? Colors.white : null,
      margin: const EdgeInsets.all(12),
    );
  }

  /// Open Compose; if sent, clear the selection + refresh campaigns
  static Future<void> compose(
    EmailMarketingController c, {
    RecipientBatch? batch,
    EmailTemplate? template,
  }) async {
    final sent = await Get.to<bool>(
      () => EmailComposeScreen(
        batchId: batch?.batchId,
        recipientCount: batch?.count ?? 0,
        template: template,
      ),
    );
    if (sent == true) c.onSent();
  }

  /// Email the selected people
  static Future<void> sendToSelected(EmailMarketingController c) async {
    final batch = await c.prepareSelected(
      onError: (m) => _toast('Could not continue', m, error: true),
    );
    if (batch != null) await compose(c, batch: batch);
  }

  /// Excel / CSV -> check the emails -> compose
  static Future<void> importFile(EmailMarketingController c) async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['xlsx', 'csv', 'txt'],
    );
    final path = file?.path;
    if (file == null || path == null) return;

    List<String> emails;
    try {
      emails = await EmailImport.fromFile(path);
    } on FormatException catch (e) {
      _toast('Could not read file', e.message, error: true);
      return;
    } catch (_) {
      _toast(
        'Could not read file',
        'Please upload a valid .xlsx or .csv file.',
        error: true,
      );
      return;
    }

    if (emails.isEmpty) {
      _toast(
        'No emails found',
        'No valid email addresses were found in this file.',
      );
      return;
    }

    final batch = await Get.to<RecipientBatch>(
      () => EmailImportScreen(fileName: file.name, emails: emails),
    );
    if (batch != null) await compose(c, batch: batch);
  }

  static Future<void> newAiTemplate(
    EmailMarketingController c, {
    EmailTemplate? edit,
  }) async {
    final saved = await Get.to<bool>(
      () => EmailAiTemplateScreen(initial: edit),
    );
    if (saved == true) {
      c.loadTemplates(edit == null ? 1 : c.templatePage.value.page);
    }
  }
}

// ============================================================
// MENU
// ============================================================

String _countFor(EmailMarketingController c, EmailSection s) => switch (s) {
  EmailSection.recipients => '${c.recipientPage.value.total}',
  EmailSection.campaigns => '${c.campaignPage.value.total}',
  EmailSection.templates => '${c.templatePage.value.total}',
};

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
                label: Text('${s.label} ${_countFor(controller, s)}'),
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
    return Obx(() {
      final p = SettingPalette(context);
      final c = controller;
      final list = c.recipients;
      final selected = c.selectedCount;

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
        content = MarketingState(
          icon: Icons.people_outline,
          message: c.recipientSearch.value.isEmpty
              ? 'No recipients yet'
              : 'No recipients match "${c.recipientSearch.value}"',
        );
      } else {
        content = Column(
          children: [
            for (final r in list)
              Material(
                color: c.isSelected(r)
                    ? p.primary.withValues(alpha: .08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: CheckboxListTile(
                  value: c.isSelected(r),
                  onChanged: c.allMatching.value || r.id.isEmpty
                      ? null
                      : (_) => c.toggle(r),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  title: Text(
                    r.name.isEmpty ? '-' : r.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: p.text, fontSize: 13.5),
                  ),
                  subtitle: Text(
                    r.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: p.subText, fontSize: 12),
                  ),
                ),
              ),
          ],
        );
      }

      return RefreshIndicator(
        onRefresh: () => c.loadRecipients(c.recipientPage.value.page),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
          children: [
            TextField(
              onChanged: c.searchRecipients,
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Search recipients by name or email',
                prefixIcon: Icon(Icons.search, size: 18),
              ),
            ),
            const SizedBox(height: 8),

            // ---------- Select page + actions ----------
            Row(
              children: [
                Checkbox(
                  value: c.isPageSelected,
                  onChanged: list.isEmpty ? null : (_) => c.togglePage(),
                ),
                Expanded(
                  child: Text(
                    selected == 0
                        ? 'Select all on this page'
                        : '$selected selected',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected == 0 ? p.subText : p.text,
                      fontSize: 13,
                      fontWeight: selected == 0
                          ? FontWeight.w400
                          : FontWeight.w700,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: selected == 0 || c.isPreparing.value
                      ? null
                      : () => EmailActions.sendToSelected(c),
                  icon: Icon(
                    c.isPreparing.value
                        ? Icons.hourglass_top_rounded
                        : Icons.send_rounded,
                    size: 18,
                  ),
                  label: Text(selected == 0 ? 'Send' : 'Send ($selected)'),
                ),
                PopupMenuButton<String>(
                  tooltip: 'More',
                  onSelected: (v) => switch (v) {
                    'import' => EmailActions.importFile(c),
                    'clear' => c.clearSelection(),
                    _ => null,
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'import',
                      child: ListTile(
                        leading: Icon(Icons.upload_file_outlined),
                        title: Text('Import from Excel / CSV'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    if (selected > 0)
                      const PopupMenuItem(
                        value: 'clear',
                        child: ListTile(
                          leading: Icon(Icons.clear_all),
                          title: Text('Clear selection'),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // ---------- "Select all N matching" ----------
            if (c.canSelectAllMatching || c.allMatching.value)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: p.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.allMatching.value
                            ? 'All ${c.recipientPage.value.total} matching recipients selected.'
                            : 'All ${list.length} on this page are selected.',
                        style: TextStyle(color: p.text, fontSize: 12.5),
                      ),
                    ),
                    TextButton(
                      onPressed: c.allMatching.value
                          ? c.clearSelection
                          : c.selectAllMatching,
                      child: Text(
                        c.allMatching.value
                            ? 'Clear'
                            : 'Select all ${c.recipientPage.value.total}',
                      ),
                    ),
                  ],
                ),
              ),

            content,
            const Divider(),
            PagerBar(
              page: c.recipientPage.value,
              shown: list.length,
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
          message: 'No campaigns yet.\nTap Compose to send your first email.',
        );
      } else {
        content = Column(
          children: [
            for (final campaign in c.campaigns)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: p.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: p.border),
                ),
                child: ListTile(
                  onTap: () {
                    c.openCampaign(campaign);
                    Get.to(() => const EmailCampaignDetailScreen());
                  },
                  title: Text(
                    campaign.subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${campaign.recipientCount} recipients  •  '
                      'Sent ${campaign.stat('sent')}  •  '
                      'Opened ${campaign.stat('opened')}  •  '
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
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
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
}

// ============================================================
// TEMPLATES
// ============================================================

class _TemplatesView extends StatelessWidget {
  const _TemplatesView({required this.controller});

  final EmailMarketingController controller;

  Future<void> _delete(BuildContext context, EmailTemplate t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete template?'),
        content: Text(
          '"${t.name.isEmpty ? 'Untitled template' : t.name}" will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await controller.deleteTemplate(
      t,
      onError: (m) => Get.snackbar(
        'Could not delete',
        m,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TAppColors.error,
        colorText: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final c = controller;

      Widget content;
      if (c.isTemplatesLoading.value) {
        content = const MarketingState(
          icon: Icons.dashboard_customize_outlined,
          message: 'Loading templates...',
          loading: true,
        );
      } else if (c.templatesError.value != null) {
        content = MarketingState(
          icon: Icons.error_outline,
          message: c.templatesError.value!,
          onRetry: () => c.loadTemplates(c.templatePage.value.page),
        );
      } else if (c.templates.isEmpty) {
        content = MarketingState(
          icon: Icons.auto_awesome,
          message: c.templateSearch.value.isEmpty
              ? 'No templates yet.\nTap "New with AI" to create one.'
              : 'No templates match "${c.templateSearch.value}"',
        );
      } else {
        content = LayoutBuilder(
          builder: (_, box) {
            final columns = box.maxWidth >= 900
                ? 3
                : box.maxWidth >= 560
                ? 2
                : 1;
            final width = (box.maxWidth - 12 * (columns - 1)) / columns;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final t in c.templates)
                  SizedBox(
                    width: width,
                    child: _TemplateCard(
                      template: t,
                      deleting: c.deletingTemplateId.value == t.id,
                      onUse: () => EmailActions.compose(c, template: t),
                      onEdit: () => EmailActions.newAiTemplate(c, edit: t),
                      onDelete: () => _delete(context, t),
                    ),
                  ),
              ],
            );
          },
        );
      }

      return RefreshIndicator(
        onRefresh: () => c.loadTemplates(c.templatePage.value.page),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
          children: [
            TextField(
              onChanged: c.searchTemplates,
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Search templates',
                prefixIcon: Icon(Icons.search, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            content,
            if (c.templates.isNotEmpty) ...[
              const Divider(),
              PagerBar(
                page: c.templatePage.value,
                shown: c.templates.length,
                onPage: c.loadTemplates,
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.deleting,
    required this.onUse,
    required this.onEdit,
    required this.onDelete,
  });

  final EmailTemplate template;
  final bool deleting;
  final VoidCallback onUse;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final t = template;

    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Small preview (view only, tap = Use)
          InkWell(
            onTap: onUse,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: IgnorePointer(
                child: EmailHtmlPreview(html: t.html, maxHeight: 170),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 2, 4, 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.name.isEmpty ? 'Untitled template' : t.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: p.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      Text(
                        t.subject.isEmpty ? '-' : t.subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: p.subText, fontSize: 12),
                      ),
                      if (t.updatedAt != null)
                        Text(
                          'Updated ${formatDateTime(t.updatedAt)}',
                          style: TextStyle(color: p.subText, fontSize: 10.5),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  enabled: !deleting,
                  icon: Icon(
                    deleting ? Icons.hourglass_top_rounded : Icons.more_vert,
                    color: p.subText,
                  ),
                  onSelected: (v) => switch (v) {
                    'use' => onUse(),
                    'edit' => onEdit(),
                    'delete' => onDelete(),
                    _ => null,
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'use',
                      child: ListTile(
                        leading: Icon(Icons.send_outlined),
                        title: Text('Use in email'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.auto_awesome),
                        title: Text('Edit with AI'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline, color: Colors.red),
                        title: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
