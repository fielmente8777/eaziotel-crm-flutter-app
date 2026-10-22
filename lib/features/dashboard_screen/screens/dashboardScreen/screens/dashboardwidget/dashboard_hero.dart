// ============================================================
// DASHBOARD HERO + QUICK ACTIONS  (top part of the Home tab)
//
//   DashboardHero
//     ┌───────────────────────────────────────────┐
//     │ Good morning 👋            Tue, 14 Oct  (S)│  (S) = avatar, tap = menu
//     │ Aroha Palms Resort                         │
//     │ [📍 Goa ▾]          [⚡ 4 new leads today] │
//     └───────────────────────────────────────────┘
//
//   DashboardQuickActions: shortcuts for Leads, WhatsApp, Calls, Analytics ...
//   small round buttons (scroll sideways on phones, wrap on big screens)
//
//   DashboardSectionTitle: the same heading for every section
// ============================================================

import 'package:eazotel/features/Calls%20Management/screen/calls_management_screen.dart';
import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/headerLocationController.dart';
import 'package:eazotel/features/google_ads/screen/google_ads_screen.dart';
import 'package:eazotel/features/googleAnalytis/analytis_screen.dart';
import 'package:eazotel/features/googleAnalytis/binding/analytis_binding.dart';
import 'package:eazotel/features/marketing/screen/whatsapp_marketing_screen.dart';
import 'package:eazotel/features/notifications/screen/widgets/notification_bell.dart';
import 'package:eazotel/features/seo/screen/local_seo_screen.dart';
import 'package:eazotel/features/setting_screen/setting_screen.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// ============================================================
// HERO
// ============================================================

class DashboardHero extends StatelessWidget {
  const DashboardHero({super.key, required this.onMenu});

  /// Tap the avatar: open the menu (drawer)
  final VoidCallback onMenu;

  static String greeting(DateTime now) {
    final h = now.hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final location = Get.find<LocationController>();
    final dashboard = Get.find<DashboardController>();
    final now = DateTime.now();
    final wide = MediaQuery.sizeOf(context).width >= 700;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, wide ? 8 : 4),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4338CA), TAppColors.primary, Color(0xFF7C3AED)],
          ),
          boxShadow: [
            BoxShadow(
              color: TAppColors.primary.withValues(alpha: .35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Halke gole (premium look)
            Positioned(
              right: -40,
              top: -50,
              child: _Bubble(size: 160, alpha: .10),
            ),
            Positioned(
              left: -30,
              bottom: -60,
              child: _Bubble(size: 140, alpha: .07),
            ),
            Padding(
              padding: EdgeInsets.all(wide ? 24 : 18),
              child: Obx(() {
                final hotel = location.selectedHotel.value;
                final name = hotel?.local.trim() ?? '';
                final initial = name.isEmpty ? '' : name[0].toUpperCase();
                final today =
                    dashboard
                        .analyticsResponse
                        .value
                        ?.result
                        ?.docs
                        ?.todayLeads ??
                    0;
                final loading = dashboard.isAnalyticsLoading.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${greeting(now)} 👋',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: .85),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('EEEE, d MMMM').format(now),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: .65),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Bell: count of new WhatsApp messages
                        const NotificationBell(),
                        const SizedBox(width: 10),
                        _Avatar(initial: initial, onTap: onMenu),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      name.isEmpty ? 'Select your hotel' : name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: wide ? 28 : 23,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _GlassChip(
                          icon: Icons.location_on_outlined,
                          text: hotel == null
                              ? 'Choose hotel'
                              : [
                                  if (hotel.city.isNotEmpty) hotel.city,
                                  if (hotel.state.isNotEmpty) hotel.state,
                                ].join(', ').ifEmpty('Change hotel'),
                          trailing: Icons.keyboard_arrow_down_rounded,
                          onTap: location.openHotelSelector,
                        ),
                        if (!loading)
                          _GlassChip(
                            icon: Icons.bolt_rounded,
                            text: today == 0
                                ? 'No new leads today'
                                : '$today new lead${today == 1 ? '' : 's'} today',
                            highlight: today > 0,
                            onTap: () =>
                                Get.find<BottomNavController>().changeTab(1),
                          ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

extension on String {
  String ifEmpty(String other) => isEmpty ? other : this;
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial, required this.onTap});

  final String initial;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Menu',
      child: Material(
        color: Colors.white.withValues(alpha: .18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: .35)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                initial.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.menu_rounded,
                      size: 11,
                      color: TAppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({
    required this.icon,
    required this.text,
    this.trailing,
    this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final String text;
  final IconData? trailing;
  final VoidCallback? onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlight ? Colors.white : Colors.white.withValues(alpha: .16),
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: highlight ? TAppColors.primary : Colors.white,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: highlight ? TAppColors.primary : Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 2),
                Icon(trailing, size: 18, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// QUICK ACTIONS
// ============================================================

class _Action {
  const _Action(this.label, this.icon, this.color, this.onTap);

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

// not using
class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Get.find<BottomNavController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final actions = [
      _Action('Leads', Icons.people_alt_rounded, const Color(0xFF6366F1), () {
        nav.changeTab(1);
      }),
      _Action('WhatsApp', Icons.chat_rounded, const Color(0xFF22C55E), () {
        nav.changeTab(2);
      }),
      _Action('Calls', Icons.call_rounded, const Color(0xFF0EA5E9), () {
        Get.to(() => const CallsManagementScreen());
      }),
      _Action('Analytics', Icons.insights_rounded, const Color(0xFFF59E0B), () {
        Get.to(() => const Analytis(), binding: AnalytisBinding());
      }),
      _Action('Marketing', Icons.campaign_rounded, const Color(0xFFEC4899), () {
        Get.to(() => const WhatsappMarketingScreen());
      }),
      _Action(
        'Google Ads',
        Icons.ads_click_rounded,
        const Color(0xFFEF4444),
        () {
          Get.to(() => const GoogleAdsScreen());
        },
      ),
      _Action('SEO', Icons.travel_explore_rounded, const Color(0xFF10B981), () {
        Get.to(() => const LocalSeoScreen());
      }),
      _Action('Settings', Icons.settings_rounded, const Color(0xFF64748B), () {
        Get.to(() => const SettingScreen());
      }),
    ];

    Widget tile(_Action a) => SizedBox(
      width: 76,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: a.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: a.color.withValues(alpha: isDark ? .2 : .12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(a.icon, color: a.color, size: 24),
              ),
              const SizedBox(height: 6),
              Text(
                a.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? TAppColors.darkText : TAppColors.lightText,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, box) {
        // Centered if everything fits in one line, otherwise scroll sideways
        final fits = box.maxWidth >= actions.length * 84 + 32;

        return SizedBox(
          height: 92,
          child: fits
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [for (final a in actions) tile(a)],
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: actions.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 4),
                  itemBuilder: (_, i) => tile(actions[i]),
                ),
        );
      },
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class DashboardSectionTitle extends StatelessWidget {
  const DashboardSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: TAppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark ? TAppColors.darkText : TAppColors.lightText,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? TAppColors.darkSecondaryText
                          : TAppColors.lightSecondaryText,
                    ),
                  ),
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
