// ============================================================
// MARKETING COMMON
//
// WhatsApp aur Email dono marketing screen ke chhote widget:
//   StatusPill     : rangeen status (Completed / In-Progress / Read ...)
//   StatTile       : ek ginti wala dabba (Sent 7)
//   PagerBar       : "Page 1 of 2" + Prev / Next
//   MarketingState : loading / error / khali list
//   formatDateTime : "22 Jun 2026, 11:33 AM"
// ============================================================

import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../setting_screen/screen/widgets/setting_section_card.dart';
import '../../models/marketing_models.dart';

String formatDateTime(DateTime? date) =>
    date == null ? '-' : DateFormat('d MMM yyyy, hh:mm a').format(date);

Color statusColor(String status) => switch (status) {
  'completed' || 'sent' || 'delivered' => TAppColors.success,
  'read' || 'opened' => TAppColors.info,
  'failed' => TAppColors.error,
  'in-progress' || 'running' || 'scheduled' || 'pending' => TAppColors.warning,
  _ => TAppColors.lightSecondaryText,
};

/// "in-progress" -> "In Progress"
String statusLabel(String status) => status.isEmpty
    ? '-'
    : status
          .split(RegExp('[-_ ]'))
          .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
          .join(' ');

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.note,
  });

  final String label;
  final int value;
  final Color color;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: p.subText,
              fontSize: 10.5,
              letterSpacing: .5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (note != null)
            Text(note!, style: TextStyle(color: p.subText, fontSize: 11)),
        ],
      ),
    );
  }
}

class PagerBar extends StatelessWidget {
  const PagerBar({
    super.key,
    required this.page,
    required this.shown,
    required this.onPage,
  });

  final MarketingPage page;

  /// Is page par kitni lines dikh rahi hain
  final int shown;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            'Showing $shown of ${page.total}',
            style: TextStyle(color: p.subText, fontSize: 12),
          ),
        ),
        IconButton(
          onPressed: page.hasPrevious ? () => onPage(page.page - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          '${page.page} / ${page.totalPages}',
          style: TextStyle(color: p.text, fontSize: 12.5),
        ),
        IconButton(
          onPressed: page.hasNext ? () => onPage(page.page + 1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

/// Loading / error / khali list ka ek hi widget
class MarketingState extends StatelessWidget {
  const MarketingState({
    super.key,
    required this.icon,
    required this.message,
    this.loading = false,
    this.onRetry,
  });

  final IconData icon;
  final String message;
  final bool loading;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            else
              Icon(icon, size: 42, color: p.subText),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: p.subText, fontSize: 13),
            ),
            if (onRetry != null && !loading) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 38)),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
