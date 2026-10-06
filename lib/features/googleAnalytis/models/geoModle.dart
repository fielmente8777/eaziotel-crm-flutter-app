// lib/features/googleAnalytis/models/geo_model.dart

int _i(dynamic v) => (v as num?)?.toInt() ?? 0;

class GeoModel {
  final List<GeoCountry> countries;
  final List<GeoCity> cities;

  const GeoModel({required this.countries, required this.cities});

  factory GeoModel.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> list(String k) =>
        ((json[k] as List?) ?? const []).whereType<Map<String, dynamic>>().toList();

    return GeoModel(
      countries: list('countries').map(GeoCountry.fromJson).toList(),
      cities: list('cities').map(GeoCity.fromJson).toList(),
    );
  }
}

class GeoCountry {
  final String country;
  final String countryCode;
  final int users;

  const GeoCountry({
    required this.country,
    required this.countryCode,
    required this.users,
  });

  factory GeoCountry.fromJson(Map<String, dynamic> json) => GeoCountry(
        country: (json['country'] ?? '').toString(),
        countryCode: (json['countryCode'] ?? '').toString().toUpperCase(),
        users: _i(json['users']),
      );
}

class GeoCity {
  final String city;
  final String country;
  final int users;

  const GeoCity({
    required this.city,
    required this.country,
    required this.users,
  });

  factory GeoCity.fromJson(Map<String, dynamic> json) => GeoCity(
        city: (json['city'] ?? '').toString().trim(),
        country: (json['country'] ?? '').toString(),
        users: _i(json['users']),
      );

  /// GA "(not set)" aur "" dono ko ek hi bucket me
  bool get isUnknown => city.isEmpty || city == '(not set)';

  String get label => isUnknown ? 'Unknown' : city;
}