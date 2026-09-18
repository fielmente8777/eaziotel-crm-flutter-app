import 'package:eazotel/common/widgets/spacing.dart';
import 'package:eazotel/features/dashboard_screen/models/leads_responce_modle.dart';
import 'package:flutter/material.dart';

Container leads_detail_header(
  BuildContext context,
  String name,
  ThemeData theme,
  String status,
  String estimatedValue,
  LeadModel leads,
) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(15, 10, 15, 18),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF3730A3), Color(0xFF1E1B4B)],
      ),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
    ),
    child: Column(
      children: [
        // ======================================================
        // TOP BUTTONS
        // ======================================================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _headerButton(
              icon: Icons.arrow_back,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _headerButton(
              icon: Icons.more_vert,
              onTap: () {
                _showMenu(context);
              },
            ),
          ],
        ),

        const SizedBox(height: 18),

        // ======================================================
        // PROFILE
        // ======================================================
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
              ),
              alignment: Alignment.center,
              child: Text(
                _firstLetter(name),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // ======================================================
                  // SOURCE + STATUS
                  // ======================================================
                  VSpace(height: 8),
                  Row(
                    children: [
                      _headerChip(
                        context,
                        _getSource(leads),
                        backgroundColor: Colors.white,
                        textColor: Colors.white,
                      ),

                      const SizedBox(width: 8),

                      _headerChip(
                        context,
                        status,
                        backgroundColor: const Color(0xFFFBBF24),
                        textColor: const Color(0xFFFBBF24),
                      ),
                    ],
                  ),

                  VSpace(height: 8),

                  Text(
                    estimatedValue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.80),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 13),
      ],
    ),
  );
}

Widget _headerButton({required IconData icon, required VoidCallback onTap}) {
  return Material(
    color: Colors.white.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    ),
  );
}

String _firstLetter(String name) {
  if (name.trim().isEmpty) {
    return 'U';
  }

  return name.trim()[0].toUpperCase();
}

// ============================================================
// MORE MENU
// ============================================================

void _showMenu(BuildContext context) {
  final theme = Theme.of(context);

  showModalBottomSheet(
    context: context,
    backgroundColor: theme.scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Lead'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete Lead'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}

// HEADER CHIP
// ============================================================

Widget _headerChip(
  BuildContext context,
  String text, {
  Color backgroundColor = const Color(0xFFFFFFFF),
  Color textColor = Colors.white,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
    decoration: BoxDecoration(
      color: backgroundColor.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: textColor,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

// ============================================================
// SOURCE
// ============================================================

String _getSource(dynamic leads) {
  final source = leads.createdFrom?.trim();

  if (source != null && source.isNotEmpty) {
    return source;
  }

  return '';
}
