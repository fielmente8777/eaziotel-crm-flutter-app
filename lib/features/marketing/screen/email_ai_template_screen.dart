// ============================================================
// AI EMAIL TEMPLATE SCREEN  (web ke "AI template" jaisa)
//
//   BRIEF                         PREVIEW
//   [suggestion chips]            < 2 / 3 >   Name / Subject
//   Describe the email...         ┌──────────────┐
//   Tone: Friendly Warm ...       │   email      │
//   ▸ Brand & button              └──────────────┘
//   [✨ Generate]                 "Change something..." [Refine]
//                                 [Save]  [Save & use]
//
// Phone: Brief | Preview tab.  Tablet / window: dono saath.
// forCompose = true  -> "Save & use" template wapas compose ko deta hai
// forCompose = false -> Save ke baad wapas (Templates list taaza)
// ============================================================

import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../setting_screen/screen/widgets/setting_section_card.dart';
import '../controller/email_ai_template_controller.dart';
import '../models/marketing_models.dart';
import 'widgets/email_html_preview.dart';

class EmailAiTemplateScreen extends StatefulWidget {
  const EmailAiTemplateScreen({
    super.key,
    this.initial,
    this.forCompose = false,
  });

  /// Pehle se bana template (edit / refine ke liye)
  final EmailTemplate? initial;
  final bool forCompose;

  @override
  State<EmailAiTemplateScreen> createState() => _EmailAiTemplateScreenState();
}

class _EmailAiTemplateScreenState extends State<EmailAiTemplateScreen>
    with SingleTickerProviderStateMixin {
  static const _tag = 'email_ai_template';

  late final EmailAiTemplateController c = Get.put(
    EmailAiTemplateController(initial: widget.initial),
    tag: _tag,
  );

  // initState me banta hai (badi screen par tab nahi dikhte, phir bhi
  // dispose me pehli baar banana crash karta hai)
  late final TabController _tabs;

  late final _prompt = TextEditingController(text: c.prompt.value);
  late final _refine = TextEditingController();
  late final _name = TextEditingController(text: c.name.value);
  late final _subject = TextEditingController(text: c.subject.value);

  final List<Worker> _workers = [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initial == null ? 0 : 1,
    );
    _workers.addAll([
      // AI ne naam / subject diya to box me bhi dikhe
      ever<String>(c.name, (v) {
        if (_name.text != v) _name.text = v;
      }),
      ever<String>(c.subject, (v) {
        if (_subject.text != v) _subject.text = v;
      }),
      ever<String>(c.refineText, (v) {
        if (v.isEmpty) _refine.clear();
      }),
    ]);
  }

  @override
  void dispose() {
    for (final w in _workers) {
      w.dispose();
    }
    _tabs.dispose();
    _prompt.dispose();
    _refine.dispose();
    _name.dispose();
    _subject.dispose();
    Get.delete<EmailAiTemplateController>(tag: _tag);
    super.dispose();
  }

  Future<void> _generate({bool refine = false}) async {
    FocusScope.of(context).unfocus();
    if (_tabs.length == 2 && MediaQuery.sizeOf(context).width < 900) {
      _tabs.animateTo(1);
    }
    await c.generate(refine: refine);
  }

  Future<void> _save() async {
    final saved = await c.save();
    if (saved != null && !widget.forCompose) Get.back(result: true);
  }

  Future<void> _saveAndUse() async {
    final t = await c.saveAndUse();
    if (t != null) Get.back(result: t);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;

    final brief = _BriefPane(c: c, prompt: _prompt, onGenerate: _generate);
    final preview = _PreviewPane(
      c: c,
      name: _name,
      subject: _subject,
      refine: _refine,
      onRefine: () => _generate(refine: true),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI email template'),
        bottom: wide
            ? null
            : TabBar(
                controller: _tabs,
                tabs: const [
                  Tab(text: 'Brief'),
                  Tab(text: 'Preview'),
                ],
              ),
      ),
      bottomNavigationBar: _Actions(
        c: c,
        forCompose: widget.forCompose,
        onSave: _save,
        onUse: _saveAndUse,
      ),
      body: SafeArea(
        child: wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 420, child: brief),
                  const VerticalDivider(width: 1),
                  Expanded(child: preview),
                ],
              )
            : TabBarView(controller: _tabs, children: [brief, preview]),
      ),
    );
  }
}

