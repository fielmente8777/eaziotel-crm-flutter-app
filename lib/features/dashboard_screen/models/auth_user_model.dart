// ============================================================
// AUTH USER  (login kiya hua user: GET /user/user-details -> "User")
//
// Kaun kya dekh sakta hai (web dashboard jaisa):
//   isAdmin = true   -> account ki SAARI locations
//   isAdmin = false  -> sirf assigned_location wali locations
//   role = "owner"   -> upar se saare client accounts me switch kar sakta hai
// ============================================================

import 'package:eazotel/features/dashboard_screen/models/HotelIdProfileResponseModel%20.dart';

class AuthUserModel {
  const AuthUserModel({
    required this.role,
    required this.isAdmin,
    required this.assignedHids,
    this.displayName = '',
    this.email = '',
    this.phone = '',
  });

  /// owner / admin / user ...
  final String role;
  final bool isAdmin;

  /// Team member ko di gayi locations (hotel id)
  final List<String> assignedHids;
  final String displayName;
  final String email;
  final String phone;

  bool get isOwner => role.toLowerCase() == 'owner';

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    final assigned = json['assigned_location'];

    return AuthUserModel(
      role: '${json['role'] ?? ''}'.trim(),
      isAdmin: json['isAdmin'] == true,
      assignedHids: [
        if (assigned is List)
          for (final item in assigned)
            if (item is Map && '${item['hid'] ?? ''}'.trim().isNotEmpty)
              '${item['hid']}'.trim(),
      ],
      displayName: '${json['displayName'] ?? json['userName'] ?? ''}'.trim(),
      email: '${json['emailId'] ?? ''}'.trim(),
      phone: '${json['phone'] ?? ''}'.trim(),
    );
  }

  /// Ye user kaunsi locations khol sakta hai
  List<HotelModel> allowedHotels(List<HotelModel> all) {
    if (isAdmin) return all;
    return all.where((h) => assignedHids.contains(h.hotelId)).toList();
  }

  /// Kaunsi location kholein: pichhli baar wali (agar abhi bhi allowed),
  /// warna admin -> aakhri, team member -> pehli (web jaisa)
  HotelModel? pickHotel(List<HotelModel> allowed, String? savedHid) {
    if (allowed.isEmpty) return null;

    final saved = allowed.where((h) => h.hotelId == savedHid);
    if (saved.isNotEmpty) return saved.first;

    return isAdmin ? allowed.last : allowed.first;
  }
}

/// Owner ke liye ek client account (GET /admin/get-all-clients -> data[])
class ClientAccountModel {
  const ClientAccountModel({
    required this.hotelName,
    required this.hotelEmail,
    required this.ndid,
    required this.firstHotelId,
    required this.city,
    required this.state,
    required this.country,
  });

  final String hotelName;

  /// Isi email se switch hota hai
  final String hotelEmail;
  final String ndid;

  /// Switch ke baad yahi location khulti hai
  final String firstHotelId;
  final String city;
  final String state;
  final String country;

  String get place =>
      [city, state, country].where((e) => e.trim().isNotEmpty).join(', ');

  factory ClientAccountModel.fromJson(Map<String, dynamic> json) {
    final hotels = json['hotels'];
    final first = hotels is Map && hotels.isNotEmpty
        ? hotels.entries.first
        : null;
    final hotel = first?.value is Map ? first!.value as Map : const {};

    String s(dynamic v) {
      final text = '${v ?? ''}'.trim();
      return text == 'null' ? '' : text;
    }

    return ClientAccountModel(
      hotelName: s(json['hotelName']).isNotEmpty
          ? s(json['hotelName'])
          : s(hotel['local']),
      hotelEmail: s(json['hotelEmail']),
      ndid: s(json['ndid']),
      firstHotelId: first == null ? '' : '${first.key}',
      city: s(hotel['city']),
      state: s(hotel['state']),
      country: s(hotel['country']),
    );
  }

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [
      hotelName,
      city,
      state,
      country,
      hotelEmail,
    ].join(' ').toLowerCase().contains(q);
  }
}
