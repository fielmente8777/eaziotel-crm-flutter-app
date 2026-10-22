// ============================================================
// INTEGRATION CARDS
//
//   IntegrationCard    : one integration (icon, name, meaning, Connect / Disconnect)
//   SearchConsoleCard  : Google Search Console status
// ============================================================

import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../models/gsc_settings.dart';
import '../../models/integration_item.dart';

class IntegrationCard extends StatelessWidget {
  const IntegrationCard({
    super.key,
    required this.item,
    required this.onTap,
    this.busy = false,
  });

  final IntegrationItem item;
  final VoidCallback onTap;

  /// Google login is opening -> "Opening..."
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return _Box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Logo(icon: item.icon, color: item.color),
              const Spacer(),
              if (item.connected) const _ConnectedBadge(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: TextStyle(
              color: p.text,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.description,
            style: TextStyle(color: p.subText, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: item.connected
                ? OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      foregroundColor: p.text,
                      side: BorderSide(color: p.border),
                    ),
                    child: const Text('Disconnect'),
                  )
                : ElevatedButton(
                    onPressed: busy ? null : onTap,
                    style: settingSmallButton(),
                    child: Text(busy ? 'Opening...' : 'Connect'),
                  ),
          ),
        ],
      ),
    );
  }
}

class SearchConsoleCard extends StatelessWidget {
  const SearchConsoleCard({
    super.key,
    required this.settings,
    required this.gaConnected,
    required this.onEdit,
  });

  final GscSettings settings;

  /// Search Console cannot be set if GA is not connected
  final bool gaConnected;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final connected = settings.configured;

    final subtitle = !gaConnected
        ? 'Connect Google Analytics first'
        : connected
        ? settings.rawDomain
        : 'Add your website domain';

    return _Box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Logo(
                icon: connected ? Icons.check_circle_outline : Icons.search,
                color: connected ? TAppColors.success : p.subText,
              ),
              const Spacer(),
              if (connected) const _ConnectedBadge(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Search Console',
            style: TextStyle(
              color: p.text,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: p.subText, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: connected
                ? OutlinedButton.icon(
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      foregroundColor: p.text,
                      side: BorderSide(color: p.border),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Settings'),
                  )
                : ElevatedButton(
                    onPressed: onEdit,
                    style: settingSmallButton(),
                    child: const Text('Set Up'),
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SMALL PARTS
// ============================================================

class _Box extends StatelessWidget {
  const _Box({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: child,
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _ConnectedBadge extends StatelessWidget {
  const _ConnectedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: TAppColors.success),
      ),
      child: const Text(
        'Connected',
        style: TextStyle(
          color: TAppColors.success,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
