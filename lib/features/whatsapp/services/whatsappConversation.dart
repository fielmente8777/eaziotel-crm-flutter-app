import 'dart:convert';

import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:eazotel/features/whatsapp/models/WhatsappMessagesResponseModel.dart';
import 'package:http/http.dart' as http;

class WhatsappService {
  WhatsappService._();

  static Future<Map<String, dynamic>> getConversations({
    required String hid,
  }) async {
    final token = await TokenStorage.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Access token not found');
    }

    final uri = Uri.parse(
      '${BaseUrl.production2}'
      '${WhatsappApiEndpoint.getConversations}'
      '?hid=$hid',
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final Map<String, dynamic> data =
        jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    throw Exception(
      data['responseMessage']?.toString() ??
          'Failed to fetch WhatsApp conversations',
    );
  }

  static Future<WhatsappMessagesResponseModel>
      getConversationMessages({
    required String conversationId,
  }) async {
    final token = await TokenStorage.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Access token not found');
    }

    final uri = Uri.parse(
      '${BaseUrl.production2}'
      '${WhatsappApiEndpoint.getMessages(conversationId)}',
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final Map<String, dynamic> data =
        jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return WhatsappMessagesResponseModel.fromJson(data);
    }

    throw Exception(
      data['responseMessage']?.toString() ??
          'Failed to fetch WhatsApp messages',
    );
  }
}