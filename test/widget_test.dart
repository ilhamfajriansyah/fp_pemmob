import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_belanja/main.dart';
import 'package:catatan_belanja/services/storage_services.dart';

void main() {
  group('Catatan Belanja App Tests', () {
    setUpAll(() async {
      // Initialize SQLite for testing
      await StorageService.init();
    });

    testWidgets('App should start and show home screen', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const MyApp());

      // Wait for async operations to complete
      await tester.pumpAndSettle();

      // Verify that the app title is displayed
      expect(find.text('Catatan Belanja'), findsOneWidget);

      // Verify that the total shopping card is displayed
      expect(find.text('Total Belanja'), findsOneWidget);

      // Verify that the empty state is shown initially
      expect(find.text('Belum ada barang'), findsOneWidget);

      // Verify that the floating action button is present
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Should navigate to add item screen when FAB is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Tap the floating action button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify that we navigated to the add item screen
      expect(find.text('Tambah Barang'), findsOneWidget);
      expect(find.text('Nama Barang'), findsOneWidget);
      expect(find.text('Jumlah'), findsOneWidget);
      expect(find.text('Harga Satuan (Rp)'), findsOneWidget);
    });
  });
}
