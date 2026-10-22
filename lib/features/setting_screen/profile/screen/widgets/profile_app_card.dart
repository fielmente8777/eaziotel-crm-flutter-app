// ============================================================
// APPEARANCE + ACCOUNT  (Settings > Profile ke sabse neeche)
//
//   APPEARANCE
//   ┌──────┐ ┌──────┐ ┌──────┐     har dabba us theme ka chhota
//   │ ◐    │ │ ☀    │ │ ☾    │     preview dikhata hai (phone ki
//   │System│ │Light │ │Dark  │     Settings jaisa)
//   └──────┘ └──────┘ └──────┘
//
//   ACCOUNT
//   ⎋ Log out                  ›   ("Log out?" pooch kar)
//
//          Eazotel · Version 1.4.0 (23)
// ============================================================

import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/widgets/app_account_actions.dart';
import 'package:eazotel/theme_controller.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../screen/widgets/setting_section_card.dart';

// ============================================================
// APPEARANCE
// ============================================================

class SettingAppearanceCard extends StatelessWidget {
  const SettingAppearanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<ThemeController>();

    return SettingSectionCard(
      icon: Icons.palette_outlined,
      title: 'Appearance',
      subtitle: 'Choose how Eazotel looks on this device.',
      child: Obx(() {
        final options = [
          (
            ThemeMode.system,
            'System',
            Icons.brightness_auto_rounded,
            theme.isSystem,
          ),
          (ThemeMode.light, 'Light', Icons.light_mode_rounded, theme.isLight),
          (ThemeMode.dark, 'Dark', Icons.dark_mode_rounded, theme.isDark),
        ];

        return Row(
          children: [
            for (var i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: _ThemeChoice(
                  mode: options[i].$1,
                  label: options[i].$2,
                  icon: options[i].$3,
                  selected: options[i].$4,
                  onTap: () => theme.changeTheme(options[i].$1),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}

/// Ek theme: upar chhota preview, neeche icon + naam
class _ThemeChoice extends StatelessWidget {
  const _ThemeChoice({
    required this.mode,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final ThemeMode mode;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Semantics(
      selected: selected,
      button: true,
      label: '$label theme',
      child: Material(
        color: p.inner,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? TAppColors.primary : p.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                AspectRatio(aspectRatio: 1.25, child: _Preview(mode: mode)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      selected ? Icons.check_circle_rounded : icon,
                      size: 16,
                      color: selected ? TAppColors.primary : p.subText,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected ? TAppColors.primary : p.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Theme ka mini screen: System = aadha light, aadha dark
class _Preview extends StatelessWidget {
  const _Preview({required this.mode});

  final ThemeMode mode;

  Widget _screen(bool dark) {
    final bg = dark ? TAppColors.darkBackground : TAppColors.lightBackground;
    final card = dark ? TAppColors.darkCard : TAppColors.lightCard;
    final line = dark ? TAppColors.darkBorder : TAppColors.lightBorder;

    Widget bar(double widthFactor, Color color, {double height = 5}) =>
        FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: widthFactor,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );

    return Container(
      color: bg,
      padding:  EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bar(1, TAppColors.primary, height: 12),
          const SizedBox(height: 5),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [bar(.7, line), bar(.9, line), bar(.5, line)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: switch (mode) {
        ThemeMode.light => _screen(false),
        ThemeMode.dark => _screen(true),
        ThemeMode.system => Row(
          children: [
            Expanded(child: _screen(false)),
            Expanded(child: _screen(true)),
          ],
        ),
      },
    );
  }
}

// ============================================================
// ACCOUNT (Log out + version)
// ============================================================

class SettingAccountCard extends StatelessWidget {
  const SettingAccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingSectionCard(
          icon: Icons.manage_accounts_outlined,
          title: 'Account',
          child: Material(
            color: TAppColors.error.withValues(alpha: p.isDark ? .14 : .08),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => AppLogoutButton.confirmAndLogout(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      size: 20,
                      color: TAppColors.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Log out',
                            style: TextStyle(
                              color: TAppColors.error,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Sign out of this device',
                            style: TextStyle(color: p.subText, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: TAppColors.error,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Eazotel  ·  ',
              style: TextStyle(
                color: p.subText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const AppVersionText(),
          ],
        ),
      ],
    );
  }
}
