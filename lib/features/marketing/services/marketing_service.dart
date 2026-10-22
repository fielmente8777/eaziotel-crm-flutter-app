// ============================================================
// MARKETING SERVICE
//
// API calls for WhatsApp + Email Marketing. Only this file talks to the server.
//
//   getWhatsappCampaigns : GET /api/v1/whatsapp/campaign?hid=
//   getCampaignDetail    : GET /api/v1/whatsapp/campaign/broadcast/<id>?page=&limit=
//   getEmailRecipients   : GET /api/v1/email-marketing/recipients?hid=&page=&limit=
//   getEmailCampaigns    : GET /api/v1/email-marketing/campaigns?hid=&page=&limit=
// ============================================================

import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/api/apiexception/api_exception.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/core/constants/api_endpoints.dart';
import 'package:eazotel/features/setting_screen/whatsapp/models/whatsapp_action_response.dart';
import 'package:flutter/foundation.dart';

import '../models/marketing_models.dart';

class MarketingService {
  MarketingService._();

  /// A clear error message: the server's if there is one, otherwise [fallback]
  static String errorText(Object e, String fallback) {
    if (e is ApiException) return WhatsappActionResponse.errorOf(e, fallback);

    final text = '$e'.replaceFirst('Exception: ', '').trim();
    return text.isEmpty || text.length > 200 ? fallback : text;
  }

  // ============================================================
  // WHATSAPP
  // ============================================================

