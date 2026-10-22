// ============================================================
// WHATSAPP ACTION RESPONSE
// For APIs that only say "done / not done" (save, delete, create):
//   template create / update / delete, auto message save, AI save,
//   flow create, quick reply save / delete
//
//   { "success": true, "responseStatusCode": 200,
//     "responseMessage": "Template created successfully", "result": {...} }
// ============================================================

import 'dart:convert';

import 'package:eazotel/core/api/apiexception/api_exception.dart';

class WhatsappActionResponse {
  final bool? success;
  final int? responseStatusCode;
  final String? responseMessage;
  final dynamic result;

  /// Meta's error (template rejected): error.error.error_user_msg
  final String? metaError;

  WhatsappActionResponse({
    this.success,
    this.responseStatusCode,
    this.responseMessage,
    this.result,
    this.metaError,
  });

  bool get isSuccess => success == true;

  factory WhatsappActionResponse.fromJson(Map<String, dynamic> json) {
    return WhatsappActionResponse(
      success: json['success'] as bool?,
      responseStatusCode: json['responseStatusCode'] as int?,
      responseMessage: json['responseMessage']?.toString(),
      result: json['result'],
      metaError: _metaError(json['error']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'responseStatusCode': responseStatusCode,
      'responseMessage': responseMessage,
      'result': result,
    };
  }

  /// The server's most useful message ([fallback] if none)
  String message(String fallback) {
    final text = metaError ?? responseMessage;
    return text == null || text.trim().isEmpty ? fallback : text;
  }

  /// A readable message from a failed API (ApiException)
  static String errorOf(Object error, String fallback) {
    if (error is ApiException) {
      try {
        final json = jsonDecode(error.responseBody ?? '');
        if (json is Map) {
          final response = WhatsappActionResponse.fromJson(
            Map<String, dynamic>.from(json),
          );
          return response.message(error.message);
        }
      } catch (_) {}
      return error.message;
    }
    return fallback;
  }

  static String? _metaError(dynamic error) {
    // { error: { error: { error_user_msg: "..." } } } ya { error: { message } }
    if (error is! Map) return error is String ? error : null;
    final inner = error['error'];
    if (inner is Map) {
      return (inner['error_user_msg'] ?? inner['message'])?.toString();
    }
    return (error['error_user_msg'] ?? error['message'])?.toString();
  }
}
