// ============================================================
// MESSAGE TEMPLATES PAGE  (Settings > WhatsApp > Message Templates)
//
//   [Create Template] [Template Library]
//
//   Create : form (name, content, variable samples, buttons) + preview
//            on a window / big tablet, the preview on the right,
//            on phones, below the form
//   Library: search + category, tap a card -> the form gets filled
// ============================================================

import 'package:eazotel/utils/res/t_responsive.dart';
import 'package:eazotel/utils/res/t_responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../screen/widgets/wa_form_widgets.dart';
import '../controller/message_template_controller.dart';
import '../models/template_library.dart';
import 'widgets/template_preview.dart';

class MessageTemplatesPage extends StatelessWidget {
  const MessageTemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MessageTemplateController());

    return TResponsiveBuilder(
      builder: (context, r) => Column(
        children: [
          Obx(
            () => WaSubTabs(
              labels: [for (final t in TemplateSubTab.values) t.label],
              selected: c.subTab.value.index,
              onSelect: (i) => c.subTab.value = TemplateSubTab.values[i],
            ),
          ),
          Expanded(
            child: Obx(
              () => c.subTab.value == TemplateSubTab.create
                  ? _CreateView(c: c, r: r)
                  : _LibraryView(c: c, r: r),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CREATE / EDIT
// ============================================================

class _CreateView extends StatelessWidget {
  const _CreateView({required this.c, required this.r});

  final MessageTemplateController c;
  final TResponsive r;

  @override
  Widget build(BuildContext context) {
    // Preview on the right only when there is space
    final sideBySide = r.width >= 900;
    const gap = SizedBox(height: 14);

    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EditBanner(c: c),
        _NameSection(c: c, r: r),
        gap,
        _ContentSection(c: c),
        gap,
        _SamplesSection(c: c),
        _ButtonsSection(c: c, r: r),
        gap,
        if (!sideBySide) ...[_PreviewSection(c: c), gap],
        _SubmitRow(c: c),
      ],
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(r.pagePadding),
      child: sideBySide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: form),
                const SizedBox(width: 18),
                SizedBox(width: 340, child: _PreviewSection(c: c)),
              ],
            )
          : form,
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              color: p.text,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: TextStyle(color: p.subText, fontSize: 12)),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _EditBanner extends StatelessWidget {
  const _EditBanner({required this.c});

  final MessageTemplateController c;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Obx(() {
      if (!c.isEditing) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.withValues(alpha: .4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.edit_note, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Editing "${c.name.text}". Name, category and language '
                'cannot be changed.',
                style: TextStyle(color: p.text, fontSize: 12.5),
              ),
            ),
            TextButton(onPressed: c.startCreate, child: const Text('Cancel')),
          ],
        ),
      );
    });
  }
}

class _NameSection extends StatelessWidget {
  const _NameSection({required this.c, required this.r});

  final MessageTemplateController c;
  final TResponsive r;

  @override
  Widget build(BuildContext context) {
    return _Box(
      title: 'Template name and language',
      child: Obx(() {
        final locked = c.isEditing;

        final category = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const WaLabel('Category'),
            WaDropdown<String>(
              key: ValueKey('cat-${c.category.value}-$locked'),
              value: c.category.value,
              items: {
                for (final x in MessageTemplateController.categories) x: x,
              },
              onChanged: locked ? null : (v) => c.category.value = v,
            ),
          ],
        );

        final language = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const WaLabel('Language'),
            WaDropdown<String>(
              key: ValueKey('lang-${c.language.value}-$locked'),
              value: c.language.value,
              items: MessageTemplateController.languages,
              onChanged: locked ? null : (v) => c.language.value = v,
            ),
          ],
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const WaLabel('Template Name'),
            TextField(
              controller: c.name,
              enabled: !locked,
              decoration: waInput(
                context,
                hint: 'e.g. booking_confirmation',
                error: c.showErrors.value ? c.nameError : null,
              ),
            ),
            const SizedBox(height: 12),
            if (r.isPhone) ...[
              category,
              const SizedBox(height: 12),
              language,
            ] else
              Row(
                children: [
                  Expanded(child: category),
                  const SizedBox(width: 12),
                  Expanded(child: language),
                ],
              ),
          ],
        );
      }),
    );
  }
}