// ============================================================
// BRIEF
// ============================================================

class _BriefPane extends StatelessWidget {
  const _BriefPane({
    required this.c,
    required this.prompt,
    required this.onGenerate,
  });

  final EmailAiTemplateController c;
  final TextEditingController prompt;
  final Future<void> Function({bool refine}) onGenerate;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text(
          'Describe the email you want',
          style: TextStyle(
            color: p.text,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Include the offer, who it is for, and any dates or details.',
          style: TextStyle(color: p.subText, fontSize: 12.5),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: prompt,
          minLines: 4,
          maxLines: 8,
          onChanged: (v) => c.prompt.value = v,
          decoration: const InputDecoration(
            hintText: 'e.g. Monsoon offer: 25% off on 3-night stays in July',
          ),
        ),
        const SizedBox(height: 10),
        Text('Ideas', style: TextStyle(color: p.subText, fontSize: 12)),
        const SizedBox(height: 6),
        for (final s in EmailAiTemplateController.suggestions)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                prompt.text = s;
                c.prompt.value = s;
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: p.inner,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 16, color: p.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s,
                        style: TextStyle(color: p.text, fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Text('Tone', style: TextStyle(color: p.subText, fontSize: 12)),
        const SizedBox(height: 6),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (value, label) in EmailAiTemplateController.tones)
                ChoiceChip(
                  label: Text(label),
                  selected: c.tone.value == value,
                  onSelected: (_) => c.tone.value = value,
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _BrandOptions(c: c),
        const SizedBox(height: 16),
        Obx(
          () => FilledButton.icon(
            onPressed: c.busy ? null : () => onGenerate(),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
            icon: Icon(
              c.isGenerating.value
                  ? Icons.hourglass_top_rounded
                  : Icons.auto_awesome,
            ),
            label: Text(
              c.isGenerating.value
                  ? 'Writing your email…'
                  : c.current == null
                  ? 'Generate email'
                  : 'Generate a new one',
            ),
          ),
        ),
      ],
    );
  }
}

/// Brand naam, rang, logo + button (andar band, tap par khule)
class _BrandOptions extends StatelessWidget {
  const _BrandOptions({required this.c});

  final EmailAiTemplateController c;

