// ============================================================
// WHATSAPP SETTING SERVICE
//
// Settings > WhatsApp tab ki API calls. Sirf yahi file server se baat karti hai.
//
//   isWhatsappConnected : GET /api/v1/integration/get
//   getAccountDetails   : GET /api/v1/whatsapp/account/connection/details
//   getBusinessProfile  : GET /api/v1/whatsapp/profile
//   updateBusinessProfile : POST /api/v1/whatsapp/profile/update
//   getFlowIds          : GET /api/v1/whatsapp/flow
//   getBilling          : GET /api/v1/whatsapp/billing
//   getTransactions     : GET /api/v1/whatsapp/billing/transactions
//   updateAutoMessageConfig : PUT /api/v1/whatsapp/account/<id>/automessageConfig/update
//   deleteTemplate      : DELETE /api/v1/whatsapp/message/template/delete
//
// Templates ki API pehle se WhatsappTemaplate.getWhatsappTemplates me hai.
// ============================================================

import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/features/whatsapp/models/FlowResponseModel.dart';
import 'package:flutter/foundation.dart';

import '../models/whatsapp_action_response.dart';

class WhatsappSettingService {
  WhatsappSettingService._();

  // ============================================================
  // WHATSAPP CONNECTED HAI YA NAHI
  // GET /api/v1/integration/get?hid=<hid>
  // result.docs.metaWhatsapp == true  ->  connected
  // ============================================================

