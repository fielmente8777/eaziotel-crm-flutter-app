// ============================================================
// WHATSAPP CREDITS PAGE  (Settings > WhatsApp > Credits & Usage)
//
// Upar do tab: Overview | Transactions
// Neeche chune hue tab ka content:
//   Overview      -> widgets/credits_overview.dart
//   Transactions  -> widgets/credits_transactions.dart
//
// Data WhatsappCreditsController me hai.
// ============================================================

import 'package:eazotel/utils/res/t_responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../screen/widgets/setting_section_card.dart';
import '../controller/whatsapp_credits_controller.dart';
import 'widgets/credits_overview.dart';
import 'widgets/credits_transactions.dart';

class WhatsappCreditsPage extends StatelessWidget {
  const WhatsappCreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WhatsappCreditsController());

    return TResponsiveBuilder(
      builder: (context, r) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(r.pagePadding),
          child: TCenteredContent(
            child: SettingSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CreditsTabs(controller: controller),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.selectedTab.value == CreditsTab.overview) {
                      return CreditsOverview(controller: controller, r: r);
                    }

                    return CreditsTransactions(controller: controller, r: r);
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Overview | Transactions (chune hue tab ke neeche line)
class _CreditsTabs extends StatelessWidget {
  const _CreditsTabs({required this.controller});

  final WhatsappCreditsController controller;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.border)),
      ),
      child: Obx(() {
        final selected = controller.selectedTab.value;

        return Row(
          children: [
            for (final tab in CreditsTab.values)
              InkWell(
                onTap: () => controller.selectedTab.value = tab,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 2,
                        color: tab == selected ? p.primary : Colors.transparent,
                      ),
                    ),
                  ),
                  child: Text(
                    tab.label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: tab == selected ? p.text : p.subText,
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
