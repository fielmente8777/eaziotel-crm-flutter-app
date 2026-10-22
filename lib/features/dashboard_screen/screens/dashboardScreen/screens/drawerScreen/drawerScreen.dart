// ============================================================
// DASHBOARD DRAWER (menu)
//
//   top      : hotel card (name, city, email) + "View profile"
//              (Profile is in the bottom tab; no separate item here)
//   INSIGHTS : Google Analytics, Google Ads Insights, Meta Insights, SEO
//   ENGAGE   : Marketing (WhatsApp / Email), Calls Management, Social Media
//   (Settings, theme, logout, version are now in the "Settings" bottom tab)
//
// The whole list scrolls (nothing gets cut off even on small phones).
// ============================================================

import 'package:eazotel/features/Calls%20Management/screen/calls_management_screen.dart';
import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/headerLocationController.dart';
import 'package:eazotel/features/google_ads/screen/google_ads_screen.dart';
import 'package:eazotel/features/googleAnalytis/analytis_screen.dart';
import 'package:eazotel/features/googleAnalytis/binding/analytis_binding.dart';
import 'package:eazotel/features/marketing/screen/email_marketing_screen.dart';
import 'package:eazotel/features/meta_insights/screen/meta_insights_screen.dart';
import 'package:eazotel/features/marketing/screen/whatsapp_marketing_screen.dart';
import 'package:eazotel/features/seo/screen/local_seo_screen.dart';
import 'package:eazotel/features/seo/screen/website_seo_screen.dart';
import 'package:eazotel/features/social_media/screen/social_media_screen.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardDrawer extends StatelessWidget {
  final BottomNavController controller;
  final LocationController locationController;

  const DashboardDrawer({
    super.key,
    required this.controller,
    required this.locationController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    /// Close the menu and open the screen
    void go(Widget Function() page, {Bindings? binding}) {
      Navigator.pop(context);
      Get.to(page, binding: binding);
    }

    return Drawer(
      width: 310,
      backgroundColor: isDark
          ? TAppColors.darkBackground
          : TAppColors.lightBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _Header(
              locationController: locationController,
              onProfile: () {
                Navigator.pop(context);
                controller.changeTab(3);
              },
              onClose: () => Navigator.pop(context),
            ),
            // Menu (scrolls if long)
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    sliver: SliverList.list(
                      children: [
                        const _GroupLabel('Insights'),
                        _Item(
                          icon: Icons.insights_rounded,
                          color: const Color(0xFFF59E0B),
                          title: 'Google Analytics',
                          onTap: () => go(
                            () => const Analytis(),
                            binding: AnalytisBinding(),
                          ),
                        ),
                        _Item(
                          icon: Icons.ads_click_rounded,
                          color: const Color(0xFFEF4444),
                          title: 'Google Ads Insights',
                          onTap: () => go(() => const GoogleAdsScreen()),
                        ),
                        _Item(
                          icon: Icons.facebook,
                          color: const Color(0xFF1877F2),
                          title: 'Meta Insights',
                          onTap: () => go(() => const MetaInsightsScreen()),
                        ),
                        _Group(
                          icon: Icons.query_stats_rounded,
                          color: const Color(0xFF10B981),
                          title: 'SEO',
                          children: [
                            _Item(
                              icon: Icons.map_outlined,
                              color: const Color(0xFF10B981),
                              title: 'Local Seo',
                              small: true,
                              onTap: () => go(() => const LocalSeoScreen()),
                            ),
                            _Item(
                              icon: Icons.travel_explore,
                              color: const Color(0xFF3B82F6),
                              title: 'Website Seo',
                              small: true,
                              onTap: () => go(() => const WebsiteSeoScreen()),
                            ),
                          ],
                        ),
                        const _GroupLabel('Engage'),

                        _Group(
                          icon: Icons.campaign_rounded,
                          color: const Color(0xFFEC4899),
                          title: 'Marketing',
                          children: [
                            _Item(
                              icon: Icons.chat_outlined,
                              color: const Color(0xFF25D366),
                              title: 'WhatsApp Marketing',
                              small: true,
                              onTap: () =>
                                  go(() => const WhatsappMarketingScreen()),
                            ),
                            _Item(
                              icon: Icons.mail_outline,
                              color: const Color(0xFFEA4335),
                              title: 'Email Marketing',
                              small: true,
                              onTap: () =>
                                  go(() => const EmailMarketingScreen()),
                            ),
                          ],
                        ),
                        _Item(
                          icon: Icons.call_rounded,
                          color: const Color(0xFF0EA5E9),
                          title: 'Calls Management',
                          onTap: () => go(() => const CallsManagementScreen()),
                        ),
                        // _Item(
                        //   icon: Icons.share_rounded,
                        //   color: const Color(0xFF6366F1),
                        //   title: 'Social Media',
                        //   onTap: () => go(() => const SocialMediaScreen()),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HEADER
// ============================================================

class _Header extends StatelessWidget {
  const _Header({
    required this.locationController,
    required this.onProfile,
    required this.onClose,
  });

  final LocationController locationController;
  final VoidCallback onProfile;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final dashboard = Get.find<DashboardController>();

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4338CA), TAppColors.primary, Color(0xFF7C3AED)],
        ),
      ),
      child: Obx(() {
        final hotel = locationController.selectedHotel.value;
        final name = hotel?.local.trim() ?? '';
        final initial = name.isEmpty ? '' : name[0].toUpperCase();
        final place = [
          if ((hotel?.city ?? '').isNotEmpty) hotel!.city,
          if ((hotel?.state ?? '').isNotEmpty) hotel!.state,
        ].join(', ');
        final email = dashboard.user.value?.profile.hotelEmail ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .35),
                    ),
                  ),
                  child: initial.isEmpty
                      ? const Icon(Icons.apartment, color: Colors.white)
                      : Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Close',
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              name.isEmpty ? 'Your hotel' : name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (place.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  place,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .8),
                    fontSize: 12.5,
                  ),
                ),
              ),
            if (email.isNotEmpty)
              Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .7),
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 12),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: onProfile,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_rounded,
                        size: 16,
                        color: TAppColors.primary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'View profile',
                        style: TextStyle(
                          color: TAppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
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

// ============================================================
// ITEMS
// ============================================================

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 6),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 1,
          fontWeight: FontWeight.w700,
          color: isDark
              ? TAppColors.darkSecondaryText
              : TAppColors.lightSecondaryText,
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color, this.small = false});

  final IconData icon;
  final Color color;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = small ? 32.0 : 38.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? .22 : .12),
        borderRadius: BorderRadius.circular(small ? 10 : 12),
      ),
      child: Icon(icon, color: color, size: small ? 17 : 20),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
    this.small = false,
  });

  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: small,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: _IconBox(icon: icon, color: color, small: small),
        title: Text(
          title,
          style: TextStyle(
            fontSize: small ? 13.5 : 14.5,
            fontWeight: FontWeight.w600,
            color: isDark ? TAppColors.darkText : TAppColors.lightText,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: isDark
              ? TAppColors.darkSecondaryText
              : TAppColors.lightSecondaryText,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.icon,
    required this.color,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final Color color;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        childrenPadding: const EdgeInsets.only(left: 18),
        leading: _IconBox(icon: icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: isDark ? TAppColors.darkText : TAppColors.lightText,
          ),
        ),
        children: children,
      ),
    );
  }
}
