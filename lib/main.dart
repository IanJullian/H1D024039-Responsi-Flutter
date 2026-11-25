import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'services/location_service.dart';
import 'services/storage_service.dart';
import 'services/weather_service.dart';
import 'viewmodels/location_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const CuacaKuApp());
}

class CuacaKuApp extends StatelessWidget {
  const CuacaKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<WeatherService>(
          create: (_) => WeatherService(),
          dispose: (_, service) => service.dispose(),
        ),
        Provider<LocationService>(
          create: (_) => LocationService(),
          dispose: (_, service) => service.dispose(),
        ),
        Provider<StorageService>(create: (_) => StorageService()),
        ChangeNotifierProxyProvider<WeatherService, WeatherViewModel>(
          create: (context) => WeatherViewModel(context.read<WeatherService>()),
          update: (_, weatherService, previous) {
            return previous ?? WeatherViewModel(weatherService);
          },
        ),
        ChangeNotifierProxyProvider2<
          LocationService,
          StorageService,
          LocationViewModel
        >(
          create: (context) {
            final viewModel = LocationViewModel(
              context.read<LocationService>(),
              context.read<StorageService>(),
            );

            unawaited(viewModel.loadFavorites());

            return viewModel;
          },
          update: (_, locationService, storageService, previous) {
            return previous ??
                LocationViewModel(locationService, storageService);
          },
        ),
      ],
      child: MaterialApp(
        title: 'CuacaKu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeScreen(),
      ),
    );
  }
}
