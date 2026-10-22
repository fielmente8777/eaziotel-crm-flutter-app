// ============================================================
// SOCIAL MEDIA SCREEN  (Drawer > Social Media)
//
// Same as web: social media work happens on a separate portal (social.eazotel.com).
// Here we show what it offers + a button to open the portal
// (in the browser).
// ============================================================

import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/utils/res/t_responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../setting_screen/screen/widgets/setting_section_card.dart';

class SocialMediaScreen extends StatelessWidget {
  const SocialMediaScreen({super.key});

  static const _features = [
    (
      Icons.calendar_month_rounded,
      'Monthly content calendar',
      'Planned posts, stories and reels for the whole month.',
      Color(0xFF6366F1),
    ),
    (
      Icons.brush_rounded,
      'High-quality graphics & captions',
      'Designed creatives with captions written for your brand.',
      Color(0xFFEC4899),
    ),
    (
      Icons.trending_up_rounded,
      'Engagement & follower growth',
      'Replies, community engagement and growth strategy.',
      Color(0xFF10B981),
    ),
    (
      Icons.insights_rounded,
      'Insights tracking',
      'See how your posts, stories and reels are performing.',
      Color(0xFFF59E0B),
    ),
  ];

  Future<void> _open() async {
    final ok = await launchUrl(
      Uri.parse(SocialMediaLinks.login),
      mode: LaunchMode.externalApplication,
    );
    if (!ok) {
      Get.snackbar(
        'Could not open',
        'Please open ${SocialMediaLinks.portal} in your browser.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Social Media')),
      body: SafeArea(
        child: TResponsiveBuilder(
          builder: (context, r) => SingleChildScrollView(
            padding: EdgeInsets.all(r.pagePadding),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ---------- Hero ----------
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF0EA5E9),
                            Color(0xFF6366F1),
                            Color(0xFFEC4899),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.share_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Social Media Management',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Full-scale social media management including posts, '
                            'stories, reels, engagement and insights tracking.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .9),
                              fontSize: 13.5,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF6366F1),
                              minimumSize: const Size(0, 46),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _open,
                            icon: const Icon(Icons.open_in_new, size: 18),
                            label: const Text(
                              'Open Social Media dashboard',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "What's included",
                      style: TextStyle(
                        color: p.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LayoutBuilder(
                      builder: (context, box) {
                        final cols = r.isPhone ? 1 : 2;
                        const gap = 12.0;
                        final width = (box.maxWidth - gap * (cols - 1)) / cols;

                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: [
                            for (final f in _features)
                              SizedBox(
                                width: width,
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: p.card,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: p.border),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: f.$4.withValues(alpha: .12),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(f.$1, color: f.$4),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              f.$2,
                                              style: TextStyle(
                                                color: p.text,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              f.$3,
                                              style: TextStyle(
                                                color: p.subText,
                                                fontSize: 12.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'You will be taken to ${SocialMediaLinks.portal} to sign in.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: p.subText, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
