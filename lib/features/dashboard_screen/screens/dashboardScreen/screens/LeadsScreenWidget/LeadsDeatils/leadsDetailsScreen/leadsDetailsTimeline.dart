import 'package:flutter/material.dart';

// ============================================================
// TIMELINE CONTENT
// ============================================================

class leadDetailsTimelineScreen extends StatelessWidget {
  final BuildContext context;

  const leadDetailsTimelineScreen(this.context, {super.key});

  @override
  Widget build(BuildContext buildContext) {
    return Column(
      children: [
        _timelineItem(
          context,
          icon: Icons.check_circle,
          title: 'Lead created via Meta Ads',
          time: 'Today, 10:45 AM',
        ),

        _timelineItem(
          context,
          icon: Icons.email,
          title: 'Email sent',
          time: 'Today, 11:02 AM',
          message: 'Welcome email with hotel brochure sent.',
        ),

        _timelineItem(
          context,
          icon: Icons.phone,
          title: 'Phone call — 4 min 12 sec',
          time: 'Today, 2:30 PM',
          message: 'Interested in Deluxe Room. Will confirm by evening.',
        ),

        const SizedBox(height: 8),

        // ======================================================
        // MARK AS CONVERTED
        // ======================================================
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.check_circle_outline, size: 17),
            label: const Text(
              'Mark as Converted',
              style: TextStyle(fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _timelineItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String time,
    String? message,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  time,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),

                if (message != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
