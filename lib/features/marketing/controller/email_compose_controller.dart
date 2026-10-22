// ============================================================
// EMAIL COMPOSE CONTROLLER  (write and send a new email)
//
// Sending works like the web dashboard:
//   1. no batch -> make a batch from the "To" emails
//   2. create the campaign (subject, HTML, attachments)
//   3. send the campaign
//
// Message: either your own text, or the HTML of a template (AI / saved).
// ============================================================

import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:get/get.dart';

import '../models/marketing_models.dart';
import '../services/email_import.dart';
import '../services/marketing_service.dart';

class EmailComposeController extends GetxController {
  EmailComposeController({
    this.batchId,
    this.recipientCount = 0,
    EmailTemplate? template,
  }) {
    if (template != null) useTemplate(template);
  }

  /// People already chosen (Recipients / from Excel). null = type them in "To".
  final String? batchId;
  final int recipientCount;

  bool get hasBatch => batchId != null && batchId!.isNotEmpty;

  final DashboardController dashboard = Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());

  String get hid => dashboard.selectedHotelId.value;

  // ============================================================
  // FORM
  // ============================================================

  final from = ''.obs;
  final fromName = ''.obs;
  final to = ''.obs;
  final subject = ''.obs;
  final message = ''.obs;

  /// If a template is applied, its HTML is sent instead of the message box
  final template = Rxn<EmailTemplate>();

  /// Paths of the attachment files
  final attachments = <String>[].obs;

  final isSending = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Pre-fill the hotel's email (you can change it)
    final hotelEmail = dashboard.user.value?.profile.hotelEmail.trim() ?? '';
    if (EmailImport.isEmail(hotelEmail)) from.value = hotelEmail.toLowerCase();
  }

  void useTemplate(EmailTemplate value) {
    template.value = value;
    if (subject.value.trim().isEmpty && value.subject.isNotEmpty) {
      subject.value = value.subject;
    }
  }

  void removeTemplate() => template.value = null;

  /// "a@x.com, b@y.com; c@z.com" -> list
  static List<String> parseEmails(String value) => value
      .split(RegExp(r'[,;\s]+'))
      .map((e) => e.trim().toLowerCase())
      .where((e) => e.isNotEmpty)
      .toSet()
      .toList();

  // ============================================================
  // MESSAGE -> HTML
  // ============================================================

  static String _escape(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');

  /// Plain text -> HTML with paragraphs
  static String textToHtml(String text) => text
      .trim()
      .split(RegExp(r'\n\s*\n'))
      .map((p) => '<p>${_escape(p.trim()).replaceAll('\n', '<br>')}</p>')
      .join();

  /// HTML -> plain text (the text version of the email)
  static String htmlToText(String html) => html
      .replaceAll(
        RegExp(
          r'<(script|style)[^>]*>.*?</\1>',
          dotAll: true,
          caseSensitive: false,
        ),
        '',
      )
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</(p|div|h\d|li|tr)>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .replaceAll(RegExp(r'\n\s*\n+'), '\n\n')
      .trim();

  String get html => template.value?.html ?? textToHtml(message.value);

  // ============================================================
  // CHECK
  // ============================================================

  /// First error (null = all good)
  String? get problem {
    final fromEmail = from.value.trim();
    if (fromEmail.isEmpty) return 'Please enter the From email.';
    if (!EmailImport.isEmail(fromEmail)) {
      return 'Invalid From email: $fromEmail';
    }

    if (!hasBatch) {
      final list = parseEmails(to.value);
      if (list.isEmpty) return 'Please enter at least one recipient email.';
      final bad = list.where((e) => !EmailImport.isEmail(e)).toList();
      if (bad.isNotEmpty) return 'Invalid recipient email: ${bad.join(', ')}';
    }

    if (subject.value.trim().isEmpty) return 'Please enter a subject.';

    if (template.value == null && message.value.trim().isEmpty) {
      return 'Please write your message or pick a template.';
    }

    return null;
  }

  // ============================================================
  // SEND
  // ============================================================

  /// true = added to the queue. On error, [onError].
  Future<bool> send({required void Function(String) onError}) async {
    if (isSending.value) return false;

    final issue = problem;
    if (issue != null) {
      onError(issue);
      return false;
    }

    isSending.value = true;

    try {
      // 1. Batch
      var id = batchId ?? '';
      if (id.isEmpty) {
        final batch = await MarketingService.createBatchFromEmails(
          hid: hid,
          emails: parseEmails(to.value),
        );
        id = batch.batchId;
      }
      if (id.isEmpty) {
        onError('Could not prepare recipients.');
        return false;
      }

      // 2. Campaign
      final body = html;
      final campaignId = await MarketingService.createEmailCampaign(
        hid: hid,
        name: subject.value.trim(),
        subject: subject.value.trim(),
        html: body,
        text: htmlToText(body),
        fromEmail: from.value.trim().toLowerCase(),
        fromName: fromName.value.trim(),
        batchIds: [id],
        attachmentPaths: attachments.toList(),
      );
      if (campaignId.isEmpty) {
        onError('Could not create the campaign.');
        return false;
      }

      // 3. Send
      await MarketingService.sendEmailCampaign(
        hid: hid,
        campaignId: campaignId,
      );
      return true;
    } catch (e) {
      onError(
        MarketingService.errorText(e, 'Could not send. Please try again.'),
      );
      return false;
    } finally {
      isSending.value = false;
    }
  }
}
