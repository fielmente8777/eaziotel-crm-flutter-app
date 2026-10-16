import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:eazotel/features/leads/models/leads_responce_modle.dart';
import 'package:flutter/material.dart';

class LeadDetailsTimelineScreen extends StatelessWidget {
  final LeadModel lead;

  const LeadDetailsTimelineScreen({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // =========================
    // LEAD CREATED DATA
    // =========================

    final createdFrom = (lead.createdFrom ?? '').toString().trim();

    final createdDate = _parseDate(lead.createdAtDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==================================================
        // 1. LEAD CREATED CARD
        // ==================================================
        _leadCreatedCard(
          context: context,
          theme: theme,
          isDark: isDark,
          createdFrom: createdFrom,
          createdDate: createdDate,
        ),

        // ==================================================
        // 2. NOTES CARDS
        // ==================================================
        if (lead.notes != null && lead.notes!.isNotEmpty) ...[
          const SizedBox(height: 12),

          ...lead.notes!.map(
            (note) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _noteAddedCard(
                context: context,
                theme: theme,
                isDark: isDark,
                note: note,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ==========================================================
  // LEAD CREATED CARD
  // ==========================================================

  Widget _leadCreatedCard({
    required BuildContext context,
    required ThemeData theme,
    required bool isDark,
    required String createdFrom,
    required DateTime? createdDate,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? TAppColors.darkCard : TAppColors.lightCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? TAppColors.darkBorder : TAppColors.lightBorder,
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Text('✨', style: TextStyle(fontSize: 28)),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lead created via ${_formatSource(createdFrom)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  _formatDateTime(createdDate),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? const Color(0xFF9EABC0)
                        : const Color(0xFF9AAAC0),
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  'Lead entered CRM successfully.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? const Color(0xFFE1E6EE)
                        : const Color(0xFF293241),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // NOTE ADDED CARD
  // ==========================================================

  Widget _noteAddedCard({
    required BuildContext context,
    required ThemeData theme,
    required bool isDark,
    required dynamic note,
  }) {
    final message = note.message?.toString().trim() ?? '';

    final createdDate = _parseDate(note.createdAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? TAppColors.darkCard : TAppColors.lightCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? TAppColors.darkBorder : TAppColors.lightBorder,
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Text('📝', style: TextStyle(fontSize: 28)),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Note Added',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  _formatDateTime(createdDate),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? const Color(0xFF9EABC0)
                        : const Color(0xFF9AAAC0),
                  ),
                ),

                if (message.isNotEmpty) ...[
                  const SizedBox(height: 18),

                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFFE1E6EE)
                          : const Color(0xFF293241),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PARSE DATE
  // ==========================================================

  DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    final valueString = value.toString().trim();

    if (valueString.isEmpty) {
      return null;
    }

    return DateTime.tryParse(valueString);
  }

  // ==========================================================
  // FORMAT SOURCE
  // ==========================================================

  String _formatSource(String source) {
    if (source.isEmpty) {
      return 'Website';
    }

    return source
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          if (word.isEmpty) {
            return word;
          }

          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  // ==========================================================
  // FORMAT DATE TIME
  // ==========================================================

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Date not available';
    }

    final date = dateTime.toLocal();

    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');

    final second = date.second.toString().padLeft(2, '0');

    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.month}/${date.day}/${date.year}, '
        '$hour:$minute:$second $period';
  }
}