  static Future<List<WhatsappCampaign>> getWhatsappCampaigns({
    required String hid,
  }) async {
    final json = await _get(
      'WHATSAPP CAMPAIGNS',
      '${MarketingApiEndpoint.whatsappCampaigns}?hid=$hid',
    );

    final list = _map(_map(json['result'])['docs'])['campaigns'];

    return list is List
        ? list
              .whereType<Map>()
              .map(
                (e) => WhatsappCampaign.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList()
        : [];
  }

  static Future<
    ({
      WhatsappCampaign campaign,
      List<CampaignRecipient> recipients,
      MarketingPage page,
    })
  >
  getCampaignDetail({
    required String id,
    required int page,
    int limit = 10,
  }) async {
    final json = await _get(
      'CAMPAIGN DETAIL',
      '${MarketingApiEndpoint.whatsappCampaignDetail(id)}?page=$page&limit=$limit',
    );

    final doc = _map(_map(json['result'])['doc']);
    final list = doc['recipients'];

    return (
      campaign: WhatsappCampaign.fromJson(_map(doc['campaign'])),
      recipients: list is List
          ? list
                .whereType<Map>()
                .map(
                  (e) =>
                      CampaignRecipient.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : <CampaignRecipient>[],
      page: MarketingPage.fromJson(doc['pagination']),
    );
  }

  // ============================================================
  // EMAIL
  // ============================================================

  static Future<({List<EmailRecipient> items, MarketingPage page})>
  getEmailRecipients({
    required String hid,
    required int page,
    int limit = 50,
    String search = '',
  }) async {
    final json = await _get(
      'EMAIL RECIPIENTS',
      _url(MarketingApiEndpoint.emailRecipients, {
        'hid': hid,
        'page': '$page',
        'limit': '$limit',
        'search': search.trim(),
      }),
    );

    final result = _map(json['result']);
    final list = result['doc'];

    return (
      items: list is List
          ? list
                .whereType<Map>()
                .map(
                  (e) => EmailRecipient.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : <EmailRecipient>[],
      page: MarketingPage.fromJson(result['pagination']),
    );
  }

  static Future<({List<EmailCampaign> items, MarketingPage page})>
  getEmailCampaigns({
    required String hid,
    required int page,
    int limit = 20,
  }) async {
    final json = await _get(
      'EMAIL CAMPAIGNS',
      '${MarketingApiEndpoint.emailCampaigns}?hid=$hid&page=$page&limit=$limit',
      // The campaign comes with the full HTML, which floods the log
      logBody: false,
    );

    final result = _map(json['result']);
    final list = result['doc'];

    return (
      items: list is List
          ? list
                .whereType<Map>()
                .map(
                  (e) => EmailCampaign.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : <EmailCampaign>[],
      page: MarketingPage.fromJson(result['pagination']),
    );
  }

  // ============================================================
  // WHATSAPP: NEW CAMPAIGN
  // ============================================================

  /// How many contacts the campaign will reach ('' source = all)
  static Future<int> getCampaignAudience({
    required String hid,
    String source = '',
  }) async {
    final json = await _get(
      'CAMPAIGN AUDIENCE',
      _url(MarketingApiEndpoint.whatsappCampaignAudience, {
        'hid': hid,
        'source': source,
      }),
    );

    final total = _map(json['result'])['totalUsers'];
    return total is num ? total.toInt() : int.tryParse('$total') ?? 0;
  }

  /// [template] = templateId, templateName, templateCategory,
  /// templateLanguage, templateParams, templateParamsHeader
  static Future<void> createWhatsappCampaign({
    required String hid,
    required String name,
    required Map<String, dynamic> template,
    String source = '',
  }) async {
    await _send(
      'CREATE WHATSAPP CAMPAIGN',
      'POST',
      _url(MarketingApiEndpoint.whatsappCreateCampaign, {'hid': hid}),
      {
        'campaignName': name,
        'template': template,
        if (source.isNotEmpty) 'source': source,
      },
    );
  }

  // ============================================================
  // EMAIL: RECIPIENT BATCH (who to send to)
  // Answer of all three: result.doc { recipientBatchId, count }
  // ============================================================

  static Future<({String batchId, int count})> createBatchFromLeads({
    required String hid,
    required List<String> leadIds,
  }) => _batch('LEADS BATCH', MarketingApiEndpoint.emailBatchLeads, {
    'hid': hid,
    'leadIds': leadIds,
  });

  /// ALL leads matching the search (not just this page)
  static Future<({String batchId, int count})> createBatchFromSearch({
    required String hid,
    required String search,
  }) => _batch('ALL LEADS BATCH', MarketingApiEndpoint.emailBatchAllLeads, {
    'hid': hid,
    'search': search.trim(),
  });

  static Future<({String batchId, int count})> createBatchFromEmails({
    required String hid,
    required List<String> emails,
  }) => _batch('MANUAL BATCH', MarketingApiEndpoint.emailBatchManual, {
    'hid': hid,
    'emails': emails,
  });

  static Future<({String batchId, int count})> _batch(
    String tag,
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final json = await _send(tag, 'POST', endpoint, body);
    final doc = _map(_map(json['result'])['doc']);
    final count = doc['count'];

    return (
      batchId: '${doc['recipientBatchId'] ?? ''}',
      count: count is num ? count.toInt() : 0,
    );
  }

  // ============================================================
  // EMAIL: CREATE + SEND CAMPAIGN
  // ============================================================

  /// Multipart (with attachments). Answer: result.doc.campaign._id
  static Future<String> createEmailCampaign({
    required String hid,
    required String name,
    required String subject,
    required String html,
    required String text,
    required String fromEmail,
    String fromName = '',
    required List<String> batchIds,
    List<String> attachmentPaths = const [],
  }) async {
    const tag = 'CREATE EMAIL CAMPAIGN';
    const endpoint = MarketingApiEndpoint.emailCampaigns;

    try {
      final response = await ApiClient.multipart(
        endpoint,
        fields: {
          'hid': hid,
          'name': name,
          'subject': subject,
          'html': html,
          'text': text,
          'fromName': fromName,
          'fromEmail': fromEmail,
          'recipientBatchIds': jsonEncode(batchIds),
        },
        files: [
          for (final path in attachmentPaths)
            ApiUploadFile(field: 'attachments', path: path),
        ],
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      _log(tag, endpoint, response.statusCode, response.body);

      final json = _map(jsonDecode(response.body));
      final campaign = _map(_map(_map(json['result'])['doc'])['campaign']);

      return '${campaign['_id'] ?? ''}';
    } catch (e, stackTrace) {
      _logError(tag, e, stackTrace);
      rethrow;
    }
  }

  static Future<void> sendEmailCampaign({
    required String hid,
    required String campaignId,
  }) async {
    await _send(
      'SEND EMAIL CAMPAIGN',
      'POST',
      MarketingApiEndpoint.emailCampaignSend(campaignId),
      {'hid': hid},
    );
  }

  // ============================================================
  // EMAIL: CAMPAIGN DETAIL
  // ============================================================

  static Future<EmailCampaign?> getEmailCampaign({
    required String hid,
    required String id,
  }) async {
    final json = await _get(
      'EMAIL CAMPAIGN',
      _url(MarketingApiEndpoint.emailCampaign(id), {'hid': hid}),
      logBody: false,
    );

    final doc = _map(json['result'])['doc'];
    return doc is Map
        ? EmailCampaign.fromJson(Map<String, dynamic>.from(doc))
        : null;
  }

  static Future<({List<EmailCampaignRecipient> items, MarketingPage page})>
  getEmailCampaignRecipients({
    required String hid,
    required String id,
    required int page,
    int limit = 50,
    String status = '',
  }) async {
    final json = await _get(
      'EMAIL CAMPAIGN RECIPIENTS',
      _url(MarketingApiEndpoint.emailCampaignRecipients(id), {
        'hid': hid,
        'page': '$page',
        'limit': '$limit',
        'status': status,
      }),
    );

    final result = _map(json['result']);
    final list = result['doc'];

    return (
      items: list is List
          ? list
                .whereType<Map>()
                .map(
                  (e) => EmailCampaignRecipient.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : <EmailCampaignRecipient>[],
      page: MarketingPage.fromJson(result['pagination']),
    );
  }

  // ============================================================
  // EMAIL: TEMPLATES
  // ============================================================

  static Future<({List<EmailTemplate> items, MarketingPage page})>
  getEmailTemplates({
    required String hid,
    required int page,
    int limit = 12,
    String search = '',
  }) async {
    final json = await _get(
      'EMAIL TEMPLATES',
      _url(MarketingApiEndpoint.emailTemplates, {
        'hid': hid,
        'page': '$page',
        'limit': '$limit',
        'search': search.trim(),
      }),
      logBody: false,
    );

    final result = _map(json['result']);
    final list = result['doc'];

    return (
      items: list is List
          ? list
                .whereType<Map>()
                .map(
                  (e) => EmailTemplate.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : <EmailTemplate>[],
      page: MarketingPage.fromJson(result['pagination']),
    );
  }

  /// New or existing (update if there is an id). Answer: the saved template
  static Future<EmailTemplate> saveEmailTemplate({
    required String hid,
    required EmailTemplate template,
  }) async {
    final json = template.isSaved
        ? await _send(
            'UPDATE EMAIL TEMPLATE',
            'PATCH',
            _url(MarketingApiEndpoint.emailTemplate(template.id), {'hid': hid}),
            {'hid': hid, ...template.toPayload()},
          )
        : await _send(
            'CREATE EMAIL TEMPLATE',
            'POST',
            _url(MarketingApiEndpoint.emailTemplates, {'hid': hid}),
            {'hid': hid, ...template.toPayload()},
          );

    final doc = _map(_map(json['result'])['doc']);

    return doc.isEmpty
        ? template
        : EmailTemplate.fromJson(doc).copyWith(
            // If the server does not send html, keep ours
            html: '${doc['html'] ?? ''}'.isEmpty ? template.html : null,
          );
  }

  static Future<void> deleteEmailTemplate({
    required String hid,
    required String id,
  }) async {
    await _send(
      'DELETE EMAIL TEMPLATE',
      'DELETE',
      _url(MarketingApiEndpoint.emailTemplate(id), {'hid': hid}),
      {'hid': hid},
    );
  }

  /// Create an email with AI. If [previous] is given, it changes that one (refine).
  /// Can take 20-60 seconds.
  static Future<EmailTemplate> generateEmailTemplate({
    required String hid,
    required String prompt,
    required String tone,
    String brandName = '',
    String primaryColor = '',
    String logoUrl = '',
    String ctaText = '',
    String ctaUrl = '',
    EmailTemplate? previous,
  }) async {
    final json = await _send(
      'AI EMAIL TEMPLATE',
      'POST',
      _url(MarketingApiEndpoint.emailTemplateGenerate, {'hid': hid}),
      {
        'hid': hid,
        'prompt': prompt,
        'tone': tone,
        'brandName': brandName,
        'primaryColor': primaryColor,
        'logoUrl': logoUrl,
        'ctaText': ctaText,
        'ctaUrl': ctaUrl,
        if (previous != null)
          'previousTemplate': {
            'subject': previous.subject,
            'html': previous.html,
          },
      },
      timeout: const Duration(seconds: 120),
    );

    final doc = _map(_map(json['result'])['doc']);
    if ('${doc['html'] ?? ''}'.isEmpty) {
      throw Exception('The AI returned an empty template. Please try again.');
    }

    return EmailTemplate.fromJson(doc);
  }

  // ============================================================
  // COMMON: URL (with empty values removed)
  // ============================================================

  static String _url(String path, Map<String, String> query) => Uri(
    path: path,
    queryParameters: {
      for (final e in query.entries)
        if (e.value.isNotEmpty) e.key: e.value,
    },
  ).toString();

  static void _log(String tag, String endpoint, int status, String body) {
    debugPrint('');
    debugPrint('==================================================');
    debugPrint('📣 MARKETING: $tag API');
    debugPrint('==================================================');
    debugPrint('URL: ${BaseUrl.production2}$endpoint');
    debugPrint('STATUS: $status');
    debugPrint(
      'BODY: ${body.length > 1500 ? '${body.substring(0, 1500)}…' : body}',
    );
    debugPrint('==================================================');
  }

  static void _logError(String tag, Object e, StackTrace stackTrace) {
    debugPrint('');
    debugPrint('==================================================');
    debugPrint('❌ MARKETING: $tag API ERROR');
    debugPrint('==================================================');
    debugPrint('ERROR: $e');
    debugPrint('STACK: $stackTrace');
    debugPrint('==================================================');
  }

  // ============================================================
  // COMMON: POST / PATCH / DELETE + log + JSON
  // ============================================================

  static Future<Map<String, dynamic>> _send(
    String tag,
    String method,
    String endpoint,
    Map<String, dynamic> body, {
    Duration? timeout,
  }) async {
    try {
      final response = switch (method) {
        'PATCH' => await ApiClient.patch(
          endpoint,
          body: body,
          authenticated: true,
          baseUrl: BaseUrl.production2,
        ),
        'DELETE' => await ApiClient.delete(
          endpoint,
          body: body,
          authenticated: true,
          baseUrl: BaseUrl.production2,
        ),
        _ => await ApiClient.post(
          endpoint,
          body: body,
          authenticated: true,
          baseUrl: BaseUrl.production2,
          timeout: timeout,
        ),
      };

      _log(tag, endpoint, response.statusCode, response.body);

      final json = _map(jsonDecode(response.body));

      // Some APIs send success:false even with a 200
      if (json['success'] == false) {
        throw Exception(
          '${json['message'] ?? json['responseMessage'] ?? 'Request failed'}',
        );
      }

      return json;
    } catch (e, stackTrace) {
      _logError(tag, e, stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // COMMON: GET + log + JSON
  // ============================================================

  static Map<String, dynamic> _map(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  static Future<Map<String, dynamic>> _get(
    String tag,
    String endpoint, {
    bool logBody = true,
  }) async {
    try {
      final response = await ApiClient.get(
        endpoint,
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      debugPrint('');
      debugPrint('==================================================');
      debugPrint('📣 MARKETING: $tag API');
      debugPrint('==================================================');
      debugPrint('URL: ${BaseUrl.production2}$endpoint');
      debugPrint('STATUS: ${response.statusCode}');
      if (logBody) debugPrint('BODY: ${response.body}');
      debugPrint('==================================================');

      return _map(jsonDecode(response.body));
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('==================================================');
      debugPrint('❌ MARKETING: $tag API ERROR');
      debugPrint('==================================================');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('==================================================');

      rethrow;
    }
  }
}
