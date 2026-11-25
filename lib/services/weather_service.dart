import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather_model.dart';
import 'api_exception.dart';

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const Duration _requestTimeout = Duration(seconds: 15);

  Future<WeatherModel> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,'
          'apparent_temperature,precipitation,'
          'weather_code,wind_speed_10m',
      'daily':
          'temperature_2m_max,temperature_2m_min,'
          'precipitation_probability_max,weather_code',
      'timezone': 'auto',
      'forecast_days': '7',
    });

    try {
      final response = await _client.get(uri).timeout(_requestTimeout);

      final dynamic decoded = jsonDecode(response.body);

      if (response.statusCode != 200) {
        final reason = decoded is Map<String, dynamic>
            ? decoded['reason']?.toString()
            : null;

        throw ApiException(
          reason != null && reason.isNotEmpty
              ? reason
              : 'Gagal mengambil data cuaca '
                    '(HTTP ${response.statusCode}).',
        );
      }

      if (decoded is! Map<String, dynamic>) {
        throw const ApiException('Format respons data cuaca tidak valid.');
      }

      if (decoded['error'] == true) {
        throw ApiException(
          decoded['reason']?.toString() ??
              'Terjadi kesalahan pada Weather API.',
        );
      }

      return WeatherModel.fromJson(decoded);
    } on TimeoutException {
      throw const ApiException(
        'Permintaan cuaca melewati batas waktu. '
        'Silakan coba kembali.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Tidak dapat terhubung ke server cuaca. '
        'Periksa koneksi internet.',
      );
    } on FormatException {
      throw const ApiException('Respons Weather API bukan JSON yang valid.');
    } on ApiException {
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}
