// ============================================================
// EMAIL COMPOSE CONTROLLER  (naya email likho aur bhejo)
//
// Web dashboard jaisa bhejna:
//   1. batch nahi hai -> "To" ke emails se batch banao
//   2. campaign banao (subject, HTML, attachments)
//   3. campaign bhejo
//
// Message: ya to apna likha text, ya template (AI / saved) ka HTML.
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

  /// Pehle se chune log (Recipients / Excel se). null = "To" se likho.
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

  /// Template laga hai to message box ki jagah iska HTML jaata hai
  final template = Rxn<EmailTemplate>();

  /// Attachment files ke raste
  final attachments = <String>[].obs;

  final isSending = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Hotel ka email pehle se bhar do (badal sakte ho)
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

  /// Saada text -> paragraph wala HTML
  static String textToHtml(String text) => text
      .trim()
      .split(RegExp(r'\n\s*\n'))
      .map((p) => '<p>${_escape(p.trim()).replaceAll('\n', '<br>')}</p>')
      .join();

  /// HTML -> saada text (email ka text version)
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

  /// Pehli galti (null = sab theek)
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

  /// true = queue me chala gaya. Galti ho to [onError].
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

      // 3. Bhejo
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
