// ============================================================
// MARKETING MODELS
//
//   WhatsappCampaign      : WhatsApp campaign list ki ek line
//   CampaignRecipient     : campaign ka ek number (sent / delivered / read ...)
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
  const EmailRecipient({required this.name, required this.email});

  final String name;
  final String email;

  factory EmailRecipient.fromJson(Map<String, dynamic> json) =>
      EmailRecipient(name: _str(json['name']), email: _str(json['email']));
}

class EmailCampaign {
  const EmailCampaign({
    required this.subject,
    required this.status,
    required this.fromEmail,
    required this.recipientCount,
    required this.text,
    required this.stats,
    this.createdAt,
  });

  final String subject;
  final String status;
  final String fromEmail;
  final int recipientCount;

  /// Email ka saada text (preview ke liye)
  final String text;

  /// sent, delivered, failed, opened, clicked, unsubscribed
  final Map<String, int> stats;
  final DateTime? createdAt;

  int stat(String key) => stats[key] ?? 0;

  factory EmailCampaign.fromJson(Map<String, dynamic> json) {
    final raw = json['stats'];

    return EmailCampaign(
      subject: _str(json['subject']).isNotEmpty
          ? _str(json['subject'])
          : _str(json['name']),
      status: _str(json['status']).toLowerCase(),
      fromEmail: _str(json['fromEmail']),
      recipientCount: _int(json['recipientCount']),
      // Khali lines aur extra spaces hata kar
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
