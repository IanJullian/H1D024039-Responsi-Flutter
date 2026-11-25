import 'package:flutter_test/flutter_test.dart';
import 'package:cuacaku/core/constants/weather_condition.dart';

void main() {
  group('WeatherCondition', () {
    test('Kode 0 menampilkan kondisi cerah', () {
      final condition = WeatherCondition.fromCode(0);

      expect(condition.description, 'Cerah');
    });

    test('Kode 3 menampilkan kondisi mendung', () {
      final condition = WeatherCondition.fromCode(3);

      expect(condition.description, 'Mendung');
    });

    test('Kode 61 menampilkan kondisi hujan', () {
      final condition = WeatherCondition.fromCode(61);

      expect(condition.description, 'Hujan');
    });

    test('Kode 95 menampilkan kondisi badai petir', () {
      final condition = WeatherCondition.fromCode(95);

      expect(condition.description, 'Badai petir');
    });

    test('Kode tidak dikenal menampilkan kondisi default', () {
      final condition = WeatherCondition.fromCode(999);

      expect(condition.description, 'Kondisi tidak diketahui');
    });

    test('Kode null ditangani dengan aman', () {
      final condition = WeatherCondition.fromCode(null);

      expect(condition.description, 'Kondisi tidak diketahui');
    });
  });
}
