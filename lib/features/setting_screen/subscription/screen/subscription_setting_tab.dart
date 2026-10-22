// ============================================================
// SETTINGS > SUBSCRIPTION TAB  (responsive)
//
//   Hero (plan, price, ACTIVE, days left)
//   4 cards (start, end, auto renew, support)
//   Apps
//   Upgrade plan / Manage billing
//   Payment information  (wide = table, phone = cards)
// ============================================================

import 'dart:math' as math;

import 'package:eazotel/features/setting_screen/screen/widgets/setting_section_card.dart';
import 'package:eazotel/features/setting_screen/subscription/model/subscription_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/subscription_controller.dart';

const Color _kAccent = Color(0xFFFF6A13); // orange (Upgrade / days left)
const Color _kGreen = Color(0xFF22C55E);

class SubscriptionSettingTab extends StatelessWidget {
  const SubscriptionSettingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(SubscriptionController());
    final p = SettingPalette(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        return SingleChildScrollView(
          padding: EdgeInsets.all(w < 640 ? 12 : 16),
          child: Obx(() {
            // ---------- Loading ----------
            if (c.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // ---------- Error ----------
            final error = c.errorMessage.value;

            if (error != null) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Text(error, style: TextStyle(color: p.subText)),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: c.load,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final sub = c.subscription;

            if (sub == null) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'No active subscription',
                    style: TextStyle(color: p.subText),
                  ),
                ),
              );
            }

            // ---------- Content ----------
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Hero(sub: sub, width: w),
                const SizedBox(height: 16),
                _InfoCards(sub: sub, width: w),
                const SizedBox(height: 24),
                _AppsSection(apps: sub.apps, width: w),
                const SizedBox(height: 20),
                _ActionButtons(controller: c, width: w),
                const SizedBox(height: 28),
                _PaymentSection(controller: c, width: w),
              ],
            );
          }),
        );
      },
    );
  }
}

// ============================================================
// HERO
// ============================================================

class _Hero extends StatelessWidget {
  const _Hero({required this.sub, required this.width});

  final SubscriptionModel sub;
  final double width;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final isPhone = width < 640;

    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 16, color: p.subText),
            const SizedBox(width: 6),
            Text(
              'Your subscription',
              style: TextStyle(fontSize: 13, color: p.subText),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          sub.plan.name.isEmpty ? '-' : sub.plan.name,
          style: TextStyle(
            fontSize: isPhone ? 32 : 44,
            fontWeight: FontWeight.w800,
            color: p.text,
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '₹${_money(sub.plan.price)}',
                style: TextStyle(
                  fontSize: isPhone ? 24 : 30,
                  fontWeight: FontWeight.w700,
                  color: p.text,
                ),
              ),
              TextSpan(
                text: ' / month',
                style: TextStyle(fontSize: 14, color: p.subText),
              ),
            ],
          ),
        ),
      ],
    );

    final chips = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _Pill(
          label: sub.status.toUpperCase(),
          color: sub.isActive ? _kGreen : Colors.redAccent,
          dot: true,
        ),
        _Pill(
          label: '${sub.daysLeft} days left',
          color: _kAccent,
          filled: true,
          icon: Icons.workspace_premium_outlined,
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isPhone ? 16 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
        gradient: LinearGradient(
          colors: [p.primary.withOpacity(0.05), p.primary.withOpacity(0.16)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: isPhone
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [left, const SizedBox(height: 16), chips],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: left),
                chips,
              ],
            ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.color,
    this.filled = false,
    this.dot = false,
    this.icon,
  });

  final String label;
  final Color color;
  final bool filled;
  final bool dot;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: filled ? color : color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
          ],
          if (icon != null) ...[
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 4 INFO CARDS
// ============================================================

class _InfoCards extends StatelessWidget {
  const _InfoCards({required this.sub, required this.width});

  final SubscriptionModel sub;
  final double width;

  @override
  Widget build(BuildContext context) {
    final columns = width >= 900 ? 4 : 2;
    const gap = 12.0;
    final itemWidth =
        (width - (width < 640 ? 24 : 32) - gap * (columns - 1)) / columns;

    final items = [
      (Icons.calendar_month_outlined, 'Start date', _date(sub.startDate)),
      (Icons.event_outlined, 'End date', _date(sub.endDate)),
      (Icons.autorenew, 'Auto renew', sub.autoRenew ? 'Enabled' : 'Disabled'),
      (Icons.headset_mic_outlined, 'Support', _capitalize(sub.plan.support)),
    ];

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        for (final item in items)
          SizedBox(
            width: itemWidth,
            child: _InfoCard(icon: item.$1, title: item.$2, value: item.$3),
          ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _kAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: _kAccent),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: p.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, color: p.subText)),
        ],
      ),
    );
  }
}

// ============================================================
// APPS
// ============================================================

class _AppsSection extends StatelessWidget {
  const _AppsSection({required this.apps, required this.width});

  final List<SubscriptionAppModel> apps;
  final double width;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    if (apps.isEmpty) return const SizedBox.shrink();

    final columns = width >= 760 ? 2 : 1;
    const gap = 12.0;
    final itemWidth =
        (width - (width < 640 ? 24 : 32) - gap * (columns - 1)) / columns;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Apps',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: p.text,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final app in apps)
              SizedBox(
                width: itemWidth,
                child: _AppCard(app: app),
              ),
          ],
        ),
      ],
    );
  }
}

class _AppCard extends StatelessWidget {
  const _AppCard({required this.app});

