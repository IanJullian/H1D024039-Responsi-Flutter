import 'package:flutter/material.dart';

import '../core/constants/weather_condition.dart';
import '../models/weather_model.dart';

class ForecastCard extends StatelessWidget {
  const ForecastCard({super.key, required this.forecast});

  final DailyWeather forecast;

  static const List<String> _weekdays = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  String _formatWeekday(String value) {
    final date = DateTime.tryParse(value);

    if (date == null) {
      return '--';
    }

    return _weekdays[date.weekday - 1];
  }

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);

    if (date == null) {
      return '--';
    }

    return '${date.day} ${_months[date.month - 1]}';
  }

  String _formatTemperature(double? value) {
    if (value == null) {
      return '--°';
    }

    return '${value.toStringAsFixed(0)}°';
  }

  double? _getDouble(List<double?> values, int index) {
    if (index >= values.length) {
      return null;
    }

    return values[index];
  }

  int? _getInt(List<int?> values, int index) {
    if (index >= values.length) {
      return null;
    }

    return values[index];
  }

  Widget _buildForecastItem(BuildContext context, int index) {
    final weatherCode = _getInt(forecast.weatherCode, index);

    final condition = WeatherCondition.fromCode(weatherCode);

    final maximumTemperature = _getDouble(forecast.temperature2mMax, index);

    final minimumTemperature = _getDouble(forecast.temperature2mMin, index);

    final precipitationProbability = _getInt(
      forecast.precipitationProbabilityMax,
      index,
    );

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 132,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatWeekday(forecast.time[index]),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            _formatDate(forecast.time[index]),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Icon(condition.icon, size: 34, color: colorScheme.primary),
          Text(
            condition.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          Text(
            '${_formatTemperature(maximumTemperature)} / '
            '${_formatTemperature(minimumTemperature)}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.water_drop_outlined,
                size: 15,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                precipitationProbability == null
                    ? '--%'
                    : '$precipitationProbability%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (forecast.time.isEmpty) {
      return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Data prakiraan cuaca belum tersedia.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Prakiraan 7 Hari', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(
          'Perkiraan kondisi cuaca beberapa hari ke depan.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: forecast.time.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: _buildForecastItem,
          ),
        ),
      ],
    );
  }
}
