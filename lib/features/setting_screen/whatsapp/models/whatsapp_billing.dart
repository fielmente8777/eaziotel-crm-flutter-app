// ============================================================
// WHATSAPP BILLING (models)
//
// Settings > WhatsApp > Credits & Usage ka data.
//
//   WhatsappBilling      : wallet, free messages aur is mahine ka usage
//                          (GET /api/v1/whatsapp/billing -> result.docs)
//   BillingUsageRow      : usage table ki ek line (Marketing, Utility ...)
//   WhatsappTransaction  : recharge ki ek entry
//                          (GET /api/v1/whatsapp/billing/transactions -> items)
// ============================================================

/// null / galat type ho to 0
double _toDouble(dynamic value) {
  return value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
}

int _toInt(dynamic value) {
  return value is num ? value.toInt() : int.tryParse('$value') ?? 0;
}

/// null / galat type ho to khali Map
Map<String, dynamic> _toMap(dynamic value) {
  return value is Map ? Map<String, dynamic>.from(value) : {};
}

/// "2026-10-07T06:30:46.500Z" -> phone ke time zone ka DateTime
DateTime? _toDate(dynamic value) {
  return DateTime.tryParse(value?.toString() ?? '')?.toLocal();
}

// ============================================================
// BILLING (Overview tab)
// ============================================================

class WhatsappBilling {
  const WhatsappBilling({
    required this.balance,
    required this.totalLoaded,
    required this.totalUsed,
    required this.lastRechargeAt,
    required this.cycleLabel,
    required this.freeLimit,
    required this.freeUsed,
    required this.freeRemaining,
    required this.usage,
  });

  // ---------- Wallet ----------
  final double balance; // Available balance
  final double totalLoaded;
  final double totalUsed;
  final DateTime? lastRechargeAt;

  /// "October 2026"
  final String cycleLabel;

  // ---------- Free service messages ----------
  final int freeLimit; // 1000
  final int freeUsed; // 66
  final int freeRemaining; // 934

  /// Usage table ki lines
  final List<BillingUsageRow> usage;

  /// "Credits used" bar: 0.0 se 1.0
  double get usedFraction {
    if (totalLoaded <= 0) return 0;

    return (totalUsed / totalLoaded).clamp(0.0, 1.0);
  }

  /// "Free service messages" bar: 0.0 se 1.0
  double get freeFraction {
    if (freeLimit <= 0) return 0;

    return (freeUsed / freeLimit).clamp(0.0, 1.0);
  }

  /// Table ki "Total" line
  int get totalMessages => usage.fold(0, (sum, row) => sum + row.messages);

  double get totalCost => usage.fold(0, (sum, row) => sum + row.cost);

  factory WhatsappBilling.fromJson(Map<String, dynamic> json) {
    final wallet = _toMap(json['wallet']);
    final freeTier = _toMap(json['freeTier']);
    final usage = _toMap(json['usage']);
    final rates = _toMap(json['rates']);

    final service = _toMap(usage['service']);
    final authentication = _toMap(usage['authentication']);

    return WhatsappBilling(
      balance: _toDouble(wallet['balance']),
      totalLoaded: _toDouble(wallet['totalLoaded']),
      totalUsed: _toDouble(wallet['totalUsed']),
      lastRechargeAt: _toDate(wallet['lastRechargeAt']),
      cycleLabel: _toMap(json['cycle'])['label']?.toString() ?? '',
      freeLimit: _toInt(freeTier['serviceLimit']),
      freeUsed: _toInt(freeTier['serviceUsed']),
      freeRemaining: _toInt(freeTier['serviceRemaining']),
      usage: [
        BillingUsageRow.fromJson(
          type: 'Marketing',
          note: 'Promotional templates',
          usage: _toMap(usage['marketing']),
          rate: rates['marketing'],
        ),
        BillingUsageRow.fromJson(
          type: 'Utility',
          note: 'Incl. inside 24-hr window',
          usage: _toMap(usage['utility']),
          rate: rates['utility'],
        ),

        // Web ki tarah: Authentication tabhi dikhao jab koi message gaya ho
        if (_toInt(authentication['count']) > 0)
          BillingUsageRow.fromJson(
            type: 'Authentication',
            note: 'OTP / verification',
            usage: authentication,
            rate: rates['authentication'],
          ),

        BillingUsageRow.fromJson(
          type: 'Service',
          note: '${_toInt(service['billableCount'])} billable',
          usage: service,
          rate: rates['service'],
        ),
      ],
    );
  }
}

class BillingUsageRow {
  const BillingUsageRow({
    required this.type,
    required this.note,
    required this.messages,
    required this.rate,
    required this.cost,
  });

  final String type; // "Marketing"
  final String note; // "Promotional templates"
  final int messages;
  final double rate; // ek message ka daam
  final double cost;

  factory BillingUsageRow.fromJson({
    required String type,
    required String note,
    required Map<String, dynamic> usage,
    required dynamic rate,
  }) {
    return BillingUsageRow(
      type: type,
      note: note,
      messages: _toInt(usage['count']),
      rate: _toDouble(rate),
      cost: _toDouble(usage['cost']),
    );
  }
}

// ============================================================
// TRANSACTIONS (Transactions tab)
// ============================================================

class WhatsappTransaction {
  const WhatsappTransaction({
    required this.id,
    required this.paymentId,
    required this.orderId,
    required this.amount,
    required this.status,
    required this.date,
  });

  final String id;
  final String paymentId; // "pay_Tkv640808FUQdn"
  final String orderId; // "order_Tkv5ZWVd4fX6Dj"
  final double amount;
  final String status; // "paid"

  /// Payment ka time (na ho to order banne ka time)
  final DateTime? date;

  bool get isPaid => status.toLowerCase() == 'paid';

  /// "paid" -> "Paid"
  String get statusLabel {
    if (status.isEmpty) return '-';

    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  factory WhatsappTransaction.fromJson(Map<String, dynamic> json) {
    return WhatsappTransaction(
      id: json['_id']?.toString() ?? '',
      paymentId: json['razorpayPaymentId']?.toString() ?? '-',
      orderId: json['razorpayOrderId']?.toString() ?? '-',
      amount: _toDouble(json['amount']),
      status: json['status']?.toString() ?? '',
      date: _toDate(json['paidAt'] ?? json['createdAt']),
    );
  }
}

/// Transactions API ka ek page: items + kitne page hain
class WhatsappTransactionPage {
  const WhatsappTransactionPage({
    this.items = const [],
    this.page = 1,
    this.limit = 10,
    this.total = 0,
    this.totalPages = 1,
  });

  final List<WhatsappTransaction> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory WhatsappTransactionPage.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    final pagination = _toMap(json['pagination']);

    return WhatsappTransactionPage(
      items: [
        if (items is List)
          for (final item in items)
            if (item is Map)
              WhatsappTransaction.fromJson(Map<String, dynamic>.from(item)),
      ],
      page: _toInt(pagination['page']).clamp(1, 1 << 30),
      limit: _toInt(pagination['limit']),
      total: _toInt(pagination['total']),
      totalPages: _toInt(pagination['totalPages']).clamp(1, 1 << 30),
    );
  }
}
