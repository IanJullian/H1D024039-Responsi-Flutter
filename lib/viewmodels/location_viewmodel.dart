import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../services/api_exception.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';

class LocationViewModel extends ChangeNotifier {
  LocationViewModel(this._locationService, this._storageService);

  final LocationService _locationService;
  final StorageService _storageService;

  List<LocationModel> _searchResults = [];
  List<LocationModel> _favoriteLocations = [];

  bool _isSearching = false;
  bool _isLoadingFavorites = false;

  String? _searchError;
  String? _favoritesError;

  int _searchRequestId = 0;

  List<LocationModel> get searchResults => _searchResults;

  List<LocationModel> get favoriteLocations => _favoriteLocations;

  bool get isSearching => _isSearching;

  bool get isLoadingFavorites => _isLoadingFavorites;

  String? get searchError => _searchError;

  String? get favoritesError => _favoritesError;

  bool get hasSearchResults => _searchResults.isNotEmpty;

  Future<void> loadFavorites() async {
    _isLoadingFavorites = true;
    _favoritesError = null;

    notifyListeners();

    try {
      _favoriteLocations = await _storageService.getFavoriteLocations();
    } catch (error) {
      _favoritesError = _getErrorMessage(error);
    } finally {
      _isLoadingFavorites = false;
      notifyListeners();
    }
  }

  Future<void> searchLocations(String query) async {
    final searchQuery = query.trim();

    if (searchQuery.length < 2) {
      clearSearch();
      return;
    }

    final requestId = ++_searchRequestId;

    _isSearching = true;
    _searchError = null;
    _searchResults = [];

    notifyListeners();

    try {
      final results = await _locationService.searchLocations(searchQuery);

      if (requestId != _searchRequestId) {
        return;
      }

      _searchResults = results;
    } catch (error) {
      if (requestId != _searchRequestId) {
        return;
      }

      _searchResults = [];
      _searchError = _getErrorMessage(error);
    } finally {
      if (requestId == _searchRequestId) {
        _isSearching = false;
        notifyListeners();
      }
    }
  }

  void clearSearch() {
    _searchRequestId++;
    _searchResults = [];
    _searchError = null;
    _isSearching = false;

    notifyListeners();
  }

  bool isFavorite(LocationModel location) {
    return _favoriteLocations.any(
      (favorite) => _isSameLocation(favorite, location),
    );
  }

  Future<void> toggleFavorite(LocationModel location) async {
    final updatedFavorites = List<LocationModel>.from(_favoriteLocations);

    if (isFavorite(location)) {
      updatedFavorites.removeWhere(
        (favorite) => _isSameLocation(favorite, location),
      );
    } else {
      updatedFavorites.add(location);
    }

    try {
      await _storageService.saveFavoriteLocations(updatedFavorites);

      _favoriteLocations = updatedFavorites;
      _favoritesError = null;
    } catch (error) {
      _favoritesError = _getErrorMessage(error);
    }

    notifyListeners();
  }

  Future<void> removeFavorite(LocationModel location) async {
    final updatedFavorites = List<LocationModel>.from(_favoriteLocations);

    updatedFavorites.removeWhere(
      (favorite) => _isSameLocation(favorite, location),
    );

    try {
      await _storageService.saveFavoriteLocations(updatedFavorites);

      _favoriteLocations = updatedFavorites;
      _favoritesError = null;
    } catch (error) {
      _favoritesError = _getErrorMessage(error);
    }

    notifyListeners();
  }

  bool _isSameLocation(LocationModel first, LocationModel second) {
    if (first.id != null && second.id != null) {
      return first.id == second.id;
    }

    const tolerance = 0.000001;

    return first.name == second.name &&
        (first.latitude - second.latitude).abs() < tolerance &&
        (first.longitude - second.longitude).abs() < tolerance;
  }

  String _getErrorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return error.toString();
  }
}
