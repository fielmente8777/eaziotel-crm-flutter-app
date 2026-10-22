// ============================================================
// SUBSCRIPTION PLANS SCREEN  (web ke Billing page jaisa)
//
//   "Choose your plan & customize your tools"
//   BASE PLAN     : BASIC | PRO (Most popular) | ENTERPRISE (Talk to sales)
//   ADD APPS      : har app [Add] / [Added] / [Purchased]
//   TEAM MEMBERS  : [-] 0 [+]   ₹500 / seat / mahina
//   BILLING SUMMARY: Monthly | Quarterly | 6 Months | Yearly, total, Pay
//
//   window : left content + right summary (web jaisa)
//   tablet : 2 column cards, summary neeche
//   phone  : 1 column, summary neeche + niche total / Pay bar
// ============================================================

import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../screen/widgets/setting_section_card.dart';
import '../controller/plan_builder_controller.dart';
import '../model/billing_models.dart';

/// Web ka "ternary" (orange) rang: chuna hua plan / app
const Color _accent = Color(0xFFF26B1D);

final _rupee = NumberFormat.decimalPattern('en_IN');
String _price(num v) => '₹${_rupee.format(v.round())}';

class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key, this.onRecheck, this.onSignOut});

  /// Plan khatam hone par (dashboard ki jagah) yahi screen: back nahi,
  /// upar "Check again" + "Sign out"
  final VoidCallback? onRecheck;
  final VoidCallback? onSignOut;

  bool get _gate => onSignOut != null;

  @override
  Widget build(BuildContext context) {
    final c = Get.put(PlanBuilderController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plans & billing'),
        automaticallyImplyLeading: !_gate,
        actions: [
          if (onRecheck != null)
            IconButton(
              tooltip: 'Check again',
              onPressed: onRecheck,
              icon: const Icon(Icons.refresh),
            ),
          if (onSignOut != null)
            TextButton(onPressed: onSignOut, child: const Text('Sign out')),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) {
            final wide = box.maxWidth >= 1000;
            final columns = box.maxWidth >= 600 ? 2 : 1;

            final content = _Content(controller: c, columns: columns);
            final summary = _BillingSummary(controller: c);

            if (wide) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 20, 12, 32),
                          child: content,
                        ),
                      ),
                      SizedBox(
                        width: 360,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(12, 20, 24, 32),
                          child: summary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: c.load,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        box.maxWidth >= 600 ? 24 : 16,
                        16,
                        box.maxWidth >= 600 ? 24 : 16,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          content,
                          const SizedBox(height: 24),
                          summary,
                        ],
                      ),
                    ),
                  ),
                ),
                _PayBar(controller: c),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// LEFT: header + plans + apps + team
// ============================================================

class _Content extends StatelessWidget {
  const _Content({required this.controller, required this.columns});

  final PlanBuilderController controller;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final c = controller;

    return Obx(() {
      Widget grid(List<Widget> items, {double gap = 12}) => LayoutBuilder(
        builder: (_, box) {
          final width = (box.maxWidth - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final item in items) SizedBox(width: width, child: item),
            ],
          );
        },
      );

