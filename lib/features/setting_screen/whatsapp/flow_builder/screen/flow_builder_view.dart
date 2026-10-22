// ============================================================
// FLOW BUILDER VIEW  (Flows > Create Flow tab)
//
//   no template chosen -> two cards (Lead Generation, Feedback Form)
//                          tap -> name dialog
//   builder             -> name + Publish on top
//                          SCREENS (list / chips) | CONTENT | PREVIEW
//      window : all three in one row
//      tablet : screen chips on top, content + preview in one row
//      phone  : screen chips, content, preview stacked
// ============================================================

import 'package:eazotel/utils/res/t_responsive.dart';
import 'package:eazotel/utils/res/t_responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../screen/widgets/wa_form_widgets.dart';
import '../controller/flow_builder_controller.dart';
import '../models/flow_builder_models.dart';

class FlowBuilderView extends StatelessWidget {
  const FlowBuilderView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(FlowBuilderController());

    return TResponsiveBuilder(
      builder: (context, r) => Obx(
        () => c.template.value == null
            ? _TemplatePicker(c: c)
            : _Builder(c: c, r: r),
      ),
    );
  }
}

// ============================================================
// STEP 1 + 2: TEMPLATE + NAME
// ============================================================

class _TemplatePicker extends StatelessWidget {
  const _TemplatePicker({required this.c});

  final FlowBuilderController c;

  Future<void> _askName(BuildContext context, FlowTemplateOption option) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _FlowNameDialog(option: option),
    );

    if (result != null && result.trim().isNotEmpty) c.start(option, result);
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'TEMPLATES',
          style: TextStyle(
            color: p.subText,
            fontSize: 11,
            letterSpacing: .8,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        for (final option in FlowTemplateOption.all)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: p.inner,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _askName(context, option),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: p.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(option.icon, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.title,
                              style: TextStyle(
                                color: p.text,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              option.description,
                              style: TextStyle(
                                color: p.subText,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: p.subText),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 18),
        Text(
          'Select a template above and make it your own by customising it.',
          textAlign: TextAlign.center,
          style: TextStyle(color: p.subText, fontSize: 12.5),
        ),
      ],
    );
  }
}

/// Name dialog. Its controller is kept and released only after it closes.
class _FlowNameDialog extends StatefulWidget {
  const _FlowNameDialog({required this.option});

  final FlowTemplateOption option;

  @override
  State<_FlowNameDialog> createState() => _FlowNameDialogState();
}

class _FlowNameDialogState extends State<_FlowNameDialog> {
  final _name = TextEditingController();
  late final _category = TextEditingController(text: widget.option.title);

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    super.dispose();
  }

  void _save() {
    final value = _name.text.trim();
    if (value.isNotEmpty) Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return AlertDialog(
      backgroundColor: p.card,
      title: Text('Enter flow details', style: TextStyle(color: p.text)),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const WaLabel('Flow Name'),
            TextField(
              controller: _name,
              autofocus: true,
              decoration: waInput(context, hint: 'Enter flow name'),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 14),
            const WaLabel('Category'),
            TextField(
              enabled: false,
              controller: _category,
              decoration: waInput(context),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ValueListenableBuilder(
          valueListenable: _name,
          builder: (context, value, _) => ElevatedButton(
            style: waPrimaryButton(context, color: Colors.green),
            onPressed: value.text.trim().isEmpty ? null : _save,
            child: const Text('Save and continue'),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// STEP 3: BUILDER
// ============================================================

class _Builder extends StatelessWidget {
  const _Builder({required this.c, required this.r});

  final FlowBuilderController c;
  final TResponsive r;

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(width: 14, height: 14);

    final header = _Header(c: c);
    final content = _Content(c: c);
    final preview = _Preview(c: c);

    if (r.isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          gap,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 200, child: _ScreenList(c: c)),
              gap,
              Expanded(child: content),
              gap,
              SizedBox(width: 280, child: preview),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        gap,
        _ScreenChips(c: c),
        gap,
        if (r.isTablet)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: content),
              gap,
              SizedBox(width: 260, child: preview),
            ],
          )
        else ...[
          content,
          gap,
          preview,
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.c});

  final FlowBuilderController c;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Obx(
      () => Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Back to templates',
                onPressed: c.isPublishing.value ? null : c.backToTemplates,
                icon: Icon(Icons.arrow_back, color: p.text),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.flowName.value,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    c.template.value?.title ?? '',
                    style: TextStyle(color: p.subText, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton.icon(
            style: waPrimaryButton(context, color: Colors.green),
            onPressed: c.isPublishing.value ? null : c.publish,
            icon: Icon(
              c.isPublishing.value ? Icons.hourglass_top : Icons.publish,
              size: 18,
            ),
            label: Text(c.isPublishing.value ? 'Publishing…' : 'Publish'),
          ),
        ],
      ),
    );
  }
}

