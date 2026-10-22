// ============================================================
// WHATSAPP ACCOUNT INFO (model)
//
// Takes what the screen needs from the answers of two APIs and keeps it
// in simple fields. The cards read only these fields.
//
//   account/connection/details -> waba, business, phoneNumber
//   whatsapp/profile           -> about, email, address, websites
//
// '-' is used for anything that is missing.
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
  final String profilePicture; // photo link ('' = no photo)
  final List<String> websites;

  /// [details] = `result.docs` of account/connection/details
  /// [profile] = `result.doc` of whatsapp/profile
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

  /// Empty Map if null / wrong type
  static Map<String, dynamic> _map(dynamic value) {
    return value is Map ? Map<String, dynamic>.from(value) : {};
  }

  /// '-' if null / empty
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
