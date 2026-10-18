import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyberpulse_store/providers/store_provider.dart';
import 'package:cyberpulse_store/services/supabase_config.dart';
import 'package:cyberpulse_store/services/database_service.dart';
import 'package:cyberpulse_store/widgets/database_uplink_modal.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('SupabaseConfig & DatabaseService Unit Tests', () {
    test('SupabaseConfig defaults to fallbackLocal when no credentials are provided', () async {
      await SupabaseConfig.clearCredentials();
      final connected = await SupabaseConfig.initialize();

      expect(connected, isFalse);
      expect(SupabaseConfig.state, equals(SupabaseConnectionState.fallbackLocal));
      expect(SupabaseConfig.isConnected, isFalse);
      expect(SupabaseConfig.client, isNull);
    });

    test('DatabaseService provides fallback products when running offline', () async {
      final db = DatabaseService();
      final products = await db.getProducts();

      expect(products, isNotEmpty);
      expect(products.first.name, isNotEmpty);
      expect(products.first.price, greaterThan(0));
    });

    test('DatabaseService provides fallback categories when running offline', () async {
      final db = DatabaseService();
      final categories = await db.getCategories();

      expect(categories, isNotEmpty);
      expect(categories.any((c) => c.name == 'Laptops'), isTrue);
    });

    test('DatabaseService provides fallback orders and inventory logs', () async {
      final db = DatabaseService();
      final orders = await db.getOrders();
      final logs = await db.getInventoryLogs();

      expect(orders, isNotEmpty);
      expect(logs, isNotEmpty);
    });

    test('testConnection returns Local Cache mode when client is not connected', () async {
      final db = DatabaseService();
      final res = await db.testConnection();

      expect(res['success'], isFalse);
      expect(res['mode'], equals('Local Cache'));
    });
  });

  group('StoreProvider Database Integration Tests', () {
    test('StoreProvider initializes with fallback database state seamlessly', () async {
      final store = StoreProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(store.isDatabaseConnected, isFalse);
      expect(store.dbState, equals(SupabaseConnectionState.fallbackLocal));
      expect(store.allProducts, isNotEmpty);
      expect(store.allCategories, isNotEmpty);
    });

    test('StoreProvider testDatabaseConnection reports diagnostic status', () async {
      final store = StoreProvider();
      final diag = await store.testDatabaseConnection();

      expect(diag.containsKey('success'), isTrue);
      expect(diag.containsKey('mode'), isTrue);
    });

    test('StoreProvider disconnectDatabase resets credentials and retains cache', () async {
      final store = StoreProvider();
      await store.disconnectDatabase();

      expect(store.isDatabaseConnected, isFalse);
      expect(store.dbUrl, isEmpty);
      expect(store.allProducts, isNotEmpty);
    });
  });

  group('DatabaseUplinkModal Widget Tests', () {
    testWidgets('DatabaseUplinkModal renders inputs and action buttons', (tester) async {
      final store = StoreProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<StoreProvider>.value(
            value: store,
            child: const Scaffold(
              body: DatabaseUplinkModal(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('NEURAL DATABASE UPLINK'), findsOneWidget);
      expect(find.text('SUPABASE PROJECT URL'), findsOneWidget);
      expect(find.text('SUPABASE ANON PUBLIC KEY'), findsOneWidget);
      expect(find.text('SAVE & CONNECT'), findsOneWidget);
      expect(find.text('TEST PING'), findsOneWidget);
    });
  });
}