/// Window: list on the left
class _ScreenList extends StatelessWidget {
  const _ScreenList({required this.c});

  final FlowBuilderController c;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Obx(() {
      c.tick; // the list changes too when the name changes
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'SCREENS',
            style: TextStyle(
              color: p.subText,
              fontSize: 11,
              letterSpacing: .8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < c.screens.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Material(
                color: i == c.activeIndex.value
                    ? p.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => c.selectScreen(i),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 4, 2, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            c.screens[i].title.text.isEmpty
                                ? 'Untitled'
                                : c.screens[i].title.text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: i == c.activeIndex.value
                                  ? Colors.white
                                  : p.text,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (c.screens.length > 1)
                          IconButton(
                            tooltip: 'Delete screen',
                            visualDensity: VisualDensity.compact,
                            onPressed: () => c.removeScreen(c.screens[i]),
                            icon: Icon(
                              Icons.close,
                              size: 16,
                              color: i == c.activeIndex.value
                                  ? Colors.white
                                  : Colors.red,
                            ),
                          )
                        else
                          const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            style: waOutlineButton(context),
            onPressed: c.addScreen,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Screen'),
          ),
        ],
      );
    });
  }
}

/// Phone / tablet: chips on top
class _ScreenChips extends StatelessWidget {
  const _ScreenChips({required this.c});

  final FlowBuilderController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      c.tick;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < c.screens.length; i++)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InputChip(
                  label: Text(
                    c.screens[i].title.text.isEmpty
                        ? 'Untitled'
                        : c.screens[i].title.text,
                  ),
                  selected: i == c.activeIndex.value,
                  showCheckmark: false,
                  onPressed: () => c.selectScreen(i),
                  onDeleted: c.screens.length > 1
                      ? () => c.removeScreen(c.screens[i])
                      : null,
                ),
              ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 16),
              label: const Text('Add Screen'),
              onPressed: c.addScreen,
            ),
          ],
        ),
      );
    });
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.c});

  final FlowBuilderController c;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Obx(() {
      final screen = c.activeScreen;
      if (screen == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p.inner,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: p.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'CONTENT',
              style: TextStyle(
                color: p.subText,
                fontSize: 11,
                letterSpacing: .8,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const WaLabel('Screen title'),
            TextField(
              key: ValueKey('title-${screen.id}'),
              controller: screen.title,
              decoration: waInput(context, hint: 'e.g. Sign up'),
            ),
            const SizedBox(height: 14),
            if (screen.fields.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'No fields yet. Add the questions guests will answer.',
                  style: TextStyle(color: p.subText, fontSize: 12.5),
                ),
              ),
            for (var i = 0; i < screen.fields.length; i++)
              _FieldCard(
                key: ObjectKey(screen.fields[i]),
                index: i,
                field: screen.fields[i],
                onRemove: () => c.removeField(screen.fields[i]),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                style: waOutlineButton(context),
                onPressed: c.addField,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Field'),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    super.key,
    required this.index,
    required this.field,
    required this.onRemove,
  });

  final int index;
  final FlowFieldDraft field;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 6, 4, 10),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Field ${index + 1}',
                style: TextStyle(
                  color: p.subText,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Required',
                style: TextStyle(color: p.subText, fontSize: 12),
              ),
              Obx(
                () => Switch(
                  value: field.required.value,
                  onChanged: (v) => field.required.value = v,
                ),
              ),
              IconButton(
                tooltip: 'Delete field',
                visualDensity: VisualDensity.compact,
                onPressed: onRemove,
                icon: const Icon(Icons.close, size: 18, color: Colors.red),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: field.label,
                  decoration: waInput(context, hint: 'Question / label'),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => WaDropdown<FlowFieldType>(
                    key: ValueKey('type-${field.type.value}'),
                    value: field.type.value,
                    items: {for (final t in FlowFieldType.values) t: t.label},
                    onChanged: (t) => field.type.value = t,
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

class _Preview extends StatelessWidget {
  const _Preview({required this.c});

  final FlowBuilderController c;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Obx(() {
      c.tick;
      final screen = c.activeScreen;
      if (screen == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'PREVIEW',
              style: TextStyle(
                color: p.subText,
                fontSize: 11,
                letterSpacing: .8,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              screen.title.text.isEmpty ? 'Untitled' : screen.title.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            for (final f in screen.fields)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Obx(
                  () => TextField(
                    enabled: false,
                    maxLines: f.type.value == FlowFieldType.textarea ? 3 : 1,
                    decoration: waInput(
                      context,
                      hint:
                          '${f.label.text.isEmpty ? 'Field' : f.label.text}'
                          '${f.required.value ? ' *' : ''}',
                      suffix: Icon(f.type.value.icon, size: 18),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 4),
            ElevatedButton(
              style: waPrimaryButton(context, color: Colors.green),
              onPressed: () {},
              child: const Text('Submit'),
            ),
          ],
        ),
      );
    });
  }
}
