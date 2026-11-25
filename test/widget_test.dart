import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cuacaku/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('CuacaKu menampilkan halaman Home', (WidgetTester tester) async {
    await tester.pumpWidget(const CuacaKuApp());

    await tester.pumpAndSettle();

    expect(find.text('CuacaKu'), findsOneWidget);
    expect(find.text('Selamat datang!'), findsOneWidget);
    expect(find.text('Belum ada lokasi dipilih'), findsOneWidget);
  });

  testWidgets('Pengguna dapat membuka halaman pencarian lokasi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CuacaKuApp());

    await tester.pumpAndSettle();

    await tester.tap(find.text('Cari kota'));
    await tester.pumpAndSettle();

    expect(find.text('Cari Lokasi'), findsOneWidget);
    expect(find.text('Temukan Kota'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
