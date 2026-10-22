// ============================================================
// CREDITS OVERVIEW  (Credits & Usage > Overview tab)
//
// Top to bottom:
//   1. Heading + refresh + "Add Credits" button
//   2. Three boxes : Available balance | Total loaded | Total used
//   3. Two bars    : Credits used  |  Free service messages
//   4. Usage table : Marketing, Utility, Service + Total
//   5. A note at the bottom
//
// The data comes from controller.billing.
// ============================================================

import 'package:eazotel/utils/res/t_responsive.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../screen/widgets/setting_section_card.dart';
import '../../controller/whatsapp_credits_controller.dart';
import '../../models/whatsapp_billing.dart';
import 'credits_format.dart';

class CreditsOverview extends StatelessWidget {
  const CreditsOverview({super.key, required this.controller, required this.r});

  final WhatsappCreditsController controller;
  final TResponsive r;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final billing = controller.billing.value;
      final isLoading = controller.isBillingLoading.value;
      final error = controller.billingError.value;

      // Data is loading for the first time
      if (billing == null && isLoading) return const _OverviewShimmer();

      // No data came
      if (billing == null) {
        return _OverviewError(
          message: error ?? 'No data found',
          onRetry: controller.loadBilling,
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(controller: controller, isLoading: isLoading),
          const SizedBox(height: 14),
          _WalletTiles(billing: billing, r: r),
          const SizedBox(height: 16),
          _UsageBars(billing: billing, r: r),
          const SizedBox(height: 16),
          _UsageTable(billing: billing, r: r),
          const SizedBox(height: 12),
          const _Note(),
        ],
      );
    });
  }
}

// ============================================================
// 1. HEADING + BUTTONS
// ============================================================

class _Header extends StatelessWidget {
  const _Header({required this.controller, required this.isLoading});

  final WhatsappCreditsController controller;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    // Take the full width: heading on the left, buttons on the right.
    // When space is short (phone), the buttons move down by themselves.
    return SizedBox(width: double.infinity, child: _headerContent(p));
  }

  Widget _headerContent(SettingPalette p) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 10,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 14,
                  color: TAppColors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  'WHATSAPP CREDITS',
                  style: TextStyle(
                    color: p.subText,
                    fontSize: 11,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Wallet & Message Usage',
              style: TextStyle(
                color: p.primary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Refresh
            OutlinedButton(
              onPressed: isLoading ? null : controller.loadBilling,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(40, 40),
                padding: EdgeInsets.zero,
                foregroundColor: p.text,
                side: BorderSide(color: p.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Icon(Icons.refresh, size: 18),
            ),
            const SizedBox(width: 8),

            // Add Credits
            ElevatedButton.icon(
              style: settingSmallButton().copyWith(
                backgroundColor: const WidgetStatePropertyAll(
                  TAppColors.success,
                ),
                foregroundColor: const WidgetStatePropertyAll(Colors.white),
              ),
              onPressed: controller.addCredits,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Credits'),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================
// 2. THREE BOXES (balance, loaded, used)
// ============================================================

class _WalletTiles extends StatelessWidget {
  const _WalletTiles({required this.billing, required this.r});

  final WhatsappBilling billing;
  final TResponsive r;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    Widget tile(String label, double amount, {bool isMain = false}) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: p.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: p.subText, fontSize: 11.5)),
            const SizedBox(height: 6),
            Text(
              formatMoney(amount),
              style: TextStyle(
                // The balance is the biggest and darkest
                color: isMain ? p.text : p.primary,
                fontSize: isMain ? 22 : 17,
                fontWeight: isMain ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final tiles = [
      tile('Available balance', billing.balance, isMain: true),
      tile('Total loaded', billing.totalLoaded),
      tile('Total used', billing.totalUsed),
    ];

    // Phone: stacked. Tablet / window: all three in one row.
    if (r.isPhone) {
      return Column(
        children: [
          tiles[0],
          const SizedBox(height: 10),
          tiles[1],
          const SizedBox(height: 10),
          tiles[2],
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: tiles[0]),
        const SizedBox(width: 12),
        Expanded(child: tiles[1]),
        const SizedBox(width: 12),
        Expanded(child: tiles[2]),
      ],
    );
  }
}

// ============================================================
// 3. TWO BARS (credits used, free service messages)
// ============================================================

class _UsageBars extends StatelessWidget {
  const _UsageBars({required this.billing, required this.r});

  final WhatsappBilling billing;
  final TResponsive r;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    Widget bar({
      required String title,
      required String value,
      required double fraction,
      required Color color,
      required String note,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: p.primary, fontSize: 12.5),
                ),
              ),
              Text(value, style: TextStyle(color: p.subText, fontSize: 12.5)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 7,
              color: color,
              backgroundColor: p.border,
            ),
          ),
          const SizedBox(height: 6),
          Text(note, style: TextStyle(color: p.subText, fontSize: 11.5)),
        ],
      );
    }

    final creditsBar = bar(
      title: 'Credits used',
      value: '${(billing.usedFraction * 100).round()}%',
      fraction: billing.usedFraction,
      color: p.primary,
      note: 'Last recharge: ${formatDate(billing.lastRechargeAt)}',
    );

    final freeBar = bar(
      title: 'Free service messages',
      value:
          '${formatCount(billing.freeUsed)} / ${formatCount(billing.freeLimit)}',
      fraction: billing.freeFraction,
      color: TAppColors.success,
      note: '${formatCount(billing.freeRemaining)} free left this month',
    );

    if (r.isPhone) {
      return Column(
        children: [creditsBar, const SizedBox(height: 14), freeBar],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: creditsBar),
        const SizedBox(width: 16),
        Expanded(child: freeBar),
      ],
    );
  }
}

