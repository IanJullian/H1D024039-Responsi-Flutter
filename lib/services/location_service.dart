import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/location_model.dart';
import 'api_exception.dart';

class LocationService {
  LocationService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const Duration _requestTimeout = Duration(seconds: 15);

  Future<List<LocationModel>> searchLocations(String query) async {
    final searchQuery = query.trim();

    if (searchQuery.length < 2) {
      return [];
    }

    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': searchQuery,
      'count': '10',
      'language': 'id',
      'format': 'json',
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
              : 'Pencarian lokasi gagal '
                    '(HTTP ${response.statusCode}).',
        );
      }

      if (decoded is! Map<String, dynamic>) {
        throw const ApiException(
          'Format respons pencarian lokasi tidak valid.',
        );
      }

      if (decoded['error'] == true) {
        throw ApiException(
          decoded['reason']?.toString() ??
              'Terjadi kesalahan pada Geocoding API.',
        );
      }

      final results = decoded['results'];

      if (results == null) {
        return [];
      }

      if (results is! List) {
        throw const ApiException('Data hasil pencarian lokasi tidak valid.');
      }

      return results
          .whereType<Map<String, dynamic>>()
          .map(LocationModel.fromJson)
          .toList();
    } on TimeoutException {
      throw const ApiException(
        'Pencarian lokasi melewati batas waktu. '
        'Silakan coba kembali.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Tidak dapat terhubung ke server lokasi. '
        'Periksa koneksi internet.',
      );
    } on FormatException {
      throw const ApiException('Respons Geocoding API bukan JSON yang valid.');
    } on ApiException {
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}
