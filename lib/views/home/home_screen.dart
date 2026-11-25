import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/location_viewmodel.dart';
import '../../viewmodels/weather_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherViewModel = context.watch<WeatherViewModel>();
    final locationViewModel = context.watch<LocationViewModel>();

    final selectedLocation = weatherViewModel.selectedLocation;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.cloud_rounded,
                      size: 28,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'CuacaKu',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'Selamat datang!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Pantau kondisi cuaca dan prakiraan harian '
                'dari kota pilihanmu.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 28),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LOKASI TERPILIH',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedLocation?.displayName ??
                                  'Belum ada lokasi dipilih',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      if (weatherViewModel.isLoading) ...[
                        const SizedBox(height: 16),
                        const LinearProgressIndicator(),
                      ],
                      if (weatherViewModel.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          weatherViewModel.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surface,
                child: ListTile(
                  leading: Icon(
                    Icons.favorite_outline_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Lokasi favorit'),
                  subtitle: Text(
                    locationViewModel.isLoadingFavorites
                        ? 'Memuat lokasi favorit...'
                        : '${locationViewModel.favoriteLocations.length} '
                              'lokasi tersimpan',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),
              const Spacer(),
              Center(
                child: Text(
                  'Pencarian kota dan informasi cuaca '
                  'akan segera tersedia.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
