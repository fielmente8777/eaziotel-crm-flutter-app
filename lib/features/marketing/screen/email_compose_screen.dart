// ============================================================
// EMAIL COMPOSE SCREEN  (EazoMail > Compose / Send to selected)
//
//   From        : sender's email (+ name)
//   To          : type  -> or "Sending to 120 recipients" on top (batch)
//   Subject
//   Message     : your own text  or  a template (Saved / AI) + preview
//   Attachments : kai files
//   [Send]      : batch -> campaign -> send (same as web)
//
// Bhej diya -> Get.back(result: true)
// ============================================================

import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../setting_screen/screen/widgets/setting_section_card.dart';
import '../controller/email_compose_controller.dart';
import '../controller/email_marketing_controller.dart';
import '../models/marketing_models.dart';
import 'email_ai_template_screen.dart';
import 'widgets/email_html_preview.dart';
import 'widgets/marketing_common.dart';

class EmailComposeScreen extends StatefulWidget {
  const EmailComposeScreen({
    super.key,
    this.batchId,
    this.recipientCount = 0,
    this.template,
  });

  /// People already chosen (null = type them in "To")
  final String? batchId;
  final int recipientCount;

  /// Open with a template (Templates > Use)
  final EmailTemplate? template;

  @override
  State<EmailComposeScreen> createState() => _EmailComposeScreenState();
}

class _EmailComposeScreenState extends State<EmailComposeScreen> {
  static const _tag = 'email_compose';

  late final EmailComposeController c = Get.put(
    EmailComposeController(
      batchId: widget.batchId,
      recipientCount: widget.recipientCount,
      template: widget.template,
    ),
    tag: _tag,
  );

  late final _from = TextEditingController(text: c.from.value);
  late final _subject = TextEditingController(text: c.subject.value);

  @override
  void dispose() {
    _from.dispose();
    _subject.dispose();
    Get.delete<EmailComposeController>(tag: _tag);
    super.dispose();
  }

  void _toast(String title, String message, {bool error = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: error ? TAppColors.error : TAppColors.success,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
    );
  }

  Future<void> _send() async {
    final ok = await c.send(
      onError: (m) => _toast('Could not send', m, error: true),
    );
    if (!ok) return;

    Get.back(result: true);
    _toast('Email queued', 'Your email is on its way.');
  }

  /// Apply the template; if the subject is empty, use the template's subject too
  void _apply(EmailTemplate t) {
    c.useTemplate(t);
    if (_subject.text.trim().isEmpty) _subject.text = c.subject.value;
  }

  Future<void> _openAi() async {
    final t = await Get.to<EmailTemplate>(
      () => EmailAiTemplateScreen(initial: c.template.value, forCompose: true),
    );
    if (t != null) _apply(t);
  }

