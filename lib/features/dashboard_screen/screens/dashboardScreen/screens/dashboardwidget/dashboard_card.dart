import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/dashboardwidget/DashboardStatCard.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class _StatData {
  final String value;
  final String title;
  final String bottomText;
  final IconData icon;
  final Color color;
  final Color? valueColor;
  final double? progress;

  const _StatData({
    required this.value,
    required this.title,
    required this.bottomText,
    required this.icon,
    required this.color,
    this.valueColor,
    this.progress,
  });
}

// ============================================================
// DASHBOARD BODY
// ============================================================
Widget dashboardBody() {
  final DashboardController dashboardController =
      Get.find<DashboardController>();

  return Obx(() {
    final docs = dashboardController.analyticsResponse.value?.result?.docs;

    final totalLeads = docs?.totalLeads?.isNotEmpty == true
        ? (docs!.totalLeads!.first.count ?? 0)
        : 0;

    final convertedLeads = docs?.convertedLeads?.isNotEmpty == true
        ? (docs!.convertedLeads!.first.count ?? 0)
        : 0;

    final convertedRate = totalLeads == 0
        ? 0.0
        : convertedLeads / totalLeads * 100;

    final whatsappConversations = docs?.totalWhatsappConversations ?? 0;
    final todayLeads = docs?.todayLeads ?? 0;

    // Top source (bottom text ke liye)
    final sources = [...?docs?.sourceBreakdown]
      ..sort((a, b) => (b.count ?? 0).compareTo(a.count ?? 0));
    final topSource = sources.isNotEmpty && (sources.first.id ?? '').isNotEmpty
        ? _titleCase(sources.first.id!)
        : null;

    final cards = <_StatData>[
      _StatData(
        value: '$totalLeads',
        title: 'Total Leads',
        bottomText: topSource == null ? 'All time' : 'Top source · $topSource',
        icon: Icons.people_alt_outlined,
        color: const Color(0xFF6366F1),
      ),
      _StatData(
        value: '$convertedLeads',
        title: 'Converted Leads',
        bottomText: totalLeads == 0
            ? 'No leads yet'
            : '$convertedLeads of $totalLeads leads',
        icon: Icons.verified_outlined,
        color: const Color(0xFF10B981),
        progress: totalLeads == 0 ? 0 : convertedLeads / totalLeads,
      ),
      if (whatsappConversations > 0)
        _StatData(
          value: '$whatsappConversations',
          title: 'WhatsApp Chats',
          bottomText: totalLeads == 0
              ? 'Total conversations'
              : '${(whatsappConversations / totalLeads).toStringAsFixed(1)} chats per lead',
          icon: Icons.chat_bubble_outline_rounded,
          color: const Color(0xFF22C55E),
        ),
      _StatData(
        value: '${convertedRate.toStringAsFixed(1)}%',
        title: 'Conversion Rate',
        bottomText: 'Converted ÷ Total',
        icon: Icons.trending_up_rounded,
        color: const Color(0xFFF59E0B),
        progress: convertedRate / 100,
      ),
      _StatData(
        value: '$todayLeads',
        title: "Today's Leads",
        bottomText: todayLeads == 0 ? 'None yet today' : 'Since midnight',
        icon: Icons.bolt_rounded,
        color: const Color(0xFFA855F7),
        valueColor: todayLeads > 0 ? TAppColors.success : null,
      ),
    ];

    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;

        // Phone 2 · Tablet 3 · Desktop sab ek row me
        final cols = w >= 1100
            ? cards.length
            : w >= 700
            ? 3
            : 2;
        final height = w >= 700 ? 168.0 : 156.0;

        return GridView.builder(
          padding: EdgeInsets.all(w >= 700 ? 20 : 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: height,
          ),
          itemBuilder: (context, index) {
            final card = cards[index];

            // Halka staggered entry animation
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 400 + index * 90),
              curve: Curves.easeOutCubic,
              builder: (_, t, child) => Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(0, (1 - t) * 16),
                  child: child,
                ),
              ),
              child: DashboardStatCard(
                value: card.value,
                title: card.title,
                bottomText: card.bottomText,
                icon: card.icon,
                accentColor: card.color,
                iconColor: card.color,
                valueColor: card.valueColor,
                progress: card.progress,
              ),
            );
          },
        );
      },
    );
  });
}

String _titleCase(String s) => s
    .split(RegExp(r'\s+'))
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1))
    .join(' ');
