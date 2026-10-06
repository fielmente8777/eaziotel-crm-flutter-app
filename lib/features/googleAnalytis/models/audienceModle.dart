// lib/features/googleAnalytis/models/audience_model.dart

int _i(dynamic v) => (v as num?)?.toInt() ?? 0;

class AudienceModel {
  final List<AudienceCountry> countries;
  final List<AudienceDevice> devices;

  const AudienceModel({required this.countries, required this.devices});

  factory AudienceModel.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> list(String k) =>
        ((json[k] as List?) ?? const []).whereType<Map<String, dynamic>>().toList();

    return AudienceModel(
      countries: list('countries').map(AudienceCountry.fromJson).toList(),
      devices: list('devices').map(AudienceDevice.fromJson).toList(),
    );
  }
}

class AudienceCountry {
  final String name;
  final int users;

  const AudienceCountry({required this.name, required this.users});

  factory AudienceCountry.fromJson(Map<String, dynamic> json) =>
      AudienceCountry(
        name: (json['name'] ?? '').toString(),
        users: _i(json['users']),
      );
}

class AudienceDevice {
  final String name;
  final int value;

  const AudienceDevice({required this.name, required this.value});

  factory AudienceDevice.fromJson(Map<String, dynamic> json) => AudienceDevice(
        name: (json['name'] ?? '').toString(),
        value: _i(json['value']),
      );
}