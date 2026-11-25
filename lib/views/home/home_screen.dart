import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/weather_condition.dart';
import '../../models/weather_model.dart';
import '../../viewmodels/location_viewmodel.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../../widgets/forecast_card.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openSearch(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const SearchScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final weatherViewModel = context.watch<WeatherViewModel>();
    final locationViewModel = context.watch<LocationViewModel>();

    final weather = weatherViewModel.weather;
    final selectedLocation = weatherViewModel.selectedLocation;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                  Expanded(
                    child: Text(
                      'CuacaKu',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => _openSearch(context),
                    icon: const Icon(Icons.search_rounded),
                    tooltip: 'Cari lokasi',
                  ),
                ],
              ),
              const SizedBox(height: 36),
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _openSearch(context),
                  icon: const Icon(Icons.location_searching_rounded),
                  label: const Text('Cari kota'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: weatherViewModel.refresh,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Coba lagi'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (weather != null) ...[
                const SizedBox(height: 20),
                _buildWeatherCard(context, weather),
                const SizedBox(height: 24),
                ForecastCard(forecast: weather.daily),
              ],
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surface,
                child: ListTile(
                  onTap: () => _openSearch(context),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard(BuildContext context, WeatherModel weather) {
    final current = weather.current;
    final condition = WeatherCondition.fromCode(current.weatherCode);

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CUACA SAAT INI',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  condition.icon,
                  size: 56,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${current.temperature2m?.toStringAsFixed(1) ?? '--'}°C',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      Text(
                        condition.description,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Terasa seperti '
                        '${current.apparentTemperature?.toStringAsFixed(1) ?? '--'}°C',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            Wrap(
              spacing: 20,
              runSpacing: 16,
              children: [
                _buildWeatherMetric(
                  context,
                  Icons.water_drop_outlined,
                  'Kelembapan',
                  '${current.relativeHumidity2m ?? '--'}%',
                ),
                _buildWeatherMetric(
                  context,
                  Icons.air_rounded,
                  'Kecepatan angin',
                  '${current.windSpeed10m?.toStringAsFixed(1) ?? '--'} km/j',
                ),
                _buildWeatherMetric(
                  context,
                  Icons.grain_rounded,
                  'Curah hujan',
                  '${current.precipitation?.toStringAsFixed(1) ?? '--'} mm',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherMetric(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return SizedBox(
      width: 125,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 3),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
