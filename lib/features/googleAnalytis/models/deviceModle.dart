// lib/features/googleAnalytis/models/devices_model.dart

int _i(dynamic v) => (v as num?)?.toInt() ?? 0;

class DevicesModel {
  final List<DeviceItem> devices;
  final List<NameValue> browsers;
  final List<NameValue> operatingSystems;

  const DevicesModel({
    required this.devices,
    required this.browsers,
    required this.operatingSystems,
  });

  factory DevicesModel.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> list(String k) =>
        ((json[k] as List?) ?? const []).whereType<Map<String, dynamic>>().toList();

    return DevicesModel(
      devices: list('devices').map(DeviceItem.fromJson).toList(),
      browsers: list('browsers').map(NameValue.fromJson).toList(),
      operatingSystems:
          list('operatingSystems').map(NameValue.fromJson).toList(),
    );
  }
}

/// Browser / OS row
class NameValue {
  final String name;
  final int value;

  const NameValue({required this.name, required this.value});

  factory NameValue.fromJson(Map<String, dynamic> json) => NameValue(
        name: (json['name'] ?? '').toString(),
        value: _i(json['value']),
      );
}

/// Device row — `value` = users, `sessions` = sessions
class DeviceItem {
  final String name;
  final int value;
  final int sessions;

  const DeviceItem({
    required this.name,
    required this.value,
    required this.sessions,
  });

  factory DeviceItem.fromJson(Map<String, dynamic> json) => DeviceItem(
        name: (json['name'] ?? '').toString(),
        value: _i(json['value']),
        sessions: _i(json['sessions']),
      );
}