class _ContentSection extends StatelessWidget {
  const _ContentSection({required this.c});

  final MessageTemplateController c;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    Widget addVariable(VoidCallback onTap) => TextButton.icon(
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 6),
      ),
      onPressed: onTap,
      icon: const Icon(Icons.add, size: 16),
      label: const Text('Add Variable', style: TextStyle(fontSize: 12.5)),
    );

    return _Box(
      title: 'Template Content',
      child: Obx(() {
        final type = c.headerType.value;
        final showErrors = c.showErrors.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const WaLabel('Header Type'),
            SegmentedButton<TemplateHeaderType>(
              showSelectedIcon: false,
              segments: [
                for (final t in TemplateHeaderType.values)
                  ButtonSegment(value: t, label: Text(t.label)),
              ],
              selected: {type},
              onSelectionChanged: (s) => c.setHeaderType(s.first),
            ),
            const SizedBox(height: 14),

            // ---------- Header text ----------
            if (type == TemplateHeaderType.text) ...[
              WaLabel('Header', trailing: addVariable(c.addHeaderVariable)),
              TextField(
                controller: c.header,
                maxLength: 60,
                decoration: waInput(
                  context,
                  hint: 'Header text',
                  error: showErrors ? c.headerError : null,
                ).copyWith(counterText: ''),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Only one variable allowed.',
                      style: TextStyle(color: Colors.amber, fontSize: 11.5),
                    ),
                  ),
                  WaCounter(length: c.previewHeader.length, max: 60),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // ---------- Header photo ----------
            if (type == TemplateHeaderType.image) ...[
              const WaLabel('Upload Header Media'),
              _ImagePicker(c: c),
              if (showErrors && c.headerError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    c.headerError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 12),
            ],

            // ---------- Body ----------
            WaLabel('Body', trailing: addVariable(c.addBodyVariable)),
            TextField(
              controller: c.body,
              minLines: 5,
              maxLines: 10,
              maxLength: 1024,
              keyboardType: TextInputType.multiline,
              decoration: waInput(
                context,
                hint: 'Hi {{1}}, your booking at {{2}} is confirmed.',
                error: showErrors ? c.bodyError : null,
              ).copyWith(counterText: ''),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: WaCounter(length: c.body.text.length, max: 1024),
            ),
            const SizedBox(height: 8),

            // ---------- Footer ----------
            const WaLabel('Footer (optional)'),
            TextField(
              controller: c.footer,
              maxLength: 60,
              decoration: waInput(
                context,
                hint: 'e.g. Thank you for choosing us',
              ).copyWith(counterText: ''),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: WaCounter(length: c.previewFooter.length, max: 60),
            ),
            Text(
              'Tip: use {{1}}, {{2}} for values like guest name or date.',
              style: TextStyle(color: p.subText, fontSize: 11.5),
            ),
          ],
        );
      }),
    );
  }
}

class _ImagePicker extends StatelessWidget {
  const _ImagePicker({required this.c});

  final MessageTemplateController c;

  @override
  Widget build(BuildContext context) => Obx(() => _content(context));

