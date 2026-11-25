import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../viewmodels/location_viewmodel.dart';
import '../../viewmodels/weather_viewmodel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  String _query = '';
  bool _isSelectingLocation = false;

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;
    });

    _debounce?.cancel();

    if (value.trim().length < 2) {
      context.read<LocationViewModel>().clearSearch();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;

      context.read<LocationViewModel>().searchLocations(value);
    });
  }

  void _submitSearch(String value) {
    final query = value.trim();

    if (query.length < 2) return;

    _debounce?.cancel();

    context.read<LocationViewModel>().searchLocations(query);
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();

    setState(() {
      _query = '';
    });

    context.read<LocationViewModel>().clearSearch();
  }

  Future<void> _selectLocation(LocationModel location) async {
    setState(() {
      _isSelectingLocation = true;
    });

    try {
      await context.read<WeatherViewModel>().fetchWeather(location);

      if (!mounted) return;

      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() {
          _isSelectingLocation = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite(LocationModel location) async {
    final locationViewModel = context.read<LocationViewModel>();

    await locationViewModel.toggleFavorite(location);

    if (!mounted) return;

    final errorMessage = locationViewModel.favoritesError;

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationViewModel = context.watch<LocationViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cari Lokasi')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Temukan Kota',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Cari kota untuk melihat informasi cuaca '
                    'terkini di lokasi pilihanmu.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    onSubmitted: _submitSearch,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Purwokerto',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              onPressed: _clearSearch,
                              icon: const Icon(Icons.close_rounded),
                              tooltip: 'Hapus pencarian',
                            )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (locationViewModel.isSearching) const LinearProgressIndicator(),
            if (_isSelectingLocation) const LinearProgressIndicator(),
            Expanded(child: _buildLocationContent(locationViewModel)),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationContent(LocationViewModel viewModel) {
    final isSearchingQuery = _query.trim().length >= 2;

    if (!isSearchingQuery) {
      return _buildLocationList(
        title: 'Lokasi Favorit',
        subtitle: 'Lokasi yang sudah kamu simpan.',
        locations: viewModel.favoriteLocations,
        viewModel: viewModel,
        isEmpty: viewModel.favoriteLocations.isEmpty,
      );
    }

    if (viewModel.searchError != null) {
      return _buildMessage(
        icon: Icons.wifi_off_rounded,
        title: 'Pencarian gagal',
        message: viewModel.searchError!,
      );
    }

    if (viewModel.isSearching && viewModel.searchResults.isEmpty) {
      return _buildMessage(
        icon: Icons.search_rounded,
        title: 'Mencari lokasi...',
        message: 'Sedang mengambil data dari Open-Meteo.',
      );
    }

    if (viewModel.searchResults.isEmpty) {
      return _buildMessage(
        icon: Icons.location_off_outlined,
        title: 'Kota tidak ditemukan',
        message: 'Coba gunakan nama kota yang berbeda.',
      );
    }

    return _buildLocationList(
      title: 'Hasil Pencarian',
      subtitle: '${viewModel.searchResults.length} lokasi ditemukan.',
      locations: viewModel.searchResults,
      viewModel: viewModel,
      isEmpty: false,
    );
  }

  Widget _buildLocationList({
    required String title,
    required String subtitle,
    required List<LocationModel> locations,
    required LocationViewModel viewModel,
    required bool isEmpty,
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        if (isEmpty)
          _buildMessage(
            icon: Icons.favorite_border_rounded,
            title: 'Belum ada lokasi favorit',
            message:
                'Cari kota terlebih dahulu, lalu tekan ikon hati '
                'untuk menyimpannya.',
          )
        else
          ...locations.map(
            (location) => _buildLocationCard(location, viewModel),
          ),
      ],
    );
  }

  Widget _buildLocationCard(
    LocationModel location,
    LocationViewModel viewModel,
  ) {
    final isFavorite = viewModel.isFavorite(location);

    final details = [
      if (location.admin1 != null && location.admin1!.isNotEmpty)
        location.admin1!,
      if (location.country != null && location.country!.isNotEmpty)
        location.country!,
    ].join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.location_on_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          location.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          details.isEmpty ? location.displayName : details,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          onPressed: _isSelectingLocation
              ? null
              : () => _toggleFavorite(location),
          tooltip: isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
          icon: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFavorite
                ? Colors.redAccent
                : Theme.of(context).colorScheme.primary,
          ),
        ),
        onTap: _isSelectingLocation ? null : () => _selectLocation(location),
      ),
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
