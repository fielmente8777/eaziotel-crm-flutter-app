import 'package:eazotel/common/widgets/spacing.dart';
import 'package:eazotel/features/dashboard_screen/controllers/lead_details_filter_controller.dart';
import 'package:eazotel/features/dashboard_screen/models/leads_responce_modle.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/LeadsScreenWidget/LeadsDeatils/leadsDetailsScreen/leads_detail_dropdown_filter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                _showMenu(context, leads);
              },
            ),
          ],
        ),

        const SizedBox(height: 18),

        // ======================================================
        // PROFILE
        // ======================================================
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
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

            // Details
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

                  VSpace(height: 8),

                  // Source + Status
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

// ============================================================
// HEADER BUTTON
// ============================================================

Widget _headerButton({required IconData icon, required VoidCallback onTap}) {
  return Material(
    color: Colors.white.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    ),
  );
}

// ============================================================
// FIRST LETTER
// ============================================================

String _firstLetter(String name) {
  if (name.trim().isEmpty) {
    return 'U';
  }

  return name.trim()[0].toUpperCase();
}

// ============================================================
// MORE MENU
// ============================================================

void _showMenu(BuildContext context, LeadModel leads) {
  final theme = Theme.of(context);

  final isDark = theme.brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (bottomSheetContext) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF202630) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ==================================================
              // HANDLE
              // ==================================================
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF566171)
                      : const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // FILTER
              // ==================================================
              LeadDetailsFilterWidget(leads: leads),

              const SizedBox(height: 16),

              // ==================================================
              // DELETE BUTTON
              // ==================================================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Close bottom sheet
                    Navigator.pop(bottomSheetContext);

                    // Open confirmation
                    _confirmDeleteLead(context, leads);
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  label: const Text(
                    'Delete Lead',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ============================================================
// DELETE CONFIRMATION
// ============================================================

void _confirmDeleteLead(BuildContext context, LeadModel leads) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Delete Lead?'),
        content: const Text(
          'Are you sure you want to delete this lead? '
          'This action cannot be undone.',
        ),
        actions: [
          // ----------------------------------------------------
          // CANCEL
          // ----------------------------------------------------
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade700,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
          ),

          // ----------------------------------------------------
          // DELETE
          // ----------------------------------------------------
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: () async {
                // Close dialog first
                Navigator.pop(dialogContext);

                await _deleteLead(context, leads);
              },
              child: const Text('Delete'),
            ),
          ),
        ],
      );
    },
  );
}

// ============================================================
// DELETE LEAD
// ============================================================

Future<void> _deleteLead(BuildContext context, LeadModel leads) async {
  // ----------------------------------------------------------
  // Get controller safely
  // ----------------------------------------------------------

  final LeadFilterController controller =
      Get.isRegistered<LeadFilterController>()
      ? Get.find<LeadFilterController>()
      : Get.put(LeadFilterController());

  // Set current lead
  controller.setCurrentLead(leads);

  // ----------------------------------------------------------
  // API DELETE
  // ----------------------------------------------------------

  final bool success = await controller.deleteLead(leads);

  // ----------------------------------------------------------
  // SUCCESS
  // ----------------------------------------------------------

  if (success) {
    Get.snackbar(
      'Success',
      'Lead deleted successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );

    // Go back from Lead Details screen
    if (context.mounted) {
      Navigator.pop(context);
    }

    return;
  }

  // ----------------------------------------------------------
  // ERROR
  // ----------------------------------------------------------

  Get.snackbar(
    'Error',
    'Failed to delete lead',
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 2),
  );
}

// ============================================================
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
