// ============================================================
// SEO ADDRESS
// Map par point chunne ke baad pata (OpenStreetMap reverse):
// GET https://nominatim.openstreetmap.org/reverse?lat=&lon=&format=json
//
//   address.city / town / county      -> city
//   address.suburb / neighbourhood    -> district
//   address.state, address.postcode
// ============================================================

import 'seo_common.dart';

class SeoAddress {
  final String city;
  final String district;
  final String state;
  final String pincode;

  const SeoAddress({
    this.city = '',
    this.district = '',
    this.state = '',
    this.pincode = '',
  });

  factory SeoAddress.fromJson(Map<String, dynamic> json) {
    final a = seoMap(json['address']);

    String first(List<String> keys) {
      for (final k in keys) {
        final v = seoStr(a[k]).trim();
        if (v.isNotEmpty) return v;
      }
      return '';
    }

    return SeoAddress(
      city: first(['city', 'town', 'county']),
      district: first(['suburb', 'neighbourhood', 'city_district', 'county']),
      state: first(['state']),
      pincode: first(['postcode']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'district': district,
      'state': state,
      'pincode': pincode,
    };
  }
}
