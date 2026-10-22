// ============================================================
// SETTING SECTION CARD  (saare tab ke kaam aata hai)
//
//   SettingPalette      : light / dark theme ke rang
//   settingSmallButton  : chhota button (app theme ka button poori width leta hai)
//   SettingSectionCard  : har block ka dabba (icon + title + content)
// ============================================================

import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';

/// Settings ke saare widgets ke liye theme ke rang (light / dark)
class SettingPalette {
  SettingPalette(BuildContext context)
    : theme = Theme.of(context),
      isDark = Theme.of(context).brightness == Brightness.dark;

  final ThemeData theme;
  final bool isDark;

  Color get card => isDark ? TAppColors.darkCard : TAppColors.lightCard;
  Color get inner =>
      isDark ? TAppColors.darkBackground : TAppColors.lightBackground;
  Color get border => isDark ? TAppColors.darkBorder : TAppColors.lightBorder;
  Color get text => isDark ? TAppColors.darkText : TAppColors.lightText;
  Color get subText =>
      isDark ? TAppColors.darkSecondaryText : TAppColors.lightSecondaryText;
  Color get primary => theme.colorScheme.primary;
}

/// App theme ke button poori width lete hain; yahan chhote button chahiye
ButtonStyle settingSmallButton() => ElevatedButton.styleFrom(
  minimumSize: const Size(0, 40),
  padding: const EdgeInsets.symmetric(horizontal: 20),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
);

/// Har block ka dabba: icon + title + subtitle + content
class SettingSectionCard extends StatelessWidget {
  const SettingSectionCard({
    super.key,
    required this.child,
    this.icon,
    this.title,
    this.subtitle,
    this.trailing,
    this.headerAction,
  });

  final Widget child;
  final IconData? icon;
  final String? title;
  final String? subtitle;
  final String? trailing;
  final Widget? headerAction;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: TAppColors.warning),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  fit: headerAction == null ? FlexFit.loose : FlexFit.tight,
                  child: Text(
                    title!,
                    style: TextStyle(
                      color: p.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    trailing!,
                    style: TextStyle(color: p.subText, fontSize: 11),
                  ),
                ],
                if (headerAction != null) ...[
                  const SizedBox(width: 8),
                  headerAction!,
                ],
              ],
            ),
            // if (subtitle != null) ...[
            //   const SizedBox(height: 4),
            //   Text(subtitle!, style: TextStyle(color: p.subText, fontSize: 12)),
            // ],
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}