  Widget _content(BuildContext context) {
    final p = SettingPalette(context);
    final hasImage =
        c.headerImagePath.value != null || c.headerImageUrl.value != null;

    if (!hasImage) {
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: c.pickHeaderImage,
        child: Container(
          height: 130,
          decoration: BoxDecoration(
            color: p.inner,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.border, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload_outlined, size: 34, color: p.primary),
              const SizedBox(height: 6),
              Text('Tap to upload image', style: TextStyle(color: p.text)),
              Text(
                'JPG or PNG, up to 5MB',
                style: TextStyle(color: p.subText, fontSize: 11.5),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        SizedBox(
          width: 140,
          child: TemplatePreview(
            body: '',
            showImageHeader: true,
            headerImagePath: c.headerImagePath.value,
            headerImageUrl: c.headerImageUrl.value,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                style: waOutlineButton(context),
                onPressed: c.pickHeaderImage,
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: const Text('Change'),
              ),
              TextButton.icon(
                onPressed: () {
                  c.headerImagePath.value = null;
                  c.headerImageUrl.value = null;
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Remove'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SamplesSection extends StatelessWidget {
  const _SamplesSection({required this.c});

  final MessageTemplateController c;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    Widget rows(
      String title,
      List<String> vars,
      List<TextEditingController> samples,
    ) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              color: p.text,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < vars.length && i < samples.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: p.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      vars[i],
                      style: TextStyle(
                        color: p.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: samples[i],
                      decoration: waInput(
                        context,
                        hint: 'Sample for ${vars[i]} e.g. Rahul',
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    return Obx(() {
      final headerVars = c.headerVariables;
      final bodyVars = c.bodyVariables;
      if (headerVars.isEmpty && bodyVars.isEmpty) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _Box(
          title: 'Variable Samples',
          subtitle:
              'Include samples of all variables to help Meta review your template.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (headerVars.isNotEmpty) ...[
                rows('Header', headerVars, c.headerSamples),
                const SizedBox(height: 6),
              ],
              if (bodyVars.isNotEmpty) rows('Body', bodyVars, c.bodySamples),
            ],
          ),
        ),
      );
    });
  }
}

class _ButtonsSection extends StatelessWidget {
  const _ButtonsSection({required this.c, required this.r});

  final MessageTemplateController c;
  final TResponsive r;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return _Box(
      title: 'Buttons',
      subtitle: 'Optional. Add a link guests can tap.',
      child: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final b in c.buttons)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.fromLTRB(12, 8, 4, 12),
                decoration: BoxDecoration(
                  color: p.inner,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: p.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          b.isLink
                              ? Icons.open_in_new
                              : b.isCall
                              ? Icons.call
                              : Icons.reply,
                          size: 16,
                          color: p.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            b.typeLabel,
                            style: TextStyle(
                              color: p.text,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remove button',
                          visualDensity: VisualDensity.compact,
                          onPressed: () => c.removeButton(b),
                          icon: const Icon(Icons.close, size: 18),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _ButtonFields(c: c, b: b, r: r),
                    ),
                  ],
                ),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                style: waOutlineButton(context),
                onPressed:
                    c.buttons.length >= MessageTemplateController.maxButtons
                    ? null
                    : c.addButton,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add button'),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _ButtonFields extends StatelessWidget {
  const _ButtonFields({required this.c, required this.b, required this.r});

  final MessageTemplateController c;
  final TemplateButtonForm b;
  final TResponsive r;

  @override
  Widget build(BuildContext context) => Obx(() => _content(context));

  Widget _content(BuildContext context) {
    // Both are read here, so the error goes away while typing
    final problem = c.buttonError(b);
    final error = c.showErrors.value ? problem : null;

    final text = TextField(
      controller: b.text,
      maxLength: 25,
      decoration: waInput(context, hint: 'Button text'),
    );

    if (!b.needsValue) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [text, if (error != null) _error(error)],
      );
    }

    final value = TextField(
      controller: b.url,
      maxLength: b.isCall ? 20 : 2000,
      keyboardType: b.isCall ? TextInputType.phone : TextInputType.url,
      decoration: waInput(
        context,
        hint: b.isCall ? '+91 98765 43210' : 'https://example.com',
      ),
    );

    final urlType = Obx(
      () => WaDropdown<String>(
        key: ValueKey('urltype-${b.urlType.value}'),
        value: b.urlType.value,
        items: const {'static': 'Static', 'dynamic': 'Dynamic'},
        onChanged: (v) => b.urlType.value = v,
      ),
    );

    final children = r.isPhone
        ? [
            text,
            if (b.isLink) ...[urlType, const SizedBox(height: 10)],
            value,
          ]
        : [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: text),
                if (b.isLink) ...[
                  const SizedBox(width: 10),
                  SizedBox(width: 130, child: urlType),
                ],
              ],
            ),
            value,
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [...children, if (error != null) _error(error)],
    );
  }

  Widget _error(String text) =>
      Text(text, style: const TextStyle(color: Colors.red, fontSize: 12));
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({required this.c});

  final MessageTemplateController c;

  @override
  Widget build(BuildContext context) {
    return _Box(
      title: 'Template Preview',
      child: Obx(
        () => TemplatePreview(
          headerText: c.headerType.value == TemplateHeaderType.text
              ? c.previewHeader
              : null,
          showImageHeader: c.headerType.value == TemplateHeaderType.image,
          headerImagePath: c.headerImagePath.value,
          headerImageUrl: c.headerImageUrl.value,
          body: c.previewBody,
          footer: c.previewFooter,
          buttons: [
            for (final b in c.buttons)
              TemplatePreviewButton(
                b.text.text,
                b.isLink
                    ? Icons.open_in_new
                    : b.isCall
                    ? Icons.call
                    : Icons.reply,
              ),
          ],
        ),
      ),
    );
  }
}

