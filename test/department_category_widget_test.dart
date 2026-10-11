import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyberpulse_store/providers/store_provider.dart';
import 'package:cyberpulse_store/screens/admin/admin_categories_view.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestableWidget(StoreProvider storeProvider) {
    return ChangeNotifierProvider<StoreProvider>.value(
      value: storeProvider,
      child: const MaterialApp(
        home: Scaffold(
          body: AdminCategoriesView(),
        ),
      ),
    );
  }

  testWidgets('AdminCategoriesView renders KPI metrics and category catalog', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final provider = StoreProvider();
    await tester.pumpWidget(buildTestableWidget(provider));
    await tester.pumpAndSettle();

    // Verify Title & Header
    expect(find.text('CATEGORY MANAGEMENT'), findsOneWidget);
    expect(find.text('TOTAL CATEGORIES'), findsOneWidget);
    expect(find.text('CATALOG PRODUCTS'), findsOneWidget);
    expect(find.text('TOTAL STOCK UNITS'), findsOneWidget);
    expect(find.text('INVENTORY VALUATION'), findsOneWidget);

    // Verify default seeded categories are rendered
    expect(find.text('Laptops'), findsWidgets);
    expect(find.text('Smartphones'), findsWidgets);
    expect(find.text('Audio'), findsWidgets);

    // Verify Search input
    final searchField = find.byType(TextField).first;
    expect(searchField, findsOneWidget);

    // Enter search term for Laptops
    await tester.enterText(searchField, 'Laptops');
    await tester.pumpAndSettle();

    // Laptops should remain visible
    expect(find.text('Laptops'), findsWidgets);
  });

  testWidgets('AdminCategoriesView opens New Category dialog and creates category', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final provider = StoreProvider();
    await tester.pumpWidget(buildTestableWidget(provider));
    await tester.pumpAndSettle();

    // Tap NEW CATEGORY button
    final addBtn = find.text('NEW CATEGORY');
    expect(addBtn, findsOneWidget);
    await tester.tap(addBtn);
    await tester.pumpAndSettle();

    // Dialog should be open
    expect(find.text('CREATE NEW CATEGORY'), findsOneWidget);

    // Fill name field using hint
    final nameField = find.widgetWithText(TextField, 'e.g. Quantum Drives');
    expect(nameField, findsOneWidget);
    await tester.enterText(nameField, 'Neural Implants');
    await tester.pumpAndSettle();

    // Tap CREATE CATEGORY button
    final submitBtn = find.text('CREATE CATEGORY');
    expect(submitBtn, findsOneWidget);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    // Verify new category is present in provider
    expect(provider.categoryNames.contains('Neural Implants'), isTrue);
    expect(find.text('Neural Implants'), findsWidgets);
  });
}