  static Color? _parse(String hex) {
    final clean = hex.replaceAll('#', '').trim();
    if (clean.length != 6) return null;
    final value = int.tryParse(clean, radix: 16);
    return value == null ? null : Color(0xFF000000 | value);
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    Widget field(
      String label,
      RxString value, {
      String? hint,
      Widget? suffix,
      TextInputType? keyboard,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        initialValue: value.value,
        keyboardType: keyboard,
        onChanged: (v) => value.value = v,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          isDense: true,
          suffixIcon: suffix,
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(Icons.palette_outlined, color: p.primary),
          title: Text(
            'Brand & button',
            style: TextStyle(color: p.text, fontSize: 14),
          ),
          subtitle: Text(
            'Optional',
            style: TextStyle(color: p.subText, fontSize: 12),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
          children: [
            field('Brand name', c.brandName, hint: 'Aroha Palms Resort'),
            field(
              'Brand colour',
              c.primaryColor,
              hint: '#2563eb',
              suffix: Obx(
                () => Padding(
                  padding: const EdgeInsets.all(10),
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor:
                        _parse(c.primaryColor.value) ?? Colors.transparent,
                  ),
                ),
              ),
            ),
            field(
              'Logo URL',
              c.logoUrl,
              hint: 'https://…/logo.png',
              keyboard: TextInputType.url,
            ),
            field('Button text', c.ctaText, hint: 'Book now'),
            field(
              'Button link',
              c.ctaUrl,
              hint: 'https://…',
              keyboard: TextInputType.url,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PREVIEW
// ============================================================

class _PreviewPane extends StatelessWidget {
  const _PreviewPane({
    required this.c,
    required this.name,
    required this.subject,
    required this.refine,
    required this.onRefine,
  });

  final EmailAiTemplateController c;
  final TextEditingController name;
  final TextEditingController subject;
  final TextEditingController refine;
  final VoidCallback onRefine;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Obx(() {
      final current = c.current;
      final generating = c.isGenerating.value;

      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (c.error.value != null)
            _Banner(
              text: c.error.value!,
              color: TAppColors.error,
              icon: Icons.error_outline,
            ),
          if (c.notice.value != null)
            _Banner(
              text: c.notice.value!,
              color: TAppColors.success,
              icon: Icons.check_circle_outline,
            ),

          if (current == null && !generating)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  Icon(Icons.auto_awesome, size: 46, color: p.primary),
                  const SizedBox(height: 12),
                  Text(
                    'Your email will appear here',
                    style: TextStyle(
                      color: p.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Describe it in the Brief and tap Generate.',
                    style: TextStyle(color: p.subText, fontSize: 13),
                  ),
                ],
              ),
            ),

          if (current != null || generating) ...[
            // ---------- Versions ----------
            if (c.versions.length > 1)
              Row(
                children: [
                  Text(
                    'Version',
                    style: TextStyle(color: p.subText, fontSize: 12.5),
                  ),
                  IconButton(
                    onPressed: c.versionIndex.value > 0 && !generating
                        ? c.previousVersion
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    '${c.versionIndex.value + 1} / ${c.versions.length}',
                    style: TextStyle(
                      color: p.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed:
                        c.versionIndex.value < c.versions.length - 1 &&
                            !generating
                        ? c.nextVersion
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            TextField(
              controller: name,
              onChanged: (v) => c.name.value = v,
              decoration: const InputDecoration(
                labelText: 'Template name',
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: subject,
              onChanged: (v) => c.subject.value = v,
              decoration: const InputDecoration(
                labelText: 'Subject line',
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            generating
                ? const _PreviewShimmer()
                : EmailHtmlPreview(html: current!.html),
            const SizedBox(height: 14),

            // ---------- Refine ----------
            Text(
              'Want changes?',
              style: TextStyle(
                color: p.text,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: refine,
                    minLines: 1,
                    maxLines: 4,
                    enabled: !generating && current != null,
                    onChanged: (v) => c.refineText.value = v,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Make the button green and shorter text',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: c.busy || current == null ? null : onRefine,
                  icon: Icon(
                    generating
                        ? Icons.hourglass_top_rounded
                        : Icons.auto_fix_high,
                    size: 18,
                  ),
                  label: const Text('Refine'),
                ),
              ],
            ),
          ],
        ],
      );
    });
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.color, required this.icon});

  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: p.text, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

/// AI likh raha hai: email jaisa shimmer (gol loader nahi)
class _PreviewShimmer extends StatelessWidget {
  const _PreviewShimmer();

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    Widget bar(double height, {double width = double.infinity}) => Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: p.border,
          highlightColor: Color.lerp(
            p.border,
            Colors.white,
            p.isDark ? .12 : .7,
          )!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bar(46, width: 140),
              bar(180),
              bar(18),
              bar(18),
              bar(18, width: 220),
              bar(44, width: 160),
            ],
          ),
        ),
        Text(
          'The AI is writing your email. This can take up to a minute.',
          style: TextStyle(color: p.subText, fontSize: 12.5),
        ),
      ],
    );
  }
}

// ============================================================
// SAVE / USE
// ============================================================

class _Actions extends StatelessWidget {
  const _Actions({
    required this.c,
    required this.forCompose,
    required this.onSave,
    required this.onUse,
  });

  final EmailAiTemplateController c;
  final bool forCompose;
  final VoidCallback onSave;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Obx(() {
      final ready = c.current != null && !c.busy;

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
                child: OutlinedButton.icon(
                  onPressed: ready ? onSave : null,
                  icon: Icon(
                    c.isSaving.value
                        ? Icons.hourglass_top_rounded
                        : Icons.save_outlined,
                    size: 18,
                  ),
                  label: Text(
                    c.savedId.value.isEmpty ? 'Save template' : 'Update',
                  ),
                ),
              ),
              if (forCompose) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: ready ? onUse : null,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Save & use'),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}
