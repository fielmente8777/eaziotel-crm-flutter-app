// ============================================================
// WHATSAPP ACCOUNT INFO (model)
//
// Do API ke jawab se screen ke kaam ki cheezein nikal kar
// seedhe-saade fields me rakhta hai. Cards sirf in fields ko padhte hain.
//
//   account/connection/details -> waba, business, phoneNumber
//   whatsapp/profile           -> about, email, address, websites
//
// Jo cheez na mile uski jagah '-' aata hai.
// ============================================================

class WhatsappAccountInfo {
  const WhatsappAccountInfo({
    this.accountName = '-',
    this.wabaId = '-',
    this.businessId = '-',
    this.phoneNumber = '-',
    this.verifiedName = '-',
    this.qualityRating = '-',
    this.platform = '-',
    this.accountMode = '-',
    this.about = '-',
    this.email = '-',
    this.address = '-',
    this.industry = '-',
    this.profilePicture = '',
    this.websites = const [],
  });

  // ---------- WhatsApp Business Account card ----------
  final String accountName; // "Eazotel Tech"
  final String wabaId;
  final String businessId;

  // ---------- Phone Number card ----------
  final String phoneNumber; // "+91 97593 49941"
  final String verifiedName; // "Eazotel"
  final String qualityRating; // "Green"
  final String platform; // "CLOUD_API"
  final String accountMode; // "LIVE"

  // ---------- WhatsApp Business Profile card ----------
  final String about;
  final String email;
  final String address;
  final String industry; // "PROF_SERVICES"
  final String profilePicture; // photo ka link ('' = photo nahi)
  final List<String> websites;

  /// [details] = account/connection/details ka `result.docs`
  /// [profile] = whatsapp/profile ka `result.doc`
  factory WhatsappAccountInfo.fromJson({
    required Map<String, dynamic> details,
    required Map<String, dynamic> profile,
  }) {
    final waba = _map(details['waba']);
    final business = _map(details['business']);
    final phone = _map(details['phoneNumber']);

    final websites = profile['websites'];

    return WhatsappAccountInfo(
      accountName: _text(waba['name']),
      wabaId: _text(waba['id']),
      businessId: _text(business['id']),
      phoneNumber: _text(phone['displayPhoneNumber']),
      verifiedName: _text(phone['verifiedName']),
      qualityRating: _capitalize(_text(phone['qualityRating'])),
      platform: _text(phone['platformType']),
      accountMode: _text(phone['accountMode']),
      about: _text(profile['about']),
      email: _text(profile['email']),
      address: _text(profile['address']),
      industry: _text(profile['vertical']),
      profilePicture: profile['profile_picture_url']?.toString() ?? '',
      websites: websites is List
          ? websites.map((e) => e.toString()).toList()
          : [],
    );
  }

  /// null / galat type ho to khali Map
  static Map<String, dynamic> _map(dynamic value) {
    return value is Map ? Map<String, dynamic>.from(value) : {};
  }

  /// null / khali ho to '-'
  static String _text(dynamic value) {
    final text = value?.toString().trim() ?? '';

    return text.isEmpty ? '-' : text;
  }

  /// "GREEN" -> "Green"
  static String _capitalize(String text) {
    if (text.length < 2) return text;

    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
