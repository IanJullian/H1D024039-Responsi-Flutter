import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_model.dart';

class StorageService {
  static const String _favoriteLocationsKey = 'favorite_locations';

  Future<List<LocationModel>> getFavoriteLocations() async {
    final preferences = await SharedPreferences.getInstance();

    final savedLocations =
        preferences.getStringList(_favoriteLocationsKey) ?? [];

    final favoriteLocations = <LocationModel>[];

    for (final savedLocation in savedLocations) {
      try {
        final decoded = jsonDecode(savedLocation);

        if (decoded is Map<String, dynamic>) {
          favoriteLocations.add(LocationModel.fromJson(decoded));
        }
      } on FormatException {
        // Abaikan data JSON yang tidak valid.
        continue;
      }
    }

    return favoriteLocations;
  }

  Future<void> saveFavoriteLocations(List<LocationModel> locations) async {
    final preferences = await SharedPreferences.getInstance();

    final encodedLocations = locations
        .map((location) => jsonEncode(location.toJson()))
        .toList();

    final saved = await preferences.setStringList(
      _favoriteLocationsKey,
      encodedLocations,
    );

    if (!saved) {
      throw StateError('Gagal menyimpan lokasi favorit.');
    }
  }
}