class _SubmitRow extends StatelessWidget {
  const _SubmitRow({required this.c});

  final MessageTemplateController c;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Obx(() {
      final saving = c.isSaving.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (c.hasEmptySample)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Tip: fill every variable sample, Meta may reject it otherwise.',
                style: TextStyle(color: p.subText, fontSize: 11.5),
              ),
            ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.end,
            children: [
              if (c.isEditing)
                OutlinedButton(
                  style: waOutlineButton(context),
                  onPressed: saving ? null : c.startCreate,
                  child: const Text('Cancel'),
                ),
              ElevatedButton.icon(
                style: waPrimaryButton(context),
                onPressed: saving ? null : c.submit,
                icon: saving
                    ? const Icon(Icons.hourglass_top, size: 18)
                    : Icon(c.isEditing ? Icons.publish : Icons.add, size: 18),
                label: Text(
                  saving
                      ? 'Saving…'
                      : c.isEditing
                      ? 'Publish Changes'
                      : 'Create Template',
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

// ============================================================
// TEMPLATE LIBRARY
// ============================================================

class _LibraryView extends StatelessWidget {
  const _LibraryView({required this.c, required this.r});

  final MessageTemplateController c;
  final TResponsive r;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final columns = r.value(phone: 1, tablet: 2, desktop: 3);

    const filters = {
      '': 'All',
      'UTILITY': 'Utility',
      'MARKETING': 'Marketing',
      'AUTHENTICATION': 'Authentication',
    };

    return ListView(
      padding: EdgeInsets.all(r.pagePadding),
      children: [
        TextField(
          onChanged: (v) => c.librarySearch.value = v,
          decoration: waInput(
            context,
            hint: 'Search by name, header or body',
            prefix: Icon(Icons.search, color: p.subText),
          ),
        ),
        const SizedBox(height: 10),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in filters.entries)
                ChoiceChip(
                  label: Text(f.value),
                  selected: c.libraryCategory.value == f.key,
                  showCheckmark: false,
                  onSelected: (_) => c.libraryCategory.value = f.key,
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Obx(() {
          final list = c.libraryTemplates;
          if (list.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 40, color: p.subText),
                  const SizedBox(height: 8),
                  Text(
                    'No templates match your search',
                    style: TextStyle(color: p.subText),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, box) {
              const gap = 12.0;
              final width = (box.maxWidth - gap * (columns - 1)) / columns;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final t in list)
                    SizedBox(
                      width: width,
                      child: _LibraryCard(
                        template: t,
                        onUse: () {
                          c.useLibrary(t);
                          Get.snackbar(
                            'Template added',
                            'Review it and tap Create Template.',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          );
        }),
      ],
    );
  }
}

class _LibraryCard extends StatelessWidget {
  const _LibraryCard({required this.template, required this.onUse});

  final LibraryTemplate template;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Material(
      color: p.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onUse,
        child: Container(
          height: 176,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                template.header,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: p.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  template.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: p.subText, fontSize: 12.5),
                ),
              ),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: p.inner,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: p.border),
                      ),
                      child: Text(
                        template.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: p.text,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: .4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Spacer(),
                  Text(
                    'Use Template →',
                    style: TextStyle(
                      color: p.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
