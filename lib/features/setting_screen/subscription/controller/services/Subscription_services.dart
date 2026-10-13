// ============================================================
// SUBSCRIPTION SERVICE
//
//   getMySubscription : GET /api/v1/subscription/my
// ============================================================

import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/features/setting_screen/subscription/model/subscription_model.dart';
import 'package:flutter/foundation.dart';

 
class SubscriptionService {
  SubscriptionService._();

  static Future<SubscriptionResponseModel> getMySubscription() async {
    try {
      final response = await ApiClient.get(
        SubscriptionApiEndpoint.mySubscription,
        authenticated: true,
        baseUrl: BaseUrl.production2, // gian-1eve.onrender.com
      );

      debugPrint('SUBSCRIPTION: STATUS ${response.statusCode}');

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      final result = SubscriptionResponseModel.fromJson(json);

      if (!result.success) {
        throw Exception(
          result.message.isEmpty ? 'Unable to load subscription' : result.message,
        );
      }

      return result;
    } catch (e, stackTrace) {
      debugPrint('SUBSCRIPTION ERROR: $e');
      debugPrint('STACK: $stackTrace');
      rethrow;
    }
  }
}