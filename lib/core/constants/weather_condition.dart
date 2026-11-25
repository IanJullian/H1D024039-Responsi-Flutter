import 'package:flutter/material.dart';

class WeatherCondition {
  const WeatherCondition({required this.description, required this.icon});

  final String description;
  final IconData icon;

  factory WeatherCondition.fromCode(int? code) {
    switch (code) {
      case 0:
        return const WeatherCondition(
          description: 'Cerah',
          icon: Icons.wb_sunny_rounded,
        );

      case 1:
        return const WeatherCondition(
          description: 'Cerah berawan',
          icon: Icons.wb_cloudy_rounded,
        );

      case 2:
        return const WeatherCondition(
          description: 'Berawan sebagian',
          icon: Icons.cloud_queue_rounded,
        );

      case 3:
        return const WeatherCondition(
          description: 'Mendung',
          icon: Icons.cloud_rounded,
        );

      case 45:
      case 48:
        return const WeatherCondition(
          description: 'Kabut',
          icon: Icons.blur_on_rounded,
        );

      case 51:
      case 53:
      case 55:
        return const WeatherCondition(
          description: 'Gerimis',
          icon: Icons.grain_rounded,
        );

      case 56:
      case 57:
        return const WeatherCondition(
          description: 'Gerimis beku',
          icon: Icons.ac_unit_rounded,
        );

      case 61:
      case 63:
      case 65:
        return const WeatherCondition(
          description: 'Hujan',
          icon: Icons.water_drop_rounded,
        );

      case 66:
      case 67:
        return const WeatherCondition(
          description: 'Hujan beku',
          icon: Icons.ac_unit_rounded,
        );

      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return const WeatherCondition(
          description: 'Salju',
          icon: Icons.cloud_rounded,
        );

      case 80:
      case 81:
      case 82:
        return const WeatherCondition(
          description: 'Hujan lokal',
          icon: Icons.grain_rounded,
        );

      case 95:
      case 97:
        return const WeatherCondition(
          description: 'Badai petir',
          icon: Icons.flash_on_rounded,
        );

      case 96:
      case 99:
        return const WeatherCondition(
          description: 'Badai petir disertai hujan es',
          icon: Icons.flash_on_rounded,
        );

      default:
        return const WeatherCondition(
          description: 'Kondisi tidak diketahui',
          icon: Icons.help_outline_rounded,
        );
    }
  }
}
