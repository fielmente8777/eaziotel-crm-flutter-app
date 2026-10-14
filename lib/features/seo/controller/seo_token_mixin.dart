// ============================================================
// SEO TOKEN MIXIN
// Local SEO aur Website SEO dono me credits (tokens) chahiye:
//   tokenResponse : API ka model
//   tokenBalance  : kitne bache (null = pata nahi)
//   canAfford(n)  : n credit hain ya nahi
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

  /// Balance pata nahi ho to rokte nahi (server khud 402 dega)
  bool canAfford(int cost) => tokenBalance == null || tokenBalance! >= cost;

  Future<void> loadTokens() async {
    try {
      tokenResponse.value = await SeoService.getSeoTokens();
    } catch (e) {
      debugPrint('SEO: tokens error: $e');
    }
  }
}
