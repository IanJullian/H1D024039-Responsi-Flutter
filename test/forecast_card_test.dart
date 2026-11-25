import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cuacaku/models/weather_model.dart';
import 'package:cuacaku/widgets/forecast_card.dart';

void main() {
  const forecast = DailyWeather(
    time: ['2026-11-25', '2026-11-26'],
    temperature2mMax: [31.0, 29.0],
    temperature2mMin: [23.0, 22.0],
    precipitationProbabilityMax: [20, 70],
    weatherCode: [0, 61],
  );

  testWidgets('ForecastCard menampilkan data prakiraan cuaca', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ForecastCard(forecast: forecast)),
      ),
    );

    expect(find.text('Prakiraan 7 Hari'), findsOneWidget);
    expect(find.text('Cerah'), findsOneWidget);
    expect(find.text('Hujan'), findsOneWidget);
    expect(find.text('31° / 23°'), findsOneWidget);
    expect(find.text('29° / 22°'), findsOneWidget);
    expect(find.text('70%'), findsOneWidget);
  });

  testWidgets('ForecastCard menangani data prakiraan kosong', (
    WidgetTester tester,
  ) async {
    const emptyForecast = DailyWeather(
      time: [],
      temperature2mMax: [],
      temperature2mMin: [],
      precipitationProbabilityMax: [],
      weatherCode: [],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ForecastCard(forecast: emptyForecast)),
      ),
    );

    expect(find.text('Data prakiraan cuaca belum tersedia.'), findsOneWidget);
  });
}
