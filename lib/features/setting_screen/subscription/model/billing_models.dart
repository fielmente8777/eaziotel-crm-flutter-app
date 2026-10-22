// ============================================================
// BILLING MODELS  (plan + apps khareedna, web ke Billing page jaisa)
//
//   BillingPlan   : GET /api/v1/subscription/plans -> result.data.plans[]
//   BillingApp    : GET /api/v1/subscription/plans -> result.data.apps[]
//   BillingCycle  : Monthly / Quarterly / 6 Months / Yearly + discount
//   BillingOrder  : POST create-order ka jawab (Razorpay ke liye)
// ============================================================

String _s(dynamic v) {
  final text = v?.toString().trim() ?? '';
  return text == 'null' ? '' : text;
}

num _n(dynamic v) => v is num ? v : num.tryParse(_s(v)) ?? 0;

class BillingPlan {
  const BillingPlan({
    required this.id,
    required this.name,
    required this.price,
    this.modules = const [],
    this.teamMembers,
    this.aiCreditsMonthly,
    this.maxLeadsPerMonth,
    this.support = '',
  });

  final String id;

  /// BASIC / PRO / ENTERPRISE
  final String name;
  final num price;

  /// Chalu modules (corePlatform, aiLayer ...)
  final List<String> modules;

  /// null = server ne nahi bheja, -1 = Unlimited
  final num? teamMembers;
  final num? aiCreditsMonthly;
  final num? maxLeadsPerMonth;
  final String support;

  bool get isEnterprise => name.toUpperCase() == 'ENTERPRISE';
  bool get isPopular => name.toUpperCase() == 'PRO';

  static const _moduleLabels = {
    'corePlatform': 'Core Platform',
    'aiLayer': 'AI Layer',
    'analytics': 'Analytics',
    'automation': 'Automation',
    'integrations': 'Integrations',
    'unlimitedLocation': 'Unlimited Location',
  };

  static const _taglines = {
    'BASIC':
        'Perfect for small hotels starting their journey toward direct bookings and digital growth.',
    'PRO':
        'Best value for growing hotels with multichannel automation and advanced tools.',
    'ENTERPRISE':
        'Full-suite for large properties needing advanced integrations and dedicated support.',
  };

  String get tagline => _taglines[name.toUpperCase()] ?? '';

  static String _limit(num v) => v < 0 ? 'Unlimited' : '${v.round()}';

  /// "Includes" list: modules + limits + support (web jaisa)
  List<String> get includes => [
    for (final m in modules) _moduleLabels[m] ?? m,
    if (teamMembers != null) '${_limit(teamMembers!)} team members',
    if (aiCreditsMonthly != null)
      '${_limit(aiCreditsMonthly!)} AI credits / mo',
    if (maxLeadsPerMonth != null) '${_limit(maxLeadsPerMonth!)} leads / mo',
    if (support.isNotEmpty && support.toLowerCase() != 'none')
      '${support[0].toUpperCase()}${support.substring(1)} support',
  ];

  factory BillingPlan.fromJson(Map<String, dynamic> json) {
    final modules = json['modules'];
    final limits = json['limits'] is Map ? json['limits'] as Map : const {};

    num? limit(String key) => limits[key] == null ? null : _n(limits[key]);

    return BillingPlan(
      id: _s(json['_id']),
      name: _s(json['planName']),
      price: _n(json['price']),
      modules: [
        if (modules is Map)
          for (final e in modules.entries)
            if (e.value == true) '${e.key}',
      ],
      teamMembers: limit('teamMembers'),
      aiCreditsMonthly: limit('aiCreditsMonthly'),
      maxLeadsPerMonth: limit('maxLeadsPerMonth'),
      support: _s(json['support']),
    );
  }
}

class BillingApp {
  const BillingApp({required this.id, required this.name, required this.price});

  final String id;
  final String name;

  /// Har mahine (₹)
  final num price;

  factory BillingApp.fromJson(Map<String, dynamic> json) => BillingApp(
    id: _s(json['_id']),
    name: _s(json['name']),
    price: _n(json['price']),
  );
}

/// Kitne mahine ka bill + kitni chhoot (web ke CYCLES jaisa)
enum BillingCycle {
  month('Monthly', 1, 5),
  quarter('Quarterly', 3, 10),
  sixMonth('6 Months', 6, 15),
  year('Yearly', 12, 40);

  const BillingCycle(this.label, this.months, this.discount);

  final String label;
  final int months;

  /// % chhoot
  final int discount;
}

/// create-order ka jawab: Razorpay checkout ke liye
class BillingOrder {
  const BillingOrder({
    required this.orderId,
    required this.amountInPaise,
    this.keyId = '',
  });

  final String orderId;
  final int amountInPaise;

  /// Server ne Razorpay Key ID bheji ho to (khaali = .env wali use karo)
  final String keyId;
}
