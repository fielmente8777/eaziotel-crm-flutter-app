// ============================================================
// MARKETING MODELS
//
//   WhatsappCampaign      : one line of the WhatsApp campaign list
//   CampaignRecipient     : one number of a campaign (sent / delivered / read ...)
//   EmailRecipient        : Email Marketing > Recipients
//   EmailCampaign         : Email Marketing > Campaigns
//   MarketingPage         : pagination (page, total, totalPages)
// ============================================================

int _int(dynamic v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;

String _str(dynamic v) {
  final text = v?.toString().trim() ?? '';
  return text == 'null' ? '' : text;
}

DateTime? _date(dynamic v) => DateTime.tryParse(_str(v))?.toLocal();

class MarketingPage {
  const MarketingPage({this.page = 1, this.total = 0, this.totalPages = 1});

  final int page;
  final int total;
  final int totalPages;

  bool get hasNext => page < totalPages;
  bool get hasPrevious => page > 1;

  factory MarketingPage.fromJson(dynamic json) => json is Map
      ? MarketingPage(
          page: _int(json['page']).clamp(1, 1 << 30),
          total: _int(json['total']),
          totalPages: _int(json['totalPages']).clamp(1, 1 << 30),
        )
      : const MarketingPage();
}

// ============================================================
// WHATSAPP
// ============================================================

class WhatsappCampaign {
  const WhatsappCampaign({
    required this.id,
    required this.name,
    required this.templateName,
    required this.status,
    required this.total,
    required this.sent,
    required this.delivered,
    required this.read,
    required this.failed,
    this.createdAt,
  });

  final String id;
  final String name;
  final String templateName;

  /// in-progress / completed / scheduled ...
  final String status;
  final int total;
  final int sent;
  final int delivered;
  final int read;
  final int failed;
  final DateTime? createdAt;

  factory WhatsappCampaign.fromJson(Map<String, dynamic> json) =>
      WhatsappCampaign(
        id: _str(json['_id']),
        name: _str(json['name']),
        templateName: _str(json['templateName']),
        status: _str(json['status']).toLowerCase(),
        total: _int(json['totalRecipients']),
        sent: _int(json['sentCount']),
        delivered: _int(json['deliveredCount']),
        read: _int(json['readCount']),
        failed: _int(json['failedCount']),
        createdAt: _date(json['createdAt']),
      );

  /// "7/7 (100%)"
  String get sentLabel {
    final percent = total == 0 ? 0 : (sent * 100 / total).round();
    return '$sent/$total ($percent%)';
  }

  int percentOf(int value) => total == 0 ? 0 : (value * 100 / total).round();
}

class CampaignRecipient {
  const CampaignRecipient({
    required this.phone,
    required this.name,
    required this.status,
    this.sentAt,
    this.deliveredAt,
    this.readAt,
    this.failedAt,
    this.error = '',
  });

  final String phone;
  final String name;

  /// pending / sent / delivered / read / failed
  final String status;
  final DateTime? sentAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final DateTime? failedAt;
  final String error;

  factory CampaignRecipient.fromJson(Map<String, dynamic> json) {
    final error = json['error'] ?? json['errorMessage'] ?? json['failedReason'];

    return CampaignRecipient(
      phone: _str(json['phone']),
      name: _str(json['name']),
      status: _str(json['status']).toLowerCase(),
      sentAt: _date(json['sentAt']),
      deliveredAt: _date(json['deliveredAt']),
      readAt: _date(json['readAt']),
      failedAt: _date(json['failedAt']),
      error: error is Map
          ? _str(error['message'] ?? error['title'])
          : _str(error),
    );
  }
}

// ============================================================
// EMAIL
// ============================================================

class EmailRecipient {
  const EmailRecipient({this.id = '', required this.name, required this.email});

  /// Lead id (needed when selecting and sending)
  final String id;
  final String name;
  final String email;

  factory EmailRecipient.fromJson(Map<String, dynamic> json) => EmailRecipient(
    id: _str(json['id'] ?? json['_id']),
    name: _str(json['name']),
    email: _str(json['email']),
  );
}

class EmailCampaign {
  const EmailCampaign({
    this.id = '',
    this.html = '',
    required this.subject,
    required this.status,
    required this.fromEmail,
    required this.recipientCount,
    required this.text,
    required this.stats,
    this.createdAt,
  });

  final String id;

  /// The full HTML of the email (preview in the detail)
  final String html;
  final String subject;
  final String status;
  final String fromEmail;
  final int recipientCount;

  /// Plain text of the email (for the preview)
  final String text;

  /// sent, delivered, failed, opened, clicked, unsubscribed
  final Map<String, int> stats;
  final DateTime? createdAt;

  int stat(String key) => stats[key] ?? 0;

  factory EmailCampaign.fromJson(Map<String, dynamic> json) {
    final raw = json['stats'];

    return EmailCampaign(
      id: _str(json['_id']),
      html: _str(json['html']),
      subject: _str(json['subject']).isNotEmpty
          ? _str(json['subject'])
          : _str(json['name']),
      status: _str(json['status']).toLowerCase(),
      fromEmail: _str(json['fromEmail']),
      recipientCount: _int(json['recipientCount']),
      // With empty lines and extra spaces removed
      text: _str(json['text'])
          .split(RegExp(r'\r?\n'))
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .join('\n'),
      stats: {
        if (raw is Map)
          for (final entry in raw.entries) '${entry.key}': _int(entry.value),
      },
      createdAt: _date(json['createdAt']),
    );
  }
}

/// One recipient of an email campaign (detail screen)
class EmailCampaignRecipient {
  const EmailCampaignRecipient({
    required this.email,
    required this.name,
    required this.status,
    this.sentAt,
    this.error = '',
  });

  final String email;
  final String name;

  /// pending / sending / sent / delivered / failed / opened / clicked
  final String status;
  final DateTime? sentAt;
  final String error;

  factory EmailCampaignRecipient.fromJson(Map<String, dynamic> json) {
    final error = json['error'];

    return EmailCampaignRecipient(
      email: _str(json['email']),
      name: _str(json['name']),
      status: _str(json['status']).toLowerCase(),
      sentAt: _date(json['sentAt']),
      error: error is Map
          ? _str(error['message'] ?? error['title'])
          : _str(error),
    );
  }
}

/// A saved / AI-made email template
class EmailTemplate {
  const EmailTemplate({
    this.id = '',
    required this.name,
    required this.subject,
    required this.html,
    this.previewText = '',
    this.prompt = '',
    this.updatedAt,
  });

  final String id;
  final String name;
  final String subject;
  final String html;
  final String previewText;

  /// The brief given to the AI (to regenerate / change it)
  final String prompt;
  final DateTime? updatedAt;

  bool get isSaved => id.isNotEmpty;

  factory EmailTemplate.fromJson(Map<String, dynamic> json) => EmailTemplate(
    id: _str(json['_id']),
    name: _str(json['name']),
    subject: _str(json['subject']),
    html: _str(json['html']),
    previewText: _str(json['previewText']),
    prompt: _str(json['prompt']),
    updatedAt: _date(json['updatedAt'] ?? json['createdAt']),
  );

  EmailTemplate copyWith({
    String? id,
    String? name,
    String? subject,
    String? html,
    String? previewText,
  }) => EmailTemplate(
    id: id ?? this.id,
    name: name ?? this.name,
    subject: subject ?? this.subject,
    html: html ?? this.html,
    previewText: previewText ?? this.previewText,
    prompt: prompt,
    updatedAt: updatedAt,
  );

  Map<String, dynamic> toPayload() => {
    'name': name.trim().isEmpty ? 'Untitled template' : name.trim(),
    'subject': subject.trim(),
    'previewText': previewText,
    'html': html,
    'prompt': prompt.trim(),
  };
}

/// Where the lead came from (audience of the WhatsApp campaign)
class LeadSource {
  const LeadSource(this.value, this.label);

  final String value;
  final String label;

  /// Same list as the web dashboard. '' = All sources
  static const all = [
    LeadSource('', 'All sources'),
    LeadSource('eazbot', 'Eazbot'),
    LeadSource('webform', 'Webform'),
    LeadSource('whatsapp', 'WhatsApp'),
    LeadSource('facebook', 'Facebook'),
    LeadSource('google', 'Google'),
    LeadSource('visitors', 'Visitors'),
    LeadSource('exotel', 'Exotel'),
    LeadSource('insta_ad_dm', 'Insta - Ad & DM'),
    LeadSource('front_desk', 'Front desk'),
    LeadSource('booking_engine', 'Booking Engine'),
    LeadSource('email', 'Email'),
  ];
}
