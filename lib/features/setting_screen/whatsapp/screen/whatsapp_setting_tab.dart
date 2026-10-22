// ============================================================
// WHATSAPP SETTING TAB  (Settings > WhatsApp)
//
// This file only decides WHAT shows on screen:
//
//   WhatsApp not connected  ->  _NotConnected (full-screen message)
//   data loading            ->  _Loading      (shimmer)
//   menu = Overview          ->  _Overview     (all cards)
//   menu = Credits & Usage   ->  WhatsappCreditsPage
//   menu = Message Templates ->  MessageTemplatesPage (message_templates/)
//   menu = Auto Message      ->  _AutoMessagePage
//   menu = Flows             ->  WhatsappFlowPage (+ flow_builder/)
//   menu = Quick Replies     ->  QuickRepliesPage (quick_replies/)
//   menu = WhatsApp Flow     ->  ChatbotFlowPage (chatbot_flow/)
//
// The cards themselves are in the widgets/ folder, data in controller/.
// ============================================================

import 'package:eazotel/features/setting_screen/whatsapp/screen/whatsapp_Flow_Page.dart';
import 'package:eazotel/utils/res/t_responsive.dart';
import 'package:eazotel/utils/res/t_responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../screen/widgets/setting_section_card.dart';
import '../controller/whatsapp_setting_controller.dart';
import '../chatbot_flow/screen/chatbot_flow_page.dart';
import '../message_templates/screen/message_templates_page.dart';
import '../quick_replies/screen/quick_replies_page.dart';
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

      // WhatsApp is not connected -> only this message on the full screen
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

          switch (menu) {
            case WhatsappSettingMenu.creditsUsage:
              return const WhatsappCreditsPage();
            case WhatsappSettingMenu.flows:
              return const WhatsappFlowPage();
            case WhatsappSettingMenu.messageTemplates:
              return const MessageTemplatesPage();
            case WhatsappSettingMenu.quickReplies:
              return const QuickRepliesPage();
            case WhatsappSettingMenu.whatsappFlow:
              return const ChatbotFlowPage();
            case WhatsappSettingMenu.autoMessage:
              if (controller.isLoading.value) return _Loading(r: r);
              return _AutoMessagePage(controller: controller, r: r);
            case WhatsappSettingMenu.overview:
              if (controller.isLoading.value) return _Loading(r: r);
              return _Overview(controller: controller, r: r);
          }
        });

        // Window: menu on the left. Phone / tablet: menu as chips on top.
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

    // Same as web: account + auto message + AI on the left, profile + widget on the right
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
            // Phone: everything stacked. Tablet / window: two columns.
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

// ============================================================
// AUTO MESSAGE (separate page; the same card as Overview, in the middle)
// ============================================================

class _AutoMessagePage extends StatelessWidget {
  const _AutoMessagePage({required this.controller, required this.r});

  final WhatsappSettingController controller;
  final TResponsive r;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(r.pagePadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: WhatsappAutoMessageCard(
              controller: controller,
              columns: r.isPhone ? 1 : 2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-screen message shown when WhatsApp is not connected
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
