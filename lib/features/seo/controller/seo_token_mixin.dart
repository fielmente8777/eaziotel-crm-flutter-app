// ============================================================
// SEO TOKEN MIXIN
// Both Local SEO and Website SEO need credits (tokens):
//   tokenResponse : the API model
//   tokenBalance  : how many are left (null = unknown)
//   canAfford(n)  : whether there are n credits
// ============================================================

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/seo_token_response.dart';
import '../services/seo_service.dart';

mixin SeoTokenMixin on GetxController {
  final tokenResponse = Rxn<SeoTokenResponse>();

  int? get tokenBalance => tokenResponse.value?.result.balance;

  SeoTokenPricing get pricing =>
      tokenResponse.value?.result.pricing ?? const SeoTokenPricing();

  /// If the balance is unknown we do not block (the server returns 402 itself)
  bool canAfford(int cost) => tokenBalance == null || tokenBalance! >= cost;

  Future<void> loadTokens() async {
    try {
      tokenResponse.value = await SeoService.getSeoTokens();
    } catch (e) {
      debugPrint('SEO: tokens error: $e');
    }
  }
}
