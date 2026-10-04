import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../data/mock_data.dart';

class StoreProvider extends ChangeNotifier {
  // Product Catalog
  List<Product> _products = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _selectedSort = 'Popular';
  RangeValues _priceRange = const RangeValues(0, 5000);

  // Cart
  final List<CartItem> _cart = [];
  String? _appliedPromoCode;
  double _promoDiscountPercent = 0.0;

  // Wishlist
  final Set<String> _wishlistIds = {};

  // Orders
  List<OrderModel> _orders = [];

  // Role & UI state
  bool _isAdminMode = false;
  ThemeMode _themeMode = ThemeMode.dark;
  bool _isLoading = true;

  StoreProvider() {
    _initializeData();
  }

  // Getters
  bool get isLoading => _isLoading;
  bool get isAdminMode => _isAdminMode;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  List<Product> get allProducts => _products;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get selectedSort => _selectedSort;
  RangeValues get priceRange => _priceRange;

  List<CartItem> get cart => List.unmodifiable(_cart);
  String? get appliedPromoCode => _appliedPromoCode;
  double get promoDiscountPercent => _promoDiscountPercent;

  Set<String> get wishlistIds => _wishlistIds;
  List<OrderModel> get orders => List.unmodifiable(_orders);

  // Initialize and load saved state
  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load products
      final savedProductsJson = prefs.getString('cyberpulse_products');
      if (savedProductsJson != null) {
        final List<dynamic> decoded = jsonDecode(savedProductsJson);
        _products = decoded.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        _products = List.from(MockData.initialProducts);
      }

