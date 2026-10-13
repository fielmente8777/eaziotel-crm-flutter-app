// ============================================================
// WHATSAPP SETTING MENU
//
// WhatsApp tab ke andar ka menu: Overview, Message Templates ...
//   - Window          : left side me list  (vertical: true)
//   - Phone / tablet  : upar chips         (vertical: false)
// Chuna hua item controller.selectedMenu me rehta hai.
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../controller/whatsapp_setting_controller.dart';

/// WhatsApp tab ka andar wala menu (Overview, Message Templates ...).
/// [vertical] true: left side ki list (window). false: upar ke chips.
class WhatsappSettingMenuBar extends StatelessWidget {
  const WhatsappSettingMenuBar({
    super.key,
    required this.controller,
    required this.vertical,
  });

  final WhatsappSettingController controller;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    Widget item(WhatsappSettingMenu menu, bool selected) {
      return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => controller.selectedMenu.value = menu,
        child: Container(
          width: vertical ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? p.primary.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            menu.label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? p.text : p.primary,
            ),
          ),
        ),
      );
    }

    return Obx(() {
      final selected = controller.selectedMenu.value;

      final items = [
        for (final menu in WhatsappSettingMenu.values)
          Padding(
            padding: EdgeInsets.only(
              right: vertical ? 0 : 6,
              bottom: vertical ? 4 : 0,
            ),
            child: item(menu, menu == selected),
          ),
      ];

      if (vertical) {
        return Container(
          height: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: p.border)),
          ),
          child: SingleChildScrollView(child: Column(children: items)),
        );
      }

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.border)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(children: items),
        ),
      );
    });
  }
}
