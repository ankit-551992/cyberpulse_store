import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyberpulse_store/providers/store_provider.dart';
import 'package:cyberpulse_store/models/category_item.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('Category Management & Analytics Engine Tests', () {
    test('Initializes with default categories and valid data', () {
      final provider = StoreProvider();
      expect(provider.allCategories.isNotEmpty, isTrue);
      expect(provider.activeCategories.isNotEmpty, isTrue);
      expect(provider.categoryNames.contains('All'), isTrue);
      expect(provider.categoryNames.contains('Laptops'), isTrue);

      final laptopCat = provider.allCategories.firstWhere((c) => c.slug == 'laptops');
      expect(laptopCat.name, 'Laptops');
      expect(laptopCat.featured, isTrue);
    });

    test('Category analytics calculations work accurately', () {
      final provider = StoreProvider();
      final laptopCount = provider.getProductCountForCategory('Laptops');
      expect(laptopCount, greaterThan(0));

      final valuation = provider.getValuationForCategory('Laptops');
      expect(valuation, greaterThan(0));

      final stock = provider.getStockUnitsForCategory('Laptops');
      expect(stock, greaterThan(0));
    });

    test('Adding a new category persists and updates categoryNames', () async {
      final provider = StoreProvider();
      final initialCount = provider.allCategories.length;
      final newCat = CategoryItem(
        id: 'quantum-gear',
        name: 'Quantum Gear',
        slug: 'quantum-gear',
        description: 'Next-gen experimental quantum hardware',
        iconCodePoint: 0xe3cc,
        gradientColors: const [0xFF00F0FF, 0xFF7000FF],
        featured: true,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await provider.addCategory(newCat);
      expect(provider.allCategories.length, equals(initialCount + 1));
      expect(provider.categoryNames.contains('Quantum Gear'), isTrue);
    });

    test('Updating an existing category cascades name changes to products', () async {
      final provider = StoreProvider();
      final existingCat = provider.allCategories.firstWhere((c) => c.slug == 'wearables');
      final updatedCat = existingCat.copyWith(name: 'Cyber Wearables');

      await provider.updateCategory(updatedCat);

      expect(provider.allCategories.any((c) => c.name == 'Cyber Wearables'), isTrue);
      expect(provider.categoryNames.contains('Cyber Wearables'), isTrue);
    });

    test('Toggling category active status toggles isActive flag', () async {
      final provider = StoreProvider();
      final cat = provider.allCategories.first;
      final originalState = cat.isActive;

      await provider.toggleCategoryActive(cat.id);
      final toggled = provider.allCategories.firstWhere((c) => c.id == cat.id);
      expect(toggled.isActive, equals(!originalState));

      // Toggle back
      await provider.toggleCategoryActive(cat.id);
      final reverted = provider.allCategories.firstWhere((c) => c.id == cat.id);
      expect(reverted.isActive, equals(originalState));
    });

    test('Deleting a category without products succeeds', () async {
      final provider = StoreProvider();
      final emptyCat = CategoryItem(
        id: 'empty-cat',
        name: 'Empty Category',
        slug: 'empty-cat',
        description: 'Has no products',
        iconCodePoint: 0xe148,
        createdAt: DateTime.now(),
      );
      await provider.addCategory(emptyCat);
      expect(provider.allCategories.any((c) => c.id == 'empty-cat'), isTrue);

      final success = await provider.deleteCategory('empty-cat');
      expect(success, isTrue);
      expect(provider.allCategories.any((c) => c.id == 'empty-cat'), isFalse);
    });

    test('Deleting a category with products requires reassignToCategory', () async {
      final provider = StoreProvider();
      final laptopCat = provider.allCategories.firstWhere((c) => c.slug == 'laptops');
      final success = await provider.deleteCategory(laptopCat.id);
      expect(success, isFalse);

      expect(provider.allCategories.any((c) => c.slug == 'laptops'), isTrue);
    });

    test('Deleting a category with reassign cascades product categories', () async {
      final provider = StoreProvider();
      final tempCat = CategoryItem(
        id: 'sub-rigs',
        name: 'Sub Rigs',
        slug: 'sub-rigs',
        description: 'Sub Rigs testing category',
        iconCodePoint: 0xe37a,
        createdAt: DateTime.now(),
      );
      await provider.addCategory(tempCat);

      // Add a product under Sub Rigs
      final dummyProduct = provider.products.first.copyWith(
        id: 'dummy-rig-prod',
        name: 'Dummy Rig 3000',
        category: 'Sub Rigs',
      );
      provider.addProduct(dummyProduct);

      // Now delete Sub Rigs reassigning to Laptops
      final deleteSuccess = await provider.deleteCategory('sub-rigs', reassignToCategory: 'Laptops');
      expect(deleteSuccess, isTrue);

      final reassignedProduct = provider.products.firstWhere((p) => p.id == 'dummy-rig-prod');
      expect(reassignedProduct.category, equals('Laptops'));
    });

    test('Category icon resolver returns safe constant IconData', () {
      expect(CategoryItem.resolveIcon(0xe37a), isNotNull);
      expect(CategoryItem.resolveIcon(0xe2f2), isNotNull);
      expect(CategoryItem.resolveIcon(0x000000), isNotNull);
    });
  });
}
