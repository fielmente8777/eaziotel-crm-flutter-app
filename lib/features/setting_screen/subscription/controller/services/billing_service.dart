// ============================================================
// BILLING SERVICE  (plan / apps khareedna, web ke Billing page jaisa)
//
//   getPlans      : GET  /api/v1/subscription/plans
//   createOrder   : POST /api/v1/subscription/create-order   -> Razorpay order
//   verifyPayment : POST /api/v1/subscription/verify-payment (payment ke baad)
// ============================================================

import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:flutter/foundation.dart';

import '../../model/billing_models.dart';

class BillingService {
  BillingService._();

  static void _log(String tag, String url, int status, String body) {
    debugPrint('');
    debugPrint('==================================================');
    debugPrint('💳 $tag API');
    debugPrint('==================================================');
    debugPrint('URL: ${BaseUrl.production2}$url');
    debugPrint('STATUS: $status');
    debugPrint(
      'BODY: ${body.length > 1500 ? '${body.substring(0, 1500)}…' : body}',
    );
    debugPrint('==================================================');
  }

  static Map<String, dynamic> _map(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  /// Server ka message nikal kar Exception (UI wahi dikhata hai)
  static Never _fail(Map<String, dynamic> json, String fallback) {
    final message =
        _map(json['result'])['message'] ??
        json['message'] ??
        json['error'] ??
        json['responseMessage'];
    throw Exception('${message ?? fallback}');
  }

  // ============================================================
  // PLANS + APPS
  // ============================================================

  static Future<({List<BillingPlan> plans, List<BillingApp> apps})>
  getPlans() async {
    const url = SubscriptionApiEndpoint.plans;

    final response = await ApiClient.get(
      url,
      authenticated: true,
      baseUrl: BaseUrl.production2,
    );
    _log('PLANS', url, response.statusCode, response.body);

    final data = _map(_map(_map(jsonDecode(response.body))['result'])['data']);
    final plans = data['plans'];
    final apps = data['apps'];

    return (
      plans: [
        if (plans is List)
          for (final p in plans)
            if (p is Map) BillingPlan.fromJson(Map<String, dynamic>.from(p)),
      ],
      apps: [
        if (apps is List)
          for (final a in apps)
            if (a is Map) BillingApp.fromJson(Map<String, dynamic>.from(a)),
      ],
    );
  }

  // ============================================================
  // ORDER (Razorpay)
  // ============================================================

  static Future<BillingOrder> createOrder({
    required String planId,
    required List<String> appIds,
    required int validFor,
    required int discount,
    required int teamCount,
    required num teamCost,
    required int gst,
  }) async {
    const url = SubscriptionApiEndpoint.createOrder;

    final response = await ApiClient.post(
      url,
      body: {
        'planId': planId,
        'appIds': appIds,
        'validFor': validFor,
        'discount': discount,
        'teamCount': teamCount,
        'teamCost': teamCost,
        'gst': gst,
      },
      authenticated: true,
      baseUrl: BaseUrl.production2,
    );
    _log('CREATE ORDER', url, response.statusCode, response.body);

    final json = _map(jsonDecode(response.body));
    final doc = _map(_map(json['result'])['doc']);
    final orderId = '${doc['orderId'] ?? ''}'.trim();

    if (json['success'] == false || orderId.isEmpty) {
      _fail(json, 'Could not create the order. Please try again.');
    }

    final amount = doc['amount'];
    return BillingOrder(
      orderId: orderId,
      // Server Key ID bheje (keyId / key_id / key) to wahi: order aur checkout
      // hamesha ek hi key se
      keyId: '${doc['keyId'] ?? doc['key_id'] ?? doc['key'] ?? ''}'.trim(),
      amountInPaise: amount is num
          ? amount.round()
          : int.tryParse('$amount') ?? 0,
    );
  }

  /// Razorpay ne paisa le liya -> server ko batao (plan / apps chalu)
  static Future<void> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
    required int validFor,
    required String planId,
    required List<String> appIds,
  }) async {
    const url = SubscriptionApiEndpoint.verifyPayment;

    final response = await ApiClient.post(
      url,
      body: {
        'razorpay_payment_id': paymentId,
        'razorpay_order_id': orderId,
        'razorpay_signature': signature,
        'validFor': validFor,
        'planId': planId,
        'appIds': appIds,
      },
      authenticated: true,
      baseUrl: BaseUrl.production2,
    );
    _log('VERIFY PAYMENT', url, response.statusCode, response.body);

    final json = _map(jsonDecode(response.body));
    if (json['success'] == false) {
      _fail(json, 'Payment could not be confirmed.');
    }
  }
}
