// ============================================================
// APP NOTIFICATION
//
// One notification (for now only a new WhatsApp message).
// Saved on the phone (SharedPreferences) so the list stays the same
// after closing and reopening the app. Cleared on logout.
// ============================================================

enum AppNotificationType { whatsapp }

class AppNotification {
  AppNotification({
    required this.id,
    required this.type,
    required this.hid,
    required this.conversationId,
    required this.title,
    required this.body,
    required this.phone,
    required this.createdAt,
    this.isRead = false,
  });

  /// Message id (one notification per message)
  final String id;
  final AppNotificationType type;

  /// Which hotel it belongs to (after changing hotel only that hotel's show)
  final String hid;

  /// Tapping opens this chat
  final String conversationId;

  /// The customer's name (or number)
  final String title;

  /// Text of the message
  final String body;
  final String phone;
  final DateTime createdAt;
  bool isRead;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: AppNotificationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => AppNotificationType.whatsapp,
      ),
      hid: json['hid']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      isRead: json['isRead'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'hid': hid,
    'conversationId': conversationId,
    'title': title,
    'body': body,
    'phone': phone,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
  };
}
