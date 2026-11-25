class WeatherModel {
  final double latitude;
  final double longitude;
  final String timezone;
  final CurrentWeather current;
  final DailyWeather daily;

  const WeatherModel({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.current,
    required this.daily,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final currentData = json['current'];
    final dailyData = json['daily'];

    return WeatherModel(
      latitude: _toDouble(json['latitude']) ?? 0.0,
      longitude: _toDouble(json['longitude']) ?? 0.0,
      timezone: json['timezone']?.toString() ?? 'Unknown',
      current: CurrentWeather.fromJson(
        currentData is Map<String, dynamic> ? currentData : <String, dynamic>{},
      ),
      daily: DailyWeather.fromJson(
        dailyData is Map<String, dynamic> ? dailyData : <String, dynamic>{},
      ),
    );
  }
}

class CurrentWeather {
  final String? time;
  final double? temperature2m;
  final int? relativeHumidity2m;
  final double? apparentTemperature;
  final double? precipitation;
  final int? weatherCode;
  final double? windSpeed10m;

  const CurrentWeather({
    this.time,
    this.temperature2m,
    this.relativeHumidity2m,
    this.apparentTemperature,
    this.precipitation,
    this.weatherCode,
    this.windSpeed10m,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      time: json['time']?.toString(),
      temperature2m: _toDouble(json['temperature_2m']),
      relativeHumidity2m: _toInt(json['relative_humidity_2m']),
      apparentTemperature: _toDouble(json['apparent_temperature']),
      precipitation: _toDouble(json['precipitation']),
      weatherCode: _toInt(json['weather_code']),
      windSpeed10m: _toDouble(json['wind_speed_10m']),
    );
  }
}

class DailyWeather {
  final List<String> time;
  final List<double?> temperature2mMax;
  final List<double?> temperature2mMin;
  final List<int?> precipitationProbabilityMax;
  final List<int?> weatherCode;

  const DailyWeather({
    required this.time,
    required this.temperature2mMax,
    required this.temperature2mMin,
    required this.precipitationProbabilityMax,
    required this.weatherCode,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    return DailyWeather(
      time: _toStringList(json['time']),
      temperature2mMax: _toDoubleList(json['temperature_2m_max']),
      temperature2mMin: _toDoubleList(json['temperature_2m_min']),
      precipitationProbabilityMax: _toIntList(
        json['precipitation_probability_max'],
      ),
      weatherCode: _toIntList(json['weather_code']),
    );
  }
}

// Helper untuk mengolah nilai numerik dari JSON.

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

// Helper untuk mengolah data berbentuk list.

List<String> _toStringList(dynamic value) {
  if (value is! List) {
    return <String>[];
  }

  return value.map((item) => item.toString()).toList();
}

List<double?> _toDoubleList(dynamic value) {
  if (value is! List) {
    return <double?>[];
  }

  return value.map((item) => _toDouble(item)).toList();
}

List<int?> _toIntList(dynamic value) {
  if (value is! List) {
    return <int?>[];
  }

  return value.map((item) => _toInt(item)).toList();
}