      Widget plansSection;
      if (c.isLoading.value) {
        plansSection = _Shimmer(columns: columns);
      } else if (c.loadError.value) {
        plansSection = Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.border),
          ),
          child: Column(
            children: [
              Text(
                "We couldn't load the plans right now.",
                style: TextStyle(color: p.text),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: _accent),
                onPressed: c.load,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try again'),
              ),
            ],
          ),
        );
      } else {
        plansSection = grid([
          for (final plan in c.visiblePlans)
            _PlanCard(
              plan: plan,
              selected: c.selectedPlan.value?.id == plan.id,
              purchased: c.isPurchasedPlan(plan.id),
              onSelect: () => c.selectPlan(plan),
            ),
        ], gap: 16);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(controller: c),
          const SizedBox(height: 24),
          const _SectionTitle(
            icon: Icons.layers_outlined,
            title: 'Base plan',
            hint: 'Required',
          ),
          plansSection,
          const SizedBox(height: 28),
          const _SectionTitle(
            icon: Icons.extension_outlined,
            title: 'Add apps to your plan',
            hint: 'Optional',
          ),
          if (c.appsLocked && !c.isLoading.value)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.inner,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: p.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 16, color: p.subText),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Select a base plan above to enable add-on apps',
                      style: TextStyle(color: p.subText, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          grid([
            for (final app in c.apps)
              _AppCard(
                app: app,
                selected: c.selectedAppIds.contains(app.id),
                // Renew: khareeda hua bhi add / remove ho sakta hai
                purchased: c.isPurchasedApp(app.id) && !c.isRenewal,
                purchasedEarlier: c.isPurchasedApp(app.id) && c.isRenewal,
                locked: c.appsLocked,
                onToggle: () => c.toggleApp(app),
              ),
          ], gap: 10),
          const SizedBox(height: 28),
          const _SectionTitle(
            icon: Icons.group_outlined,
            title: 'Team members',
            hint: 'Optional',
          ),
          _TeamCard(controller: c),
        ],
      );
    });
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final PlanBuilderController controller;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final s = controller.subscription;
    final days = controller.remainingDays;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _accent.withValues(alpha: .35)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 13, color: _accent),
              SizedBox(width: 5),
              Text(
                'HOTEL GROWTH PLATFORM',
                style: TextStyle(
                  color: _accent,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Choose your plan & customize your tools',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: p.text,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Start with a base plan, then add only the tools you need.\n'
          'Transparent pricing, no surprises.',
          textAlign: TextAlign.center,
          style: TextStyle(color: p.subText, fontSize: 13.5, height: 1.4),
        ),
        if (s?.endDate != null) ...[
          const SizedBox(height: 12),
          _StatusChip(days: days, endDate: s!.endDate!, plan: s.plan.name),
        ],
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.days,
    required this.endDate,
    required this.plan,
  });

  final int days;
  final DateTime endDate;
  final String plan;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = days == 0
        ? (TAppColors.error, Icons.warning_amber_rounded)
        : days <= 7
        ? (TAppColors.warning, Icons.schedule)
        : (TAppColors.success, Icons.check_circle_outline);

    final date = DateFormat('d MMM yyyy').format(endDate.toLocal());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              days == 0
                  ? '${plan.isEmpty ? 'Your' : plan} plan expired on $date'
                  : '${plan.isEmpty ? '' : '$plan · '}$days ${days == 1 ? 'day' : 'days'} left · valid until $date',
              style: TextStyle(
                color: color,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.hint,
  });

  final IconData icon;
  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 15, color: p.subText),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '${title.toUpperCase()} — ${hint.toUpperCase()}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: p.subText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: .6,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: p.border, height: 1)),
        ],
      ),
    );
  }
}

