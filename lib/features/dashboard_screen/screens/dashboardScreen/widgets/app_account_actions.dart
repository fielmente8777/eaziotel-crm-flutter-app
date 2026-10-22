// ============================================================
// APP ACCOUNT ACTIONS  (Profile tab + Drawer dono me same)
//
//   AppThemeSwitch  : [System] [Light] [Dark]
//   AppLogoutButton : "Log out?" pooch kar logout
//   AppVersionText  : "Version 1.2.0 (12)"
//
// Ek hi jagah bane hain, taaki dono screen par ek jaisa kaam kare.
// ============================================================

import 'package:eazotel/features/auth/controllers/login_controller.dart';
import 'package:eazotel/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

// ============================================================
// THEME SWITCH
// ============================================================

class AppThemeSwitch extends StatelessWidget {
  const AppThemeSwitch({super.key, this.height = 52, this.showLabels = true});

  final double height;

  /// false = sirf icon (bahut kam jagah ho tab)
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => Container(
        height: height,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            for (final (mode, title, icon, selected) in [
              (
                ThemeMode.system,
                'System',
                Icons.settings_brightness_outlined,
                themeController.isSystem,
              ),
              (
                ThemeMode.light,
                'Light',
                Icons.light_mode_outlined,
                themeController.isLight,
              ),
              (
                ThemeMode.dark,
                'Dark',
                Icons.dark_mode_outlined,
                themeController.isDark,
              ),
            ])
              Expanded(
                child: _ThemeOption(
                  title: title,
                  icon: icon,
                  selected: selected,
                  showLabel: showLabels,
                  onTap: () => themeController.changeTheme(mode),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.selected,
    required this.showLabel,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurfaceVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: selected ? theme.colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: onTap,
          child: Tooltip(
            message: '$title theme',
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18, color: color),
                  if (showLabel) ...[
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LOGOUT
// ============================================================

class AppLogoutButton extends StatelessWidget {
  const AppLogoutButton({super.key, this.expand = false});

  /// true = poori chaudai
  final bool expand;

  /// Pakka? phir logout. [context] khula rehna chahiye (logout isi se
  /// Login screen kholta hai), isliye drawer pehle band nahi karte.
  static Future<void> confirmAndLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to use the app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (ok != true || !context.mounted) return;

    final login = Get.isRegistered<LoginController>()
        ? Get.find<LoginController>()
        : Get.put(LoginController());

    await login.logoutUser(context);
  }

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () => confirmAndLogout(context),
      icon: const Icon(Icons.logout_rounded, size: 18),
      label: const Text('Logout'),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

// ============================================================
// APP VERSION
// ============================================================

class AppVersionText extends StatelessWidget {
  const AppVersionText({super.key, this.textAlign = TextAlign.center});

  final TextAlign textAlign;

  /// Ek hi baar padhte hain (har screen par dobara nahi)
  static final Future<PackageInfo> _info = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<PackageInfo>(
      future: _info,
      builder: (context, snapshot) {
        final info = snapshot.data;

        return Text(
          info == null ? '' : 'Version ${info.version} (${info.buildNumber})',
          textAlign: textAlign,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        );
      },
    );
  }
}
