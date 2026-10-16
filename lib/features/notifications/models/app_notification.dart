// ============================================================
// APP NOTIFICATION
//
// Ek notification (abhi sirf WhatsApp ka naya message).
// Phone me save hota hai (SharedPreferences) taaki app band karke
// kholne par bhi list wahi rahe. Logout par saaf ho jaata hai.
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

  /// Message ki id (ek message ki ek hi notification)
  final String id;
  final AppNotificationType type;

  /// Kis hotel ki hai (hotel badalne par sirf usi ki dikhti hain)
  final String hid;

  /// Tap karne par yahi chat khulti hai
  final String conversationId;

  /// Customer ka naam (ya number)
  final String title;

  /// Message ka text
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
