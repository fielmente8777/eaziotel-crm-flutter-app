// ============================================================
// WHATSAPP FORM WIDGETS
// Settings > WhatsApp ke naye page (Templates, Quick Replies,
// Create Flow) me baar-baar lagne wale chhote widget:
//
//   waInput()      : TextField ka dabba (light / dark dono)
//   WaLabel        : field ke upar ka naam (+ right side me kuch)
//   WaSubTabs      : "Create Template | Template Library" jaise tab
//   WaPageHeader   : page ka title + subtitle + button
//   WaDropdown     : chhota dropdown
//   WaCounter      : "12/60"
// ============================================================

import 'package:flutter/material.dart';

import '../../../screen/widgets/setting_section_card.dart';

InputDecoration waInput(
  BuildContext context, {
  String? hint,
  String? error,
  Widget? prefix,
  Widget? suffix,
}) {
  final p = SettingPalette(context);

  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: c, width: w),
  );

  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: p.subText, fontSize: 13),
    errorText: error,
    errorMaxLines: 2,
    isDense: true,
    filled: true,
    fillColor: p.inner,
    prefixIcon: prefix,
    suffixIcon: suffix,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: border(p.border),
    enabledBorder: border(p.border),
    disabledBorder: border(p.border.withValues(alpha: .5)),
    focusedBorder: border(p.primary, 1.5),
  );
}

class WaLabel extends StatelessWidget {
  const WaLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: p.text,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Chhoti screen par right wala hissa bhi sikud sake
          if (trailing != null)
            Flexible(
              child: Align(alignment: Alignment.centerRight, child: trailing),
            ),
        ],
      ),
    );
  }
}

class WaCounter extends StatelessWidget {
  const WaCounter({super.key, required this.length, required this.max});

  final int length;
  final int max;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Text(
      '$length/$max',
      style: TextStyle(
        color: length > max ? Colors.red : p.subText,
        fontSize: 11,
      ),
    );
  }
}

/// Upar ke tab (Create | Library). [labels] me naam, [selected] chuna hua
class WaSubTabs extends StatelessWidget {
  const WaSubTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelect,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              InkWell(
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: i == selected ? p.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      color: i == selected ? p.primary : p.subText,
                      fontWeight: i == selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class WaPageHeader extends StatelessWidget {
  const WaPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: p.text,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(subtitle, style: TextStyle(color: p.subText, fontSize: 12.5)),
      ],
    );

    return Wrap(
      spacing: 12,
      runSpacing: 10,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [text, ?action],
    );
  }
}

class WaDropdown<T> extends StatelessWidget {
  const WaDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;

  /// value -> screen par naam
  final Map<T, String> items;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return DropdownButtonFormField<T>(
      initialValue: items.containsKey(value) ? value : null,
      isExpanded: true,
      dropdownColor: p.card,
      style: TextStyle(color: p.text, fontSize: 13.5),
      decoration: waInput(context),
      items: [
        for (final e in items.entries)
          DropdownMenuItem(value: e.key, child: Text(e.value)),
      ],
      onChanged: onChanged == null
          ? null
          : (v) => v == null ? null : onChanged!(v),
    );
  }
}

/// Primary rang ka chhota button (Row me bhi chalta hai)
ButtonStyle waPrimaryButton(BuildContext context, {Color? color}) =>
    ElevatedButton.styleFrom(
      backgroundColor: color ?? SettingPalette(context).primary,
      foregroundColor: Colors.white,
      minimumSize: const Size(0, 42),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

ButtonStyle waOutlineButton(BuildContext context) {
  final p = SettingPalette(context);
  return OutlinedButton.styleFrom(
    foregroundColor: p.text,
    minimumSize: const Size(0, 42),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    side: BorderSide(color: p.border),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
}
