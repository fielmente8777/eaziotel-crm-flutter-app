// ============================================================
// CREDITS TRANSACTIONS  (Credits & Usage > Transactions tab)
//
// Recharge ki list:
//   - Tablet / window : table  (Date | Payment ID | Order ID | Status | Amount)
//   - Phone           : card
// Neeche "Showing 1–4 of 4" aur Prev / Next button.
//
// Data controller.transactions se aata hai.
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

class CreditsTransactions extends StatelessWidget {
  const CreditsTransactions({
    super.key,
    required this.controller,
    required this.r,
  });

  final WhatsappCreditsController controller;
  final TResponsive r;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Obx(() {
      final page = controller.transactions.value;
      final isLoading = controller.isTransactionsLoading.value;
      final error = controller.transactionsError.value;

      if (isLoading) return const _TransactionsShimmer();

      if (error != null) {
        return _Message(
          text: error,
          onRetry: () => controller.loadTransactions(page: page.page),
        );
      }

      if (page.items.isEmpty) {
        return const _Message(text: 'No transactions yet');
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- List ----------
          if (r.isPhone)
            for (final item in page.items) _TransactionTile(item: item)
          else
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: p.border),
              ),
              child: Column(
                children: [
                  const _TransactionHeaderRow(),
                  for (final item in page.items) _TransactionRow(item: item),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // ---------- Showing + Prev / Next ----------
          // Poori chaudai: "Showing" baaye, buttons daaye
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Text(
                  controller.showingLabel,
                  style: TextStyle(color: p.subText, fontSize: 12.5),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PageButton(
                      label: 'Prev',
                      icon: Icons.chevron_left,
                      iconFirst: true,
                      onTap: controller.hasPreviousPage
                          ? controller.previousPage
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Page ${page.page} of ${page.totalPages}',
                        style: TextStyle(color: p.text, fontSize: 12.5),
                      ),
                    ),
                    _PageButton(
                      label: 'Next',
                      icon: Icons.chevron_right,
                      iconFirst: false,
                      onTap: controller.hasNextPage
                          ? controller.nextPage
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

// ============================================================
// TABLE (tablet / window)
// ============================================================

/// Table ke column ki chaudai. Heading aur har line me yahi use hoti hai.
const int _dateFlex = 5;
const int _idFlex = 4;
const double _statusWidth = 90;
const double _amountWidth = 110;

class _TransactionHeaderRow extends StatelessWidget {
  const _TransactionHeaderRow();

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    final style = TextStyle(
      color: p.subText,
      fontSize: 10.5,
      letterSpacing: 0.3,
    );

    return Container(
      color: p.inner,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: _dateFlex,
            child: Text('DATE', style: style),
          ),
          Expanded(
            flex: _idFlex,
            child: Text('PAYMENT ID', style: style),
          ),
          Expanded(
            flex: _idFlex,
            child: Text('ORDER ID', style: style),
          ),
          SizedBox(
            width: _statusWidth,
            child: Text('STATUS', style: style),
          ),
          SizedBox(
            width: _amountWidth,
            child: Text('AMOUNT', textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.item});

  final WhatsappTransaction item;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    Widget id(String text, Color color) {
      return SelectableText(
        text,
        maxLines: 1,
        style: TextStyle(color: color, fontSize: 12, fontFamily: 'monospace'),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: _dateFlex,
            child: Text(
              formatDateTime(item.date),
              style: TextStyle(color: p.primary, fontSize: 13),
            ),
          ),
          Expanded(flex: _idFlex, child: id(item.paymentId, p.primary)),
          Expanded(flex: _idFlex, child: id(item.orderId, p.text)),
          SizedBox(
            width: _statusWidth,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusPill(item: item),
            ),
          ),
          SizedBox(
            width: _amountWidth,
            child: _Amount(item: item),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CARD (phone)
// ============================================================

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.item});

  final WhatsappTransaction item;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    Widget idLine(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$label  ',
                style: TextStyle(color: p.subText),
              ),
              TextSpan(
                text: value,
                style: TextStyle(color: p.text, fontFamily: 'monospace'),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11.5),
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.inner,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatDateTime(item.date),
                  style: TextStyle(color: p.primary, fontSize: 13),
                ),
              ),
              _Amount(item: item),
            ],
          ),
          const SizedBox(height: 6),
          _StatusPill(item: item),
          const SizedBox(height: 4),
          idLine('Payment', item.paymentId),
          idLine('Order', item.orderId),
        ],
      ),
    );
  }
}

// ============================================================
// CHHOTE HISSE
// ============================================================

/// "Paid" ka hara pill (baaki status peele)
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.item});

  final WhatsappTransaction item;

  @override
  Widget build(BuildContext context) {
    final color = item.isPaid ? TAppColors.success : TAppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        item.statusLabel,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// "+₹20.00" (paid ho to hara)
class _Amount extends StatelessWidget {
  const _Amount({required this.item});

  final WhatsappTransaction item;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Text(
      '+${formatMoney(item.amount)}',
      textAlign: TextAlign.right,
      style: TextStyle(
        color: item.isPaid ? TAppColors.success : p.subText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Prev / Next button. [onTap] null ho to button band (grey) rehta hai.
class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.label,
    required this.icon,
    required this.iconFirst,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool iconFirst;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    final iconWidget = Icon(icon, size: 16);
    final text = Text(label, style: const TextStyle(fontSize: 12.5));

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        foregroundColor: p.text,
        side: BorderSide(color: p.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: iconFirst ? [iconWidget, text] : [text, iconWidget],
      ),
    );
  }
}

class _TransactionsShimmer extends StatelessWidget {
  const _TransactionsShimmer();

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Shimmer.fromColors(
      baseColor: p.border,
      highlightColor: Color.lerp(
        p.border,
        Colors.white,
        p.isDark ? 0.12 : 0.7,
      )!,
      child: Column(
        children: [
          for (var i = 0; i < 4; i++)
            Container(
              height: 46,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
        ],
      ),
    );
  }
}

/// Khali list ya error ke liye. [onRetry] diya ho to Retry button dikhta hai.
class _Message extends StatelessWidget {
  const _Message({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 40, color: p.subText),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: p.text, fontSize: 13.5),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