      // Load orders
      final savedOrdersJson = prefs.getString('cyberpulse_orders');
      if (savedOrdersJson != null) {
        final List<dynamic> decoded = jsonDecode(savedOrdersJson);
        _orders = decoded.map((item) => OrderModel.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        _orders = List.from(MockData.initialOrders);
      }

      // Load wishlist
      final savedWishlist = prefs.getStringList('cyberpulse_wishlist');
      if (savedWishlist != null) {
        _wishlistIds.addAll(savedWishlist);
      }

      // Load theme preference
      final isDark = prefs.getBool('cyberpulse_dark_mode') ?? true;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    } catch (e) {
      debugPrint('Error loading storage: $e');
      _products = List.from(MockData.initialProducts);
      _orders = List.from(MockData.initialOrders);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_products.map((p) => p.toJson()).toList());
      await prefs.setString('cyberpulse_products', encoded);
    } catch (e) {
      debugPrint('Error saving products: $e');
    }
  }

  Future<void> _saveOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_orders.map((o) => o.toJson()).toList());
      await prefs.setString('cyberpulse_orders', encoded);
    } catch (e) {
      debugPrint('Error saving orders: $e');
    }
  }

  Future<void> _saveWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('cyberpulse_wishlist', _wishlistIds.toList());
    } catch (e) {
      debugPrint('Error saving wishlist: $e');
    }
  }

  // Filtered Products
  List<Product> get filteredProducts {
    List<Product> list = _products.where((p) {
      // Category filter
      if (_selectedCategory != 'All' && p.category != _selectedCategory) {
        return false;
      }
      // Price range
      if (p.price < _priceRange.start || p.price > _priceRange.end) {
        return false;
      }
      // Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = p.name.toLowerCase().contains(query);
        final matchesBrand = p.brand.toLowerCase().contains(query);
        final matchesCategory = p.category.toLowerCase().contains(query);
        final matchesDesc = p.description.toLowerCase().contains(query);
        if (!matchesName && !matchesBrand && !matchesCategory && !matchesDesc) {
          return false;
        }
      }
      return true;
    }).toList();

    // Sorting
    switch (_selectedSort) {
      case 'Price: Low to High':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Top Rated':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Newest':
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Popular':
      default:
        list.sort((a, b) => (b.reviewCount * b.rating).compareTo(a.reviewCount * a.rating));
        break;
    }

    return list;
  }

  List<Product> get featuredProducts =>
      _products.where((p) => p.isFeatured).toList();

  List<Product> get trendingProducts =>
      _products.where((p) => p.isTrending).toList();

  List<Product> get wishlistProducts =>
      _products.where((p) => _wishlistIds.contains(p.id)).toList();

  // Search & Filter controls
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortOption(String sort) {
    _selectedSort = sort;
    notifyListeners();
  }

  void setPriceRange(RangeValues range) {
    _priceRange = range;
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    _selectedSort = 'Popular';
    _priceRange = const RangeValues(0, 5000);
    notifyListeners();
  }

  // Wishlist actions
  void toggleWishlist(String productId) {
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
    } else {
      _wishlistIds.add(productId);
    }
    _saveWishlist();
    notifyListeners();
  }

  bool isWishlisted(String productId) => _wishlistIds.contains(productId);

  // Cart actions
  int get cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _cart.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get discountAmount => subtotal * _promoDiscountPercent;

  double get shippingFee {
    if (_cart.isEmpty) return 0.0;
    return subtotal > 1500 ? 0.0 : 25.0; // Free shipping over $1500
  }

  double get estimatedTax => (subtotal - discountAmount) * 0.08;

  double get totalAmount {
    if (_cart.isEmpty) return 0.0;
    return (subtotal - discountAmount) + shippingFee + estimatedTax;
  }

  void addToCart(Product product, {String? color, int quantity = 1}) {
    final existingIndex = _cart.indexWhere((item) =>
        item.product.id == product.id && item.selectedColor == color);

    if (existingIndex >= 0) {
      final currentItem = _cart[existingIndex];
      final allowedQty = min(currentItem.quantity + quantity, product.stockQuantity);
      currentItem.quantity = allowedQty;
    } else {
      final initialQty = min(quantity, product.stockQuantity);
      if (initialQty > 0) {
        _cart.add(CartItem(
          product: product,
          quantity: initialQty,
          selectedColor: color ?? (product.colors.isNotEmpty ? product.colors.first : null),
        ));
      }
    }
    notifyListeners();
  }

  void updateCartQuantity(String productId, String? color, int newQuantity) {
    final index = _cart.indexWhere((item) =>
        item.product.id == productId && item.selectedColor == color);

    if (index >= 0) {
      if (newQuantity <= 0) {
        _cart.removeAt(index);
      } else {
        final maxStock = _cart[index].product.stockQuantity;
        _cart[index].quantity = min(newQuantity, maxStock);
      }
      notifyListeners();
    }
  }

  void removeFromCart(String productId, [String? color]) {
    _cart.removeWhere((item) =>
        item.product.id == productId &&
        (color == null || item.selectedColor == color));
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _appliedPromoCode = null;
    _promoDiscountPercent = 0.0;
    notifyListeners();
  }

  bool applyPromoCode(String code) {
    final cleaned = code.trim().toUpperCase();
    if (cleaned == 'CYBER20') {
      _appliedPromoCode = 'CYBER20 (20% Off)';
      _promoDiscountPercent = 0.20;
      notifyListeners();
      return true;
    } else if (cleaned == 'FUTURE15') {
      _appliedPromoCode = 'FUTURE15 (15% Off)';
      _promoDiscountPercent = 0.15;
      notifyListeners();
      return true;
    } else if (cleaned == 'TECH10') {
      _appliedPromoCode = 'TECH10 (10% Off)';
      _promoDiscountPercent = 0.10;
      notifyListeners();
      return true;
    }
    return false;
  }

  void removePromoCode() {
    _appliedPromoCode = null;
    _promoDiscountPercent = 0.0;
    notifyListeners();
  }

  // Place Order
  OrderModel placeOrder({
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String shippingAddress,
    required String paymentMethod,
  }) {
    final randomNum = 10000 + Random().nextInt(90000);
    final orderId = 'CP-$randomNum';
    final trackingCode = 'CYBER-TRK-${Random().nextInt(90000000) + 10000000}';

    final order = OrderModel(
      id: orderId,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      shippingAddress: shippingAddress,
      items: List.from(_cart),
      subtotal: subtotal,
      discount: discountAmount,
      shippingFee: shippingFee,
      tax: estimatedTax,
      total: totalAmount,
      status: OrderStatus.processing,
      paymentMethod: paymentMethod,
      trackingNumber: trackingCode,
      createdAt: DateTime.now(),
      estimatedDelivery: DateTime.now().add(const Duration(days: 3)),
    );

    // Deduct stock
    for (final cartItem in _cart) {
      final pIndex = _products.indexWhere((p) => p.id == cartItem.product.id);
      if (pIndex >= 0) {
        final cur = _products[pIndex];
        final newStock = max(0, cur.stockQuantity - cartItem.quantity);
        _products[pIndex] = cur.copyWith(stockQuantity: newStock);
      }
    }

    _orders.insert(0, order);
    _saveOrders();
    _saveProducts();
    clearCart();

    return order;
  }

  // Admin Order Actions
  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index] = _orders[index].copyWith(status: newStatus);
      _saveOrders();
      notifyListeners();
    }
  }

  // Admin Product CRUD
  void addProduct(Product product) {
    _products.insert(0, product);
    _saveProducts();
    notifyListeners();
  }

  void updateProduct(Product updatedProduct) {
    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index >= 0) {
      _products[index] = updatedProduct;
      _saveProducts();
      notifyListeners();
    }
  }

  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    _saveProducts();
    notifyListeners();
  }

  void restockProduct(String productId, int addQuantity) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      final current = _products[index];
      _products[index] = current.copyWith(
        stockQuantity: current.stockQuantity + addQuantity,
      );
      _saveProducts();
      notifyListeners();
    }
  }

  // Admin Metrics & Analytics
  double get totalRevenue => _orders
      .where((o) => o.status != OrderStatus.cancelled)
      .fold(0.0, (sum, o) => sum + o.total);

  int get totalOrdersCount => _orders.length;
  int get activeProductsCount => _products.where((p) => p.isInStock).length;
  int get lowStockCount => _products.where((p) => p.isLowStock).length;

  List<Product> get lowStockProducts =>
      _products.where((p) => p.isLowStock).toList();

  Map<String, double> get categorySalesRevenue {
    final Map<String, double> map = {};
    for (final order in _orders) {
      if (order.status == OrderStatus.cancelled) continue;
      for (final item in order.items) {
        final cat = item.product.category;
        map[cat] = (map[cat] ?? 0.0) + item.totalPrice;
      }
    }
    return map;
  }

  // Mode and Theme Toggles
  void toggleUserRole() {
    _isAdminMode = !_isAdminMode;
    notifyListeners();
  }

  void setAdminMode(bool value) {
    _isAdminMode = value;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('cyberpulse_dark_mode', _themeMode == ThemeMode.dark);
    } catch (_) {}
  }
}
