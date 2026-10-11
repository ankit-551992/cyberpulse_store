import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:cyberpulse_store/main.dart';
import 'package:cyberpulse_store/providers/store_provider.dart';
import 'package:cyberpulse_store/utils/currency_helper.dart';
import 'package:cyberpulse_store/models/order.dart';
import 'package:cyberpulse_store/data/mock_data.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('CurrencyHelper Indian Rupee Tests', () {
    test('Formats currency with rupee symbol and Indian number grouping', () {
      final formatted = CurrencyHelper.format(149999);
      expect(formatted.contains('₹'), isTrue);
      expect(formatted.contains('1,49,999'), isTrue);
    });

    test('Formats compact currency correctly for Indian lakhs & crores', () {
      expect(CurrencyHelper.formatCompact(500), equals('₹500'));
      expect(CurrencyHelper.formatCompact(150000), equals('₹1.50 Lakh'));
      expect(CurrencyHelper.formatCompact(20000000), equals('₹2.00 Cr'));
    });

    test('Indian Pincode Lookup', () {
      final infoBangalore = IndianLocationService.lookupPincode('560001');
      expect(infoBangalore.city.contains('Bengaluru'), isTrue);
      expect(infoBangalore.state, equals('Karnataka'));
      expect(infoBangalore.codAvailable, isTrue);

      final infoMumbai = IndianLocationService.lookupPincode('400001');
      expect(infoMumbai.city.contains('Mumbai'), isTrue);
      expect(infoMumbai.state, equals('Maharashtra'));
    });
  });

  group('StoreProvider State Management Tests', () {
    test('Initializes with default products and categories', () {
      final store = StoreProvider();
      expect(store.allProducts.isNotEmpty, isTrue);
      expect(MockData.categories.length, greaterThanOrEqualTo(5));
      expect(store.cart.isEmpty, isTrue);
      expect(store.orders.isNotEmpty, isTrue);
    });

    test('Cart operations and GST / total calculations', () {
      final store = StoreProvider();
      final product = store.allProducts.first;

      store.addToCart(product, quantity: 2);
      expect(store.cartCount, equals(2));
      expect(store.subtotal, equals(product.price * 2));
      expect(store.estimatedTax, closeTo(store.subtotal * 0.18, 0.01));
      expect(store.totalAmount, greaterThan(0));

      store.updateCartQuantity(product.id, product.colors.first, 1);
      expect(store.cartCount, equals(1));

      store.removeFromCart(product.id);
      expect(store.cartCount, equals(0));
    });

    test('Promo code application', () {
      final store = StoreProvider();
      final product = store.allProducts.first;
      store.addToCart(product, quantity: 1);

      final success = store.applyPromoCode('CYBER10');
      expect(success, isTrue);
      expect(store.promoDiscountPercent, equals(0.10));
      expect(store.discountAmount, greaterThan(0));

      store.removePromoCode();
      expect(store.promoDiscountPercent, equals(0.0));
      expect(store.discountAmount, equals(0.0));
    });

    test('Order creation with Indian shipping address & status update', () {
      final store = StoreProvider();
      final product = store.allProducts.first;
      store.addToCart(product, quantity: 1);

      final order = store.placeOrder(
        customerName: 'Ankit Kumar Singh',
        customerEmail: 'ankit@example.com',
        customerPhone: '+91 98765 43210',
        shippingAddress: '42 MG Road, Cyber City, Bengaluru, Karnataka - 560001',
        paymentMethod: 'UPI (GPay / PhonePe)',
      );

      expect(order.customerName, equals('Ankit Kumar Singh'));
      expect(order.paymentMethod, equals('UPI (GPay / PhonePe)'));
      expect(order.trackingNumber, isNotEmpty);
      expect(store.cart.isEmpty, isTrue);

      // Verify Admin status update
      store.updateOrderStatus(order.id, OrderStatus.shipped);
      final updatedOrder = store.orders.firstWhere((o) => o.id == order.id);
      expect(updatedOrder.status, equals(OrderStatus.shipped));
    });

    test('Wishlist toggle', () {
      final store = StoreProvider();
      final product = store.allProducts.first;

      expect(store.isWishlisted(product.id), isFalse);
      store.toggleWishlist(product.id);
      expect(store.isWishlisted(product.id), isTrue);
      store.toggleWishlist(product.id);
      expect(store.isWishlisted(product.id), isFalse);
    });

    test('Search and category filtering', () {
      final store = StoreProvider();
      store.setSearchQuery('Neural');
      expect(store.filteredProducts.every((p) => p.name.toLowerCase().contains('neural') || p.description.toLowerCase().contains('neural')), isTrue);

      store.setSearchQuery('');
      store.setCategory('Audio');
      expect(store.filteredProducts.every((p) => p.category == 'Audio'), isTrue);
    });
  });

  testWidgets('CyberPulse app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => StoreProvider(),
        child: const CyberPulseApp(),
      ),
    );

    expect(find.byType(CyberPulseApp), findsOneWidget);
  });
}
