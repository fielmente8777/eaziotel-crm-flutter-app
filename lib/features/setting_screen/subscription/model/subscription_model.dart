// ============================================================
// SUBSCRIPTION RESPONSE (GET /api/v1/subscription/my)
//
//   result.docs      -> subscription (plan, status, dates, apps)
//   result.payments  -> payment list
// ============================================================

class SubscriptionResponseModel {
  final bool success;
  final String message;
  final SubscriptionModel? subscription;
  final List<PaymentModel> payments;

  SubscriptionResponseModel({
    this.success = false,
    this.message = '',
    this.subscription,
    this.payments = const [],
  });

  factory SubscriptionResponseModel.fromJson(Map<String, dynamic> json) {
    final result = _toMap(json['result']);
    final docs = _toMap(result?['docs']);
    final rawPayments = result?['payments'];

    return SubscriptionResponseModel(
      success: json['success'] == true,
      message: json['responseMessage']?.toString() ?? '',
      subscription: docs == null ? null : SubscriptionModel.fromJson(docs),
      payments: rawPayments is List
          ? rawPayments
                .whereType<Map>()
                .map((e) => PaymentModel.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : <PaymentModel>[],
    );
  }
}

// ============================================================
// SUBSCRIPTION
// ============================================================

class SubscriptionModel {
  final String id;
  final String status; // ACTIVE ...
  final DateTime? startDate;
  final DateTime? endDate;
  final bool autoRenew;
  final SubscriptionPlanModel plan;
  final List<SubscriptionAppModel> apps;

  SubscriptionModel({
    required this.id,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.autoRenew,
    required this.plan,
    required this.apps,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  /// Bache hue din (aaj se endDate tak)
  int get daysLeft {
    final end = endDate;
    if (end == null) return 0;

    final hours = end.difference(DateTime.now()).inHours;
    return hours <= 0 ? 0 : (hours / 24).ceil();
  }

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final rawApps = json['apps'];

    return SubscriptionModel(
      id: json['_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      startDate: _toDate(json['startDate']),
      endDate: _toDate(json['endDate']),
      autoRenew: json['autoRenew'] == true,
      plan: SubscriptionPlanModel.fromJson(_toMap(json['planId']) ?? {}),
      apps: rawApps is List
          ? rawApps
                .whereType<Map>()
                .map(
                  (e) => SubscriptionAppModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : <SubscriptionAppModel>[],
    );
  }
}

// ============================================================
// PLAN  (docs.planId)
// ============================================================

class SubscriptionPlanModel {
  /// Plan ki id (_id): "Current plan" pehchanne aur naya plan lene me
  final String id;
  final String name;
  final num price;
  final String support;
  final int teamMembers;
  final int aiCreditsMonthly;
  final int maxLeadsPerMonth;

  SubscriptionPlanModel({
    this.id = '',
    this.name = '',
    this.price = 0,
    this.support = '',
    this.teamMembers = 0,
    this.aiCreditsMonthly = 0,
    this.maxLeadsPerMonth = 0,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    final limits = _toMap(json['limits']) ?? {};

    return SubscriptionPlanModel(
      id: json['_id']?.toString() ?? '',
      name: json['planName']?.toString() ?? '',
      price: json['price'] is num ? json['price'] as num : 0,
      support: json['support']?.toString() ?? '',
      teamMembers: _toInt(limits['teamMembers']),
      aiCreditsMonthly: _toInt(limits['aiCreditsMonthly']),
      maxLeadsPerMonth: _toInt(limits['maxLeadsPerMonth']),
    );
  }
}

// ============================================================
// APP  (docs.apps[])
// ============================================================

class SubscriptionAppModel {
  /// App ki id (appId._id): "Purchased" pehchanne me
  final String appId;
  final String name;
  final String code;
  final num price;
  final bool isTrial;
  final DateTime? startDate;
  final DateTime? endDate;

  SubscriptionAppModel({
    this.appId = '',
    required this.name,
    required this.code,
    required this.price,
    required this.isTrial,
    required this.startDate,
    required this.endDate,
  });

  bool get isExpired {
    final end = endDate;
    return end != null && end.isBefore(DateTime.now());
  }

  factory SubscriptionAppModel.fromJson(Map<String, dynamic> json) {
    final app = _toMap(json['appId']) ?? {};

    return SubscriptionAppModel(
      appId: app['_id']?.toString() ?? '',
      name: app['name']?.toString() ?? '',
      code: app['code']?.toString() ?? '',
      price: app['price'] is num ? app['price'] as num : 0,
      isTrial: json['isTrial'] == true,
      startDate: _toDate(json['startDate']),
      endDate: _toDate(json['endDate']),
    );
  }
}

// ============================================================
// PAYMENT  (result.payments[])
// ============================================================

class PaymentModel {
  final String id;
  final String orderId;
  final String paymentId;
  final num amountInPaise; // server paise me bhejta hai (299900 = Rs 2999)
  final String currency;
  final String status; // SUCCESS / created
  final DateTime? createdAt;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.paymentId,
    required this.amountInPaise,
    required this.currency,
    required this.status,
    required this.createdAt,
  });

  /// Rupees me amount
  num get amount => amountInPaise / 100;

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['_id']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      paymentId: json['paymentId']?.toString() ?? '',
      amountInPaise: json['amount'] is num ? json['amount'] as num : 0,
      currency: json['currency']?.toString() ?? 'INR',
      status: json['status']?.toString() ?? '',
      createdAt: _toDate(json['createdAt']),
    );
  }
}

// ============================================================
// SAFE HELPERS
// ============================================================

Map<String, dynamic>? _toMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

/// ISO string (UTC) -> local DateTime
DateTime? _toDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}
