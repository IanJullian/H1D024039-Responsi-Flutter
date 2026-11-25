import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/api_exception.dart';
import '../services/weather_service.dart';

class WeatherViewModel extends ChangeNotifier {
  WeatherViewModel(this._weatherService);

  final WeatherService _weatherService;

  LocationModel? _selectedLocation;
  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;

  LocationModel? get selectedLocation => _selectedLocation;

  WeatherModel? get weather => _weather;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  DateTime? get lastUpdated => _lastUpdated;

  bool get hasWeather => _weather != null;

  Future<void> fetchWeather(LocationModel location) async {
    final isSameLocation =
        _selectedLocation?.latitude == location.latitude &&
        _selectedLocation?.longitude == location.longitude;

    _selectedLocation = location;
    _isLoading = true;
    _errorMessage = null;

    if (!isSameLocation) {
      _weather = null;
      _lastUpdated = null;
    }

    notifyListeners();

    try {
      _weather = await _weatherService.fetchWeather(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      _lastUpdated = DateTime.now();
    } catch (error) {
      _errorMessage = _getErrorMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final location = _selectedLocation;

    if (location == null) {
      _errorMessage = 'Pilih lokasi terlebih dahulu.';
      notifyListeners();
      return;
    }

    await fetchWeather(location);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getErrorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return 'Terjadi kesalahan saat mengambil data cuaca.';
  }
}