  static Future<bool> isWhatsappConnected({required String hid}) async {
    try {
      final response = await ApiClient.get(
        '${WhatsappApiEndpoint.getIntegration}?hid=$hid',
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('🔌 WHATSAPP SETTING: INTEGRATION API');
      debugPrint('==================================================');
      debugPrint(
        'URL: ${BaseUrl.production2}${WhatsappApiEndpoint.getIntegration}?hid=$hid',
      );
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      // JSON decode
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      // result.docs.metaWhatsapp
      final docs = json['result']?['docs'];

      return docs is Map && docs['metaWhatsapp'] == true;
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ WHATSAPP SETTING: INTEGRATION API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }

  // ============================================================
  // ACCOUNT DETAILS
  // GET /api/v1/whatsapp/account/connection/details?hid=<hid>
  // result.docs -> business, phoneNumber, waba, autoMessage, ai
  // ============================================================

  static Future<Map<String, dynamic>> getAccountDetails({
    required String hid,
  }) async {
    try {
      final response = await ApiClient.get(
        '${WhatsappApiEndpoint.accountDetails}?hid=$hid',
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('🏢 WHATSAPP SETTING: ACCOUNT DETAILS API');
      debugPrint('==================================================');
      debugPrint(
        'URL: ${BaseUrl.production2}${WhatsappApiEndpoint.accountDetails}?hid=$hid',
      );
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      // JSON decode
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      // result.docs
      final docs = json['result']?['docs'];

      return docs is Map ? Map<String, dynamic>.from(docs) : {};
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ WHATSAPP SETTING: ACCOUNT DETAILS API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }

  // ============================================================
  // BUSINESS PROFILE
  // GET /api/v1/whatsapp/profile?hid=<hid>
  // result.doc -> about, address, email, websites, vertical, profile_picture_url
  // ============================================================

  static Future<Map<String, dynamic>> getBusinessProfile({
    required String hid,
  }) async {
    try {
      final response = await ApiClient.get(
        '${WhatsappApiEndpoint.businessProfile}?hid=$hid',
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('👤 WHATSAPP SETTING: BUSINESS PROFILE API');
      debugPrint('==================================================');
      debugPrint(
        'URL: ${BaseUrl.production2}${WhatsappApiEndpoint.businessProfile}?hid=$hid',
      );
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      // JSON decode
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      // result.doc  (yahan "doc" hai, "docs" nahi)
      final doc = json['result']?['doc'];

      return doc is Map ? Map<String, dynamic>.from(doc) : {};
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ WHATSAPP SETTING: BUSINESS PROFILE API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }

  // ============================================================
  // BUSINESS PROFILE UPDATE
  // POST /api/v1/whatsapp/profile/update?hid=<hid>   (form-data)
  // fields: about, vertical, email, address, websites (JSON list ka text)
  // ============================================================

  static Future<void> updateBusinessProfile({
    required String hid,
    required String about,
    required String vertical,
    required String email,
    required String address,
    required List<String> websites,

    /// Nayi profile photo (web jaisa "file" field me jaati hai)
    String? photoPath,
  }) async {
    try {
      final response = await ApiClient.multipart(
        '${WhatsappApiEndpoint.updateBusinessProfile}?hid=$hid',
        authenticated: true,
        baseUrl: BaseUrl.production2,
        fields: {
          'about': about,
          'vertical': vertical,
          'email': email,
          'address': address,
          // Web bhi list ko text bana kar bhejta hai: ["https://a.com/","https://b.com/"]
          'websites': jsonEncode(websites),
        },
        files: [
          if (photoPath != null) ApiUploadFile(field: 'file', path: photoPath),
        ],
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('✏️ WHATSAPP SETTING: PROFILE UPDATE API');
      debugPrint('==================================================');
      debugPrint(
        'URL: ${BaseUrl.production2}${WhatsappApiEndpoint.updateBusinessProfile}?hid=$hid',
      );
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      // Server 200 ke saath bhi "success": false bhej sakta hai
      final json = jsonDecode(response.body);

      if (json is Map && json['success'] == false) {
        throw Exception(json['responseMessage'] ?? 'Profile update failed');
      }
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ WHATSAPP SETTING: PROFILE UPDATE API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }

  // ============================================================
  // BILLING  (Credits & Usage > Overview)
  // GET /api/v1/whatsapp/billing?hid=<hid>
  // result.docs -> wallet, cycle, freeTier, usage, rates
  // ============================================================

  static Future<Map<String, dynamic>> getBilling({required String hid}) async {
    try {
      final response = await ApiClient.get(
        '${WhatsappApiEndpoint.billing}?hid=$hid',
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('💰 WHATSAPP SETTING: BILLING API');
      debugPrint('==================================================');
      debugPrint(
        'URL: ${BaseUrl.production2}${WhatsappApiEndpoint.billing}?hid=$hid',
      );
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      // JSON decode
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      // result.docs
      final docs = json['result']?['docs'];

      return docs is Map ? Map<String, dynamic>.from(docs) : {};
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ WHATSAPP SETTING: BILLING API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }

  // ============================================================
  // TRANSACTIONS  (Credits & Usage > Transactions)
  // GET /api/v1/whatsapp/billing/transactions?hid=<hid>&page=1&limit=10
  // result.docs -> items, pagination
  // ============================================================

  static Future<Map<String, dynamic>> getTransactions({
    required String hid,
    required int page,
    required int limit,
  }) async {
    final endpoint =
        '${WhatsappApiEndpoint.billingTransactions}?hid=$hid&page=$page&limit=$limit';

    try {
      final response = await ApiClient.get(
        endpoint,
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('🧾 WHATSAPP SETTING: TRANSACTIONS API');
      debugPrint('==================================================');
      debugPrint('URL: ${BaseUrl.production2}$endpoint');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      // JSON decode
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      // result.docs
      final docs = json['result']?['docs'];

      return docs is Map ? Map<String, dynamic>.from(docs) : {};
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ WHATSAPP SETTING: TRANSACTIONS API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }

  // ============================================================
  // CHATBOT FLOW KI ID  (auto message ke "Flow" dropdown ke liye)
  // GET /api/v1/whatsapp/flow?hid=<hid>
  // result.docs.flow._id
  // ============================================================

  static Future<List<String>> getFlowIds({required String hid}) async {
    try {
      final response = await ApiClient.get(
        '${WhatsappApiEndpoint.chatbotFlow}?hid=$hid',
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('🔀 WHATSAPP SETTING: FLOW API');
      debugPrint('==================================================');
      debugPrint(
        'URL: ${BaseUrl.production2}${WhatsappApiEndpoint.chatbotFlow}?hid=$hid',
      );
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('==================================================');

      // JSON decode
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      // result.docs.flow  (ek flow aaye ya list, dono chalenge)
      final flow = json['result']?['docs']?['flow'];
      final flows = flow is List ? flow : [flow];

      return [
        for (final item in flows)
          if (item is Map && item['_id'] != null) item['_id'].toString(),
      ];
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ WHATSAPP SETTING: FLOW API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }

  // ============================================================
  // FLOW LIST  (WhatsApp Flow > Flow Name tab)
  // GET /api/v1/whatsapp/flow/get?hid=<hid>
  // result.docs.flows -> list of flows
  // ============================================================

  static Future<FlowResponseModel> getFlows({required String hid}) async {
    try {
      final response = await ApiClient.get(
        '${WhatsappApiEndpoint.flow}$hid',
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('🔀 WHATSAPP FLOW LIST: STATUS ${response.statusCode}');
      debugPrint('BODY: ${response.body}');

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      return FlowResponseModel.fromJson(json);
    } catch (e, stackTrace) {
      debugPrint('❌ WHATSAPP FLOW LIST ERROR: $e');
      debugPrint('STACK: $stackTrace');
      rethrow;
    }
  }

  // ============================================================
  // AUTO MESSAGE / AI SAVE
  // PUT /api/v1/whatsapp/account/<phoneNumberId>/automessageConfig/update
  //   auto message: { phoneNumberId, autoMessage: {...}, notification: {enable} }
  //   AI          : { phoneNumberId, ai: {enabled, duration: {from, to}, timezone} }
  // ============================================================

  static Future<WhatsappActionResponse> updateAutoMessageConfig({
    required String phoneNumberId,
    required Map<String, dynamic> body,
  }) async {
    final endpoint = WhatsappApiEndpoint.autoMessageConfig(phoneNumberId);

    try {
      final response = await ApiClient.put(
        endpoint,
        body: {'phoneNumberId': phoneNumberId, ...body},
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('⚙️ WHATSAPP AUTO MESSAGE CONFIG API');
      debugPrint('==================================================');
      debugPrint('URL: ${BaseUrl.production2}$endpoint');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      return WhatsappActionResponse.fromJson(json);
    } catch (e, stackTrace) {
      debugPrint('❌ WHATSAPP AUTO MESSAGE CONFIG ERROR: $e');
      debugPrint('STACK: $stackTrace');
      rethrow;
    }
  }

  // ============================================================
  // TEMPLATE DELETE
  // DELETE /api/v1/whatsapp/message/template/delete
  // body: { templateName, language }
  // ============================================================

  static Future<WhatsappActionResponse> deleteTemplate({
    required String templateName,
    required String language,
  }) async {
    const endpoint = WhatsappApiEndpoint.deleteTemplate;

    try {
      final response = await ApiClient.delete(
        endpoint,
        body: {'templateName': templateName, 'language': language},
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('🗑️ WHATSAPP TEMPLATE DELETE API');
      debugPrint('==================================================');
      debugPrint('URL: ${BaseUrl.production2}$endpoint');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      final Map<String, dynamic> json = response.body.trim().isEmpty
          ? {'success': true}
          : jsonDecode(response.body) as Map<String, dynamic>;

      return WhatsappActionResponse.fromJson(json);
    } catch (e, stackTrace) {
      debugPrint('❌ WHATSAPP TEMPLATE DELETE ERROR: $e');
      debugPrint('STACK: $stackTrace');
      rethrow;
    }
  }
}
