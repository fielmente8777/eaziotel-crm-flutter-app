// ============================================================
// WHATSAPP SETTING TAB  (Settings > WhatsApp)
//
// Ye file sirf ye tay karti hai ki screen par KYA dikhe:
//
//   WhatsApp connected nahi  ->  _NotConnected (poori screen par message)
//   data aa raha hai         ->  _Loading      (shimmer)
//   menu = Overview          ->  _Overview     (saare card)
//   menu = Credits & Usage   ->  WhatsappCreditsPage
//   menu = kuch aur          ->  SettingComingSoon
//
// Card khud widgets/ folder me hain, data controller/ me.
// ============================================================

import 'package:eazotel/features/setting_screen/whatsapp/screen/whatsapp_Flow_Page.dart';
import 'package:eazotel/utils/res/t_responsive.dart';
import 'package:eazotel/utils/res/t_responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../screen/widgets/setting_coming_soon.dart';
import '../../screen/widgets/setting_section_card.dart';
import '../controller/whatsapp_setting_controller.dart';
import 'whatsapp_credits_page.dart';
import 'widgets/whatsapp_account_cards.dart';
import 'widgets/whatsapp_ai_card.dart';
import 'widgets/whatsapp_auto_message_card.dart';
import 'widgets/whatsapp_business_profile_card.dart';
import 'widgets/whatsapp_setting_menu.dart';
import 'widgets/whatsapp_templates_card.dart';
import 'widgets/whatsapp_widget_card.dart';

/// Settings > WhatsApp tab
class WhatsappSettingTab extends StatelessWidget {
  const WhatsappSettingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WhatsappSettingController());

    return Obx(() {
      final error = controller.errorMessage.value;

      // WhatsApp connected nahi hai -> poori screen par sirf yahi message
      if (!controller.isLoading.value && error != null) {
        return _NotConnected(message: error, onRetry: controller.load);
      }

      return _content(controller);
    });
  }

  Widget _content(WhatsappSettingController controller) {
    return TResponsiveBuilder(
      builder: (context, r) {
        final body = Obx(() {
          final menu = controller.selectedMenu.value;

          if (menu == WhatsappSettingMenu.creditsUsage) {
            return const WhatsappCreditsPage();
          }
          if (menu == WhatsappSettingMenu.flows) {
            return const WhatsappFlowPage();
          }

          if (menu != WhatsappSettingMenu.overview) {
            return SettingComingSoon(title: menu.label);
          }

          if (controller.isLoading.value) return _Loading(r: r);

          return _Overview(controller: controller, r: r);
        });

        // Window: menu left side me. Phone / tablet: menu upar chips me.
        if (r.isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 190,
                child: WhatsappSettingMenuBar(
                  controller: controller,
                  vertical: true,
                ),
              ),
              Expanded(child: body),
            ],
          );
        }

        return Column(
          children: [
            WhatsappSettingMenuBar(controller: controller, vertical: false),
            Expanded(child: body),
          ],
        );
      },
    );
  }
}

// ============================================================
// OVERVIEW
// ============================================================

class _Overview extends StatelessWidget {
  const _Overview({required this.controller, required this.r});

  final WhatsappSettingController controller;
  final TResponsive r;

  @override
  Widget build(BuildContext context) {
    final gap = r.gap + 6;
    final space = SizedBox(height: gap);

    // Web jaisa: left me account + auto message + AI, right me profile + widget
    final left = <Widget>[
      WhatsappAccountCard(controller: controller),
      space,
      WhatsappBusinessProfileCard(controller: controller),
      space,
      WhatsappAutoMessageCard(controller: controller),
      space,
      WhatsappAiCard(controller: controller, r: r),
    ];

    final right = <Widget>[
      WhatsappPhoneCard(controller: controller),

      space,
      // WhatsappWidgetCard(controller: controller),
    ];

    return RefreshIndicator(
      onRefresh: controller.load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(r.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Phone: sab ek ke neeche ek. Tablet / window: do column.
            if (r.isPhone) ...[
              ...left,
              space,
              ...right,
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: left,
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: right,
                    ),
                  ),
                ],
              ),

            space,
            WhatsappTemplatesCard(controller: controller, r: r),
            space,
          ],
        ),
      ),
    );
  }
}

/// WhatsApp connected na ho to poori screen par dikhne wala message
class _NotConnected extends StatelessWidget {
  const _NotConnected({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link_off_rounded, size: 52, color: p.subText),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Connect WhatsApp from the web dashboard, then tap Retry.',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.subText, fontSize: 13),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LOADING (shimmer)
// ============================================================

class _Loading extends StatelessWidget {
  const _Loading({required this.r});

  final TResponsive r;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    Widget block(double height) => Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.border),
      ),
    );

    return Shimmer.fromColors(
      baseColor: p.border,
      highlightColor: Color.lerp(
        p.border,
        Colors.white,
        p.isDark ? 0.12 : 0.7,
      )!,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(r.pagePadding),
        children: [block(110), block(130), block(260), block(180)],
      ),
    );
  }
}