// ============================================================
// 4. USAGE TABLE
// ============================================================

class _UsageTable extends StatelessWidget {
  const _UsageTable({required this.billing, required this.r});

  final WhatsappBilling billing;
  final TResponsive r;

  /// Colored dot in front of each type
  Color _dotColor(String type) {
    switch (type) {
      case 'Marketing':
        return const Color(0xFFA855F7);
      case 'Utility':
        return TAppColors.info;
      case 'Authentication':
        return TAppColors.warning;
      default:
        return TAppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    // Narrow columns on phones, wide on big screens
    final double numberWidth = r.isPhone ? 64 : 110;

    Widget headerText(String text, {bool right = true}) {
      return Text(
        text,
        textAlign: right ? TextAlign.right : TextAlign.left,
        style: TextStyle(color: p.subText, fontSize: 10.5, letterSpacing: 0.3),
      );
    }

    /// One table line: [first] on the left, the other three on the right (fixed widths)
    Widget line({
      required Widget first,
      required Widget messages,
      required Widget rate,
      required Widget cost,
      Color? background,
      bool topBorder = true,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: background,
          border: topBorder ? Border(top: BorderSide(color: p.border)) : null,
        ),
        child: Row(
          children: [
            Expanded(child: first),
            SizedBox(width: numberWidth, child: messages),
            SizedBox(width: numberWidth, child: rate),
            SizedBox(width: numberWidth, child: cost),
          ],
        ),
      );
    }

    Widget number(String text, {bool bold = false, bool faded = false}) {
      return Text(
        text,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: faded ? p.subText : p.text,
          fontSize: 13,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        ),
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.border),
      ),
      child: Column(
        children: [
          // ---------- "Usage this month" + mahina ----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Usage this month',
                    style: TextStyle(color: p.primary, fontSize: 13.5),
                  ),
                ),
                Text(
                  billing.cycleLabel,
                  style: TextStyle(color: p.subText, fontSize: 11.5),
                ),
              ],
            ),
          ),

          // ---------- Column names ----------
          line(
            first: headerText('TYPE', right: false),
            messages: headerText('MESSAGES'),
            rate: headerText('RATE'),
            cost: headerText('COST'),
          ),

          // ---------- A line for each type ----------
          for (final row in billing.usage)
            line(
              first: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5, right: 8),
                    child: CircleAvatar(
                      radius: 3.5,
                      backgroundColor: _dotColor(row.type),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.type,
                          style: TextStyle(color: p.primary, fontSize: 13.5),
                        ),
                        Text(
                          row.note,
                          style: TextStyle(color: p.subText, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              messages: number(formatCount(row.messages)),
              rate: number(formatRate(row.rate), faded: true),
              cost: number(formatMoney(row.cost), bold: true),
            ),

          // ---------- Total ----------
          line(
            background: p.inner,
            first: Text(
              'Total',
              style: TextStyle(color: p.primary, fontSize: 13.5),
            ),
            messages: number(formatCount(billing.totalMessages), bold: true),
            rate: const SizedBox.shrink(),
            cost: number(formatMoney(billing.totalCost), bold: true),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 5. NOTE
// ============================================================

class _Note extends StatelessWidget {
  const _Note();

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1, right: 6),
          child: Icon(Icons.info_outline, size: 14, color: p.subText),
        ),
        Expanded(
          child: Text(
            'From 1 Oct 2026, utility messages inside the 24-hour window are '
            'charged and are not covered by the 1,000 free service messages. '
            'Rates shown are for Indian numbers.',
            style: TextStyle(color: p.primary, fontSize: 11.5, height: 1.4),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// LOADING + ERROR
// ============================================================

class _OverviewShimmer extends StatelessWidget {
  const _OverviewShimmer();

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    Widget block(double height) => Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Shimmer.fromColors(
      baseColor: p.border,
      highlightColor: Color.lerp(
        p.border,
        Colors.white,
        p.isDark ? 0.12 : 0.7,
      )!,
      child: Column(children: [block(44), block(80), block(50), block(220)]),
    );
  }
}

class _OverviewError extends StatelessWidget {
  const _OverviewError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 40, color: p.subText),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: p.text, fontSize: 13.5),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
