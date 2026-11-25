class LocationModel {
  final int? id;
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? admin1;
  final String? timezone;

  const LocationModel({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
    this.timezone,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? 'Unknown',
      latitude: _toDouble(json['latitude']) ?? 0.0,
      longitude: _toDouble(json['longitude']) ?? 0.0,
      country: json['country']?.toString(),
      admin1: json['admin1']?.toString(),
      timezone: json['timezone']?.toString(),
    );
  }

  // Nama lengkap lokasi untuk ditampilkan pada UI.
  String get displayName {
    final parts = <String>[name];

    if (admin1 != null && admin1!.isNotEmpty) {
      parts.add(admin1!);
    }

    if (country != null && country!.isNotEmpty) {
      parts.add(country!);
    }

    return parts.join(', ');
  }

  // Mengubah objek lokasi menjadi JSON untuk penyimpanan lokal.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'admin1': admin1,
      'timezone': timezone,
    };
  }
}

double? _toDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value?.toString() ?? '');
}

int? _toInt(dynamic value) {
  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '');
}