// ============================================================
// PLAN CARD
// ============================================================

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.purchased,
    required this.onSelect,
  });

  final BillingPlan plan;
  final bool selected;
  final bool purchased;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final canSelect = !purchased && !plan.isEnterprise;
    final ribbon = purchased
        ? ('Current plan', TAppColors.success)
        : plan.isPopular
        ? ('Most popular', _accent)
        : null;

    final borderColor = selected
        ? _accent
        : plan.isPopular && !purchased
        ? _accent.withValues(alpha: .5)
        : p.border;

    Widget action;
    if (plan.isEnterprise) {
      action = OutlinedButton.icon(
        onPressed: () => launchUrl(
          Uri.parse(PlanBuilderController.salesWhatsappUrl),
          mode: LaunchMode.externalApplication,
        ),
        icon: const Icon(Icons.chat_outlined, size: 16),
        label: const Text('Talk to sales'),
      );
    } else if (purchased) {
      action = Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: TAppColors.success.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Active plan',
          style: TextStyle(
            color: TAppColors.success,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else if (selected) {
      action = Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _accent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 16, color: Colors.white),
            SizedBox(width: 6),
            Text(
              'Selected',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    } else {
      action = OutlinedButton(
        onPressed: onSelect,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(40),
          side: BorderSide(color: p.border),
          foregroundColor: p.text,
        ),
        child: const Text('Select plan'),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: p.card,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: canSelect ? onSelect : null,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor,
                  width: selected ? 1.6 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name.toUpperCase(),
                    style: TextStyle(
                      color: p.subText,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: plan.isEnterprise
                              ? 'Custom'
                              : _price(plan.price),
                          style: TextStyle(
                            color: p.text,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (!plan.isEnterprise)
                          TextSpan(
                            text: ' /mo',
                            style: TextStyle(color: p.subText, fontSize: 13),
                          ),
                      ],
                    ),
                  ),
                  if (plan.tagline.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      plan.tagline,
                      style: TextStyle(
                        color: p.subText,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(width: double.infinity, child: action),
                  if (plan.includes.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      'INCLUDES',
                      style: TextStyle(
                        color: p.subText,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    for (final item in plan.includes)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check,
                              size: 15,
                              color: TAppColors.success,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(color: p.text, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (ribbon != null)
          Positioned(
            top: -10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: ribbon.$2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  ribbon.$1.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .4,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ============================================================
// APP CARD
// ============================================================

class _AppCard extends StatelessWidget {
  const _AppCard({
    this.purchasedEarlier = false,
    required this.app,
    required this.selected,
    required this.purchased,
    required this.locked,
    required this.onToggle,
  });

  final BillingApp app;
  final bool selected;
  final bool purchased;
  final bool locked;
  final VoidCallback onToggle;

  /// Pehle khareeda tha (renew me phir se le rahe hain)
  final bool purchasedEarlier;

  static const _icons = <String, IconData>{
    'WhatsApp Chat': Icons.chat_bubble_outline,
    'Lead Management': Icons.track_changes,
    'Exotel Integration': Icons.phone_in_talk_outlined,
    'CRM': Icons.contacts_outlined,
    'Booking Engine + Reservation Desk': Icons.hotel_outlined,
    'Eazbot': Icons.smart_toy_outlined,
    'Webhook': Icons.webhook,
    'WordPress Webhook': Icons.extension_outlined,
    'GRM': Icons.bar_chart,
    'Meta Leads': Icons.show_chart,
    'Google Ads Insights': Icons.campaign_outlined,
    'Social Media': Icons.share_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final active = selected && !purchased;

    final iconColor = purchased
        ? TAppColors.success
        : active
        ? _accent
        : p.subText;

    Widget trailing;
    if (purchased) {
      trailing = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: TAppColors.success.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Purchased',
          style: TextStyle(
            color: TAppColors.success,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else {
      trailing = SizedBox(
        height: 32,
        child: active
            ? FilledButton.icon(
                onPressed: locked ? null : onToggle,
                style: FilledButton.styleFrom(
                  backgroundColor: _accent,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.check, size: 15),
                label: const Text('Added', style: TextStyle(fontSize: 12.5)),
              )
            : OutlinedButton(
                onPressed: locked ? null : onToggle,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  visualDensity: VisualDensity.compact,
                  side: BorderSide(color: p.border),
                  foregroundColor: p.text,
                ),
                child: const Text('Add', style: TextStyle(fontSize: 12.5)),
              ),
      );
    }

    return Opacity(
      opacity: locked && !purchased ? .5 : 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? _accent : p.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _icons[app.name] ?? Icons.power_outlined,
                size: 19,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${_price(app.price)}/month',
                    style: TextStyle(color: p.subText, fontSize: 12),
                  ),
                  if (purchasedEarlier)
                    const Text(
                      'Purchased earlier',
                      style: TextStyle(
                        color: TAppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TEAM SEATS
// ============================================================

class _TeamCard extends StatelessWidget {
  const _TeamCard({required this.controller});

  final PlanBuilderController controller;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: p.inner,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.group_outlined, size: 19, color: p.subText),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Additional seats',
                  style: TextStyle(
                    color: p.text,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${_price(PlanBuilderController.teamSeatPrice)} per member / month',
                  style: TextStyle(color: p.subText, fontSize: 12),
                ),
              ],
            ),
          ),
          Obx(() {
            final count = controller.teamCount.value;

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: p.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Remove a seat',
                    visualDensity: VisualDensity.compact,
                    onPressed: count == 0
                        ? null
                        : () => controller.changeTeam(-1),
                    icon: const Icon(Icons.remove, size: 18),
                  ),
                  SizedBox(
                    width: 32,
                    child: Text(
                      '$count',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: p.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Add a seat',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => controller.changeTeam(1),
                    icon: const Icon(Icons.add, size: 18),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================
// BILLING SUMMARY
// ============================================================

class _BillingSummary extends StatefulWidget {
  const _BillingSummary({required this.controller});

  final PlanBuilderController controller;

  @override
  State<_BillingSummary> createState() => _BillingSummaryState();
}

class _BillingSummaryState extends State<_BillingSummary> {
  bool _showCurrentApps = false;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final c = widget.controller;

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: p.subText,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: .6,
        ),
      ),
    );

    Widget row(
      String left,
      String right, {
      Color? rightColor,
      Color? leftColor,
    }) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              left,
              style: TextStyle(color: leftColor ?? p.text, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            right,
            style: TextStyle(
              color: rightColor ?? p.text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    return Obx(() {
      final plan = c.selectedPlan.value;
      final cycle = c.cycle.value;
      final newApps = c.newApps;
      final purchased = c.purchasedApps;
      final busy = c.isProcessing.value;
      c.teamCount.value; // seats badle to dobara

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 18,
                  color: _accent,
                ),
                const SizedBox(width: 8),
                Text(
                  'Billing summary',
                  style: TextStyle(
                    color: p.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Divider(color: p.border, height: 24),

            if (plan == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Select a plan to see\nyour billing summary',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.subText, fontSize: 13),
                ),
              )
            else ...[
              // ---------- Billing cycle ----------
              label('Billing cycle'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final cy in BillingCycle.values)
                    ChoiceChip(
                      label: Text('${cy.label}  −${cy.discount}%'),
                      selected: cy == cycle,
                      selectedColor: const Color(0xFF2563EB),
                      labelStyle: TextStyle(
                        color: cy == cycle ? Colors.white : p.text,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                      showCheckmark: false,
                      onSelected: (_) => c.cycle.value = cy,
                    ),
                ],
              ),

              // ---------- Plan ----------
              label('Plan'),
              row(
                '${plan.name} plan',
                c.isCurrentPlan ? 'Active' : '${_price(plan.price)}/mo',
                rightColor: c.isCurrentPlan ? TAppColors.success : null,
              ),

              // ---------- Current apps ----------
              if (purchased.isNotEmpty && !c.isRenewal) ...[
                const SizedBox(height: 6),
                InkWell(
                  onTap: () =>
                      setState(() => _showCurrentApps = !_showCurrentApps),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Current apps (${purchased.length})',
                            style: TextStyle(color: p.subText, fontSize: 12.5),
                          ),
                        ),
                        const Text(
                          'Active',
                          style: TextStyle(
                            color: TAppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Icon(
                          _showCurrentApps
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 18,
                          color: p.subText,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showCurrentApps)
                  for (final a in purchased)
                    row(
                      a.name,
                      'Already active',
                      leftColor: p.subText,
                      rightColor: TAppColors.success,
                    ),
              ],

              // ---------- New apps ----------
              if (newApps.isNotEmpty) ...[
                label(c.isRenewal ? 'Add-on apps' : 'New add-on apps'),
                for (final a in newApps)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          a.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: p.text, fontSize: 13),
                        ),
                      ),
                      Text(
                        '${_price(a.price)}/mo',
                        style: TextStyle(
                          color: p.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove ${a.name}',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => c.toggleApp(a),
                        icon: Icon(Icons.close, size: 16, color: p.subText),
                      ),
                    ],
                  ),
              ],

              if (c.teamCount.value > 0) ...[
                label('Team'),
                row(
                  'Team seats (${c.teamCount.value} × ${_price(PlanBuilderController.teamSeatPrice)})',
                  '${_price(c.teamCost)}/mo',
                ),
              ],

              Divider(color: p.border, height: 28),

              if (c.subtotal > 0) ...[
                row(
                  'Subtotal · ${cycle.months} ${cycle.months == 1 ? 'month' : 'months'}',
                  _price(c.subtotal),
                ),
                row(
                  'Discount (${cycle.discount}%)',
                  '− ${_price(c.discountAmount)}',
                  rightColor: TAppColors.success,
                ),
                row(
                  'GST (${PlanBuilderController.gstPercent}%)',
                  '+ ${_price(c.gstAmount)}',
                  leftColor: p.subText,
                  rightColor: p.subText,
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        'Total',
                        style: TextStyle(
                          color: p.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _price(c.total),
                          style: TextStyle(
                            color: p.text,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '≈ ${_price(c.total / cycle.months)}/mo incl. GST',
                          style: TextStyle(color: p.subText, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${cycle.discount}% discount applied',
                    style: const TextStyle(
                      color: TAppColors.success,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ] else
                Text(
                  'Everything you have is already active.\n'
                  'Add an app to see your total.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.subText, fontSize: 12.5),
                ),
            ],

            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: c.canPay ? c.pay : null,
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
                disabledBackgroundColor: _accent.withValues(alpha: .35),
                disabledForegroundColor: Colors.white70,
                minimumSize: const Size.fromHeight(48),
              ),
              icon: Icon(
                busy ? Icons.hourglass_top_rounded : Icons.lock_outline,
                size: 18,
              ),
              label: Text(
                busy
                    ? 'Processing…'
                    : c.canPay
                    ? 'Pay ${_price(c.total)}'
                    : 'Continue to payment',
              ),
            ),
            if (plan != null && newApps.isEmpty && !c.isRenewal) ...[
              const SizedBox(height: 6),
              Text(
                'Add at least one new app to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(color: p.subText, fontSize: 12),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user_outlined, size: 13, color: p.subText),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Secure payment via Razorpay · No contracts',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: p.subText, fontSize: 11.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// ============================================================
// PHONE / TABLET: neeche chipka total + Pay
// ============================================================

class _PayBar extends StatelessWidget {
  const _PayBar({required this.controller});

  final PlanBuilderController controller;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final c = controller;

    return Obx(() {
      if (c.selectedPlan.value == null) return const SizedBox.shrink();
      c.teamCount.value;
      c.cycle.value;

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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.subtotal > 0 ? _price(c.total) : '₹0',
                      style: TextStyle(
                        color: p.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${c.cycle.value.label} · incl. GST',
                      style: TextStyle(color: p.subText, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: c.canPay ? c.pay : null,
                style: FilledButton.styleFrom(
                  backgroundColor: _accent,
                  disabledBackgroundColor: _accent.withValues(alpha: .35),
                  disabledForegroundColor: Colors.white70,
                  minimumSize: const Size(0, 46),
                ),
                icon: Icon(
                  c.isProcessing.value
                      ? Icons.hourglass_top_rounded
                      : Icons.lock_outline,
                  size: 18,
                ),
                label: Text(c.isProcessing.value ? 'Processing…' : 'Pay now'),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ============================================================
// LOADING
// ============================================================

class _Shimmer extends StatelessWidget {
  const _Shimmer({required this.columns});

  final int columns;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Shimmer.fromColors(
      baseColor: p.border,
      highlightColor: Color.lerp(p.border, Colors.white, p.isDark ? .12 : .7)!,
      child: Row(
        children: [
          for (var i = 0; i < columns; i++) ...[
            if (i > 0) const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: p.card,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
