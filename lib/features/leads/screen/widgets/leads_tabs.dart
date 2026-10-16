// ============================================================
// LEADS TABS  (All Leads | Contact | Converted | Hot)
// Chuna hua tab rangeen pill, saath me us tab ki ginti.
// ============================================================

import 'package:eazotel/features/leads/controller/leads_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'leads_style.dart';

class LeadsTabs extends StatelessWidget {
  final LeadsController controller;

  const LeadsTabs({super.key, required this.controller});

  static const List<String> tabs = ['All Leads', 'Contact', 'Converted', 'Hot'];

  /// Har tab me kitne lead (jo abhi list me aaye hain)
  int _countFor(int index) {
    final all = controller.allLeads;
    switch (index) {
      case 1:
        return all.where((l) => l.contact?.trim().isNotEmpty == true).length;
      case 2:
        return all.where((l) => l.status?.toLowerCase() == 'converted').length;
      case 3:
        return all.where((l) => l.status?.toLowerCase() == 'hot').length;
      default:
        return all.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = LeadsPalette(context);

    return SizedBox(
      height: 46,
      child: Obx(() {
        final selected = controller.selectedLeadTab.value;
        controller.allLeads.length; // list badle to ginti badle

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          itemCount: tabs.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, index) {
            final isOn = selected == index;
            final count = _countFor(index);
            // Tab ka apna rang (All = indigo, Contact = neela, Converted = hara, Hot = laal)
            final color = index == 0 ? p.primary : LeadsStyle.tabColors[index];

            return Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => controller.changeLeadTab(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isOn ? color : p.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isOn ? color : p.border),
                    boxShadow: isOn
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: .35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Text(
                        tabs[index],
                        style: TextStyle(
                          color: isOn ? Colors.white : p.text,
                          fontSize: 13,
                          fontWeight: isOn ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: isOn
                              ? Colors.white.withValues(alpha: .25)
                              : p.tint(color),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            color: isOn ? Colors.white : p.onTint(color),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
