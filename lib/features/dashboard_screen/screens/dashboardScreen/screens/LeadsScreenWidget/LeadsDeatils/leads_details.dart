import 'package:eazotel/common/widgets/spacing.dart';
import 'package:eazotel/features/dashboard_screen/models/leads_responce_modle.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LeadsDetails extends StatelessWidget {
  final LeadModel leads;

  const LeadsDetails({super.key, required this.leads});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final name = leads.name?.trim().isNotEmpty == true
        ? leads.name!.trim()
        : 'Unknown';

    final phone = leads.contact?.trim() ?? '';
    final estimatedValue = ' ₹ estimated value';

    final status = leads.status?.trim().isNotEmpty == true
        ? leads.status!.trim()
        : 'Open Queries';

    // ============================================================
    // STATUS BAR
    // ============================================================

    const headerTopColor = Color(0xFF3730A3);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: headerTopColor,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ============================================================
                // HEADER
                // ============================================================
                Container(
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
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.30),
                              ),
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
                                      _getSource(),
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
                ),

                // ============================================================
                // BODY
                // ============================================================
                Container(
                  width: double.infinity,
                  color: theme.scaffoldBackgroundColor,
                  padding: const EdgeInsets.fromLTRB(15, 12, 15, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ======================================================
                      // ACTION BUTTONS
                      // ======================================================
                      Row(
                        children: [
                          Expanded(
                            child: _actionButton(
                              context,
                              title: 'Call Now',
                              icon: Icons.call,
                              iconColor: TAppColors.success,
                              onTap: () {},
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: _actionButton(
                              context,
                              title: 'WhatsApp',
                              icon: Icons.chat,
                              iconColor: isDark
                                  ? TAppColors.whatsappDark
                                  : TAppColors.whatsappLight,
                              onTap: () {},
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: _actionButton(
                              context,
                              title: 'Convert',
                              icon: Icons.check_circle_outline,
                              iconColor: theme.colorScheme.primary,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ======================================================
                      // LEAD INFORMATION
                      // ======================================================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _infoRow(
                              context,
                              icon: Icons.email_outlined,
                              title: 'EMAIL',
                              value: leads.email ?? '-',
                            ),

                            _divider(context),

                            _infoRow(
                              context,
                              icon: Icons.phone_outlined,
                              title: 'PHONE',
                              value: phone.isEmpty ? '-' : phone,
                            ),

                            _divider(context),

                            _infoRow(
                              context,
                              icon: Icons.calendar_today_outlined,
                              title: 'CHECK-IN / CHECK-OUT',
                              value: _checkInOut(),
                            ),

                            _divider(context),

                            _infoRow(
                              context,
                              icon: Icons.star_border,
                              title: 'ROOM PREFERENCE',
                              value: 'Deluxe Room · 2 guests',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ======================================================
                      // LEAD AGE
                      // ======================================================
                      Text(
                        'Lead Age: ${_getLeadAge()}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ======================================================
                      // TABS
                      // ======================================================
                      Row(
                        children: [
                          Expanded(
                            child: _tabItem(
                              context,
                              'Overview',
                              selected: true,
                            ),
                          ),
                          Expanded(child: _tabItem(context, 'Notes')),
                          Expanded(child: _tabItem(context, 'Timeline')),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ======================================================
                      // TIMELINE
                      // ======================================================
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
                        message:
                            'Interested in Deluxe Room. Will confirm by evening.',
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
                          icon: const Icon(
                            Icons.check_circle_outline,
                            size: 17,
                          ),
                          label: const Text(
                            'Mark as Converted',
                            style: TextStyle(fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
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
  // ACTION BUTTON
  // ============================================================

  Widget _actionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 62,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 19),
              const SizedBox(height: 5),
              Text(
                title,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 14, color: theme.colorScheme.primary),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.80,
                    ),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                    color: isDark ? Colors.white : TAppColors.lightText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _divider(BuildContext context) {
    return Divider(height: 1, color: Theme.of(context).dividerTheme.color);
  }

  // ============================================================
  // TAB
  // ============================================================

  Widget _tabItem(BuildContext context, String title, {bool selected = false}) {
    final theme = Theme.of(context);

    return Container(
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: selected ? theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 12,
          color: selected
              ? theme.colorScheme.primary
              : theme.textTheme.bodySmall?.color,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  // ============================================================
  // TIMELINE
  // ============================================================

  Widget _timelineItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String time,
    String? message,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 12, color: theme.colorScheme.primary),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.55,
                    ),
                  ),
                ),

                if (message != null) ...[
                  const SizedBox(height: 7),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message,
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
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
  // SOURCE
  // ============================================================

  String _getSource() {
    final source = leads.createdFrom?.trim();

    if (source != null && source.isNotEmpty) {
      return source;
    }

    return 'Webform';
  }

  // ============================================================
  // CHECK IN / CHECK OUT
  // ============================================================

  String _checkInOut() {
    final checkIn = leads.checkIn?.trim() ?? '';
    final checkOut = leads.checkOut?.trim() ?? '';

    if (checkIn.isEmpty && checkOut.isEmpty) {
      return '-';
    }

    if (checkIn.isEmpty) {
      return checkOut;
    }

    if (checkOut.isEmpty) {
      return checkIn;
    }

    return '$checkIn → $checkOut';
  }

  // ============================================================
  // LEAD AGE
  // ============================================================

  String _getLeadAge() {
    try {
      final createdAt = leads.createdAt;

      if (createdAt == null) {
        return 'Unknown';
      }

      final date = DateTime.tryParse(createdAt.toString());

      if (date == null) {
        return 'Unknown';
      }

      final now = DateTime.now();

      final difference = now.difference(date).inDays;

      if (difference <= 0) {
        return 'Today';
      }

      if (difference == 1) {
        return '1d ago';
      }

      return '${difference}d ago';
    } catch (_) {
      return 'Unknown';
    }
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
}
 