  Future<void> _pickSaved() async {
    if (!Get.isRegistered<EmailMarketingController>()) return;

    final t = await showModalBottomSheet<EmailTemplate>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _SavedTemplatesSheet(
        controller: Get.find<EmailMarketingController>(),
      ),
    );
    if (t != null) _apply(t);
  }

  Future<void> _attach() async {
    final files = await FilePicker.pickFiles();
    for (final f in files) {
      final path = f.path;
      if (path != null && !c.attachments.contains(path)) {
        c.attachments.add(path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(c.hasBatch ? 'New broadcast' : 'New email'),
        actions: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.icon(
                onPressed: c.isSending.value ? null : _send,
                icon: Icon(
                  c.isSending.value
                      ? Icons.hourglass_top_rounded
                      : Icons.send_rounded,
                  size: 18,
                ),
                label: Text(c.isSending.value ? 'Sending…' : 'Send'),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                // ---------- Kisko ----------
                if (c.hasBatch)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: p.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.groups_rounded, color: p.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Sending to ${c.recipientCount} '
                            'recipient${c.recipientCount == 1 ? '' : 's'}',
                            style: TextStyle(
                              color: p.text,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),

                TextField(
                  controller: _from,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (v) => c.from.value = v,
                  decoration: const InputDecoration(
                    labelText: 'From email',
                    prefixIcon: Icon(Icons.alternate_email, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) => c.fromName.value = v,
                  decoration: const InputDecoration(
                    labelText: 'From name (optional)',
                    hintText: 'e.g. Eazotel Resort',
                    prefixIcon: Icon(Icons.badge_outlined, size: 20),
                  ),
                ),
                if (!c.hasBatch) ...[
                  const SizedBox(height: 12),
                  TextField(
                    minLines: 1,
                    maxLines: 3,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (v) => c.to.value = v,
                    decoration: const InputDecoration(
                      labelText: 'To',
                      hintText: 'a@example.com, b@example.com',
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: _subject,
                  onChanged: (v) => c.subject.value = v,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    prefixIcon: Icon(Icons.subject, size: 20),
                  ),
                ),
                const SizedBox(height: 16),

                // ---------- Message / template ----------
                Obx(() {
                  final t = c.template.value;

                  if (t == null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          minLines: 8,
                          maxLines: 20,
                          onChanged: (v) => c.message.value = v,
                          decoration: const InputDecoration(
                            labelText: 'Message',
                            alignLabelWithHint: true,
                            hintText: 'Write your email…',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _openAi,
                              icon: const Icon(Icons.auto_awesome, size: 18),
                              label: const Text('AI template'),
                            ),
                            OutlinedButton.icon(
                              onPressed: _pickSaved,
                              icon: const Icon(
                                Icons.dashboard_customize_outlined,
                                size: 18,
                              ),
                              label: const Text('Saved template'),
                            ),
                          ],
                        ),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 18, color: p.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              t.name.isEmpty ? 'Email template' : t.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: p.text,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Edit with AI',
                            onPressed: _openAi,
                            icon: const Icon(Icons.edit_outlined, size: 20),
                          ),
                          IconButton(
                            tooltip: 'Remove template',
                            onPressed: c.removeTemplate,
                            icon: const Icon(Icons.close, size: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      EmailHtmlPreview(html: t.html),
                    ],
                  );
                }),
                const SizedBox(height: 16),

                // ---------- Attachments ----------
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final path in c.attachments)
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.only(left: 12),
                          decoration: BoxDecoration(
                            color: p.inner,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.attach_file,
                                size: 18,
                                color: p.subText,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  path.split(RegExp(r'[\\/]')).last,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: p.text, fontSize: 13),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Remove',
                                onPressed: () => c.attachments.remove(path),
                                icon: const Icon(Icons.close, size: 18),
                              ),
                            ],
                          ),
                        ),
                      TextButton.icon(
                        onPressed: _attach,
                        icon: const Icon(Icons.attach_file, size: 18),
                        label: Text(
                          c.attachments.isEmpty
                              ? 'Attach files'
                              : 'Attach more (${c.attachments.length})',
                        ),
                      ),
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

// ============================================================
// SAVED TEMPLATES (bottom sheet)
// ============================================================

class _SavedTemplatesSheet extends StatelessWidget {
  const _SavedTemplatesSheet({required this.controller});

  final EmailMarketingController controller;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .75,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              onChanged: controller.searchTemplates,
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Search templates',
                prefixIcon: Icon(Icons.search, size: 18),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isTemplatesLoading.value) {
                return const MarketingState(
                  icon: Icons.dashboard_customize_outlined,
                  message: 'Loading templates...',
                  loading: true,
                );
              }
              if (controller.templates.isEmpty) {
                return const MarketingState(
                  icon: Icons.dashboard_customize_outlined,
                  message: 'No saved templates yet.\nCreate one with AI.',
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                children: [
                  for (final t in controller.templates)
                    Card(
                      color: p.card,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: p.border),
                      ),
                      child: ListTile(
                        onTap: () => Navigator.pop(context, t),
                        leading: Icon(Icons.mail_outline, color: p.primary),
                        title: Text(
                          t.name.isEmpty ? 'Untitled template' : t.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          t.subject,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