  final SubscriptionAppModel app;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final expired = app.isExpired;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.name,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: p.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Start Date: ${_date(app.startDate)}\n'
                  'End Date: ${_date(app.endDate)}',
                  style: TextStyle(fontSize: 12, height: 1.5, color: p.subText),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (expired ? Colors.grey : _kGreen).withOpacity(0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              expired ? 'Expired' : (app.isTrial ? 'Trial' : 'Active'),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: expired ? p.subText : _kGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BUTTONS
// ============================================================

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.controller, required this.width});

  final SubscriptionController controller;
  final double width;

  @override
  Widget build(BuildContext context) {
    final upgrade = FilledButton.icon(
      onPressed: controller.upgradePlan,
      style: FilledButton.styleFrom(
        backgroundColor: _kAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      icon: const Icon(Icons.workspace_premium_outlined, size: 18),
      label: const Text('Upgrade plan'),
    );

    final billing = OutlinedButton(
      onPressed: controller.manageBilling,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      child: const Text('Manage billing'),
    );

    if (width < 480) {
      return Row(
        children: [
          Expanded(child: upgrade),
          const SizedBox(width: 12),
          Expanded(child: billing),
        ],
      );
    }

    return Wrap(spacing: 12, runSpacing: 12, children: [upgrade, billing]);
  }
}

// ============================================================
// PAYMENT INFORMATION
// ============================================================

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({required this.controller, required this.width});

  final SubscriptionController controller;
  final double width;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------- Title ----------
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _kAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.credit_card, size: 20, color: _kAccent),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment information',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: p.text,
                  ),
                ),
                Text(
                  'Latest billing references',
                  style: TextStyle(fontSize: 12.5, color: p.subText),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ---------- List + Show more ----------
        // visibleCount yahin Obx ke andar padha jata hai, isliye
        // "Show more" dabane par ye hissa khud rebuild hota hai.
        Obx(() {
          final payments = controller.visiblePayments;
          final total = controller.payments.length;

          if (payments.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No payments yet',
                  style: TextStyle(color: p.subText),
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (width < 700)
                Column(
                  children: [
                    for (final pay in payments)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _PaymentCard(payment: pay),
                      ),
                  ],
                )
              else
                _PaymentTable(payments: payments),

              if (controller.hasMorePayments)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Center(
                    child: OutlinedButton(
                      onPressed: controller.showMorePayments,
                      child: Text(
                        'Show more (${total - payments.length} left)',
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }
}

// ---------- Table (tablet / desktop / windows) ----------

class _PaymentTable extends StatelessWidget {
  const _PaymentTable({required this.payments});

  final List<PaymentModel> payments;

  static const double _minWidth = 760;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = math.max(constraints.maxWidth, _minWidth);

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: p.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  children: [
                    // ---------- Header ----------
                    Container(
                      color: p.primary.withOpacity(0.15),
                      child: Row(
                        children: [
                          _cell('Order Id', 5, p, header: true),
                          _cell('Payment Id', 5, p, header: true),
                          _cell('Amount', 2, p, header: true),
                          _cell('Currency', 2, p, header: true),
                          _cell('Status', 3, p, header: true),
                          _cell('Created At', 4, p, header: true),
                        ],
                      ),
                    ),

                    // ---------- Rows ----------
                    for (final pay in payments)
                      Container(
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: p.border)),
                        ),
                        child: Row(
                          children: [
                            _cell(pay.orderId, 5, p),
                            _cell(pay.paymentId, 5, p),
                            _cell(
                              '₹${_money(pay.amount)}',
                              2,
                              p,
                              color: p.primary,
                              bold: true,
                            ),
                            _cell(pay.currency, 2, p),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: _StatusChip(status: pay.status),
                                ),
                              ),
                            ),
                            _cell(_dateTime(pay.createdAt), 4, p),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _cell(
    String text,
    int flex,
    SettingPalette p, {
    bool header = false,
    bool bold = false,
    Color? color,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Text(
          text.isEmpty ? '-' : text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: (header || bold) ? FontWeight.w600 : FontWeight.w400,
            color: header ? p.primary : (color ?? p.subText),
          ),
        ),
      ),
    );
  }
}

// ---------- Card (phone) ----------

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment});

  final PaymentModel payment;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '₹${_money(payment.amount)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: p.primary,
                  ),
                ),
              ),
              _StatusChip(status: payment.status),
            ],
          ),
          const SizedBox(height: 10),
          _line('Order Id', payment.orderId, p),
          if (payment.paymentId.isNotEmpty)
            _line('Payment Id', payment.paymentId, p),
          _line('Currency', payment.currency, p),
          _line('Created At', _dateTime(payment.createdAt), p),
        ],
      ),
    );
  }

  Widget _line(String label, String value, SettingPalette p) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: p.subText),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 12.5, color: p.text)),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final s = status.toUpperCase();

    final Color color;
    if (s == 'SUCCESS') {
      color = _kGreen;
    } else if (s == 'CREATED' || s == 'PENDING') {
      color = const Color(0xFFEAB308); // yellow
    } else {
      color = Colors.redAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        s,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ============================================================
// HELPERS
// ============================================================

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// 12 May 2026
String _date(DateTime? d) {
  if (d == null) return '-';
  return '${d.day} ${_months[d.month - 1]} ${d.year}';
}

/// Apr 23, 2026 : 06:31 PM
String _dateTime(DateTime? d) {
  if (d == null) return '-';

  final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final period = d.hour >= 12 ? 'PM' : 'AM';

  return '${_months[d.month - 1]} ${d.day}, ${d.year} : '
      '${_two(hour12)}:${_two(d.minute)} $period';
}

/// 2999.0 -> "2999", 1.9 -> "1.90"
String _money(num value) {
  return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
}

String _capitalize(String s) {
  if (s.isEmpty) return '-';
  return s[0].toUpperCase() + s.substring(1);
}
