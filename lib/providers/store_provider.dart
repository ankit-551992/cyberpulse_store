import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/inventory_log.dart';
import '../models/category_item.dart';
import '../models/user_model.dart';
export '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/supabase_config.dart';
import '../data/mock_data.dart';

class StoreProvider extends ChangeNotifier {
  // Auth Service & State
  final AuthService _authService = AuthService();
  UserModel? _currentUser = AuthService.demoCustomer;

  // Database Service
  final DatabaseService _databaseService = DatabaseService();

  // Product Catalog
  List<Product> _products = List.from(MockData.initialProducts);
  List<CategoryItem> _categories = List.from(MockData.initialCategories);
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _selectedSort = 'Popular';
  RangeValues _priceRange = const RangeValues(0, 300000);

  // Cart
  final List<CartItem> _cart = [];
  String? _appliedPromoCode;
  double _promoDiscountPercent = 0.0;

  // Wishlist
  final Set<String> _wishlistIds = {};

  // Orders
  List<OrderModel> _orders = List.from(MockData.initialOrders);

  // Inventory Audit Logs
  List<InventoryLog> _inventoryLogs = List.from(MockData.initialInventoryLogs);

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

  // Database Getters
  SupabaseConnectionState get dbState => SupabaseConfig.state;
  bool get isDatabaseConnected => SupabaseConfig.isConnected;
  String? get dbErrorMessage => SupabaseConfig.errorMessage;
  String get dbUrl => SupabaseConfig.url;

  Future<bool> connectDatabase({required String url, required String anonKey}) async {
    final success = await SupabaseConfig.saveCredentials(newUrl: url, newAnonKey: anonKey);
    if (success) {
      await refreshFromDatabase();
    }
    notifyListeners();
    return success;
  }

  Future<void> disconnectDatabase() async {
    await SupabaseConfig.clearCredentials();
    notifyListeners();
  }

  Future<Map<String, dynamic>> testDatabaseConnection() async {
    return _databaseService.testConnection();
  }

  Future<int> seedDatabaseToSupabase() async {
    return _databaseService.seedInitialDataToSupabase();
  }

  Future<void> refreshFromDatabase() async {
    _isLoading = true;
    notifyListeners();
    try {
      final cats = await _databaseService.getCategories();
      if (cats.isNotEmpty) _categories = cats;

      final prods = await _databaseService.getProducts();
      if (prods.isNotEmpty) _products = prods;

      final ords = await _databaseService.getOrders();
      if (ords.isNotEmpty) _orders = ords;

      final logs = await _databaseService.getInventoryLogs();
      if (logs.isNotEmpty) _inventoryLogs = logs;

      final wish = await _databaseService.getWishlist(_currentUser?.id ?? 'guest');
      _wishlistIds.clear();
      _wishlistIds.addAll(wish);
    } catch (e) {
      debugPrint('StoreProvider refreshFromDatabase error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Auth Getters
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isCurrentUserAdmin => _currentUser?.isAdmin ?? false;

  List<OrderModel> get myOrders {
    if (_currentUser == null) return [];
    if (_currentUser!.isAdmin) return List.unmodifiable(_orders);
    final userEmail = _currentUser!.email.trim().toLowerCase();
    final matched = _orders.where((o) => o.customerEmail.trim().toLowerCase() == userEmail).toList();
    if (matched.isEmpty) {
      // If user is demo customer or has not placed new orders yet, show their sample order
      return _orders.take(2).toList();
    }
    return matched;
  }

  List<Product> get allProducts => _products;
  List<Product> get products => _products;
  List<InventoryLog> get stockMovements => _inventoryLogs;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get selectedSort => _selectedSort;
  RangeValues get priceRange => _priceRange;

  List<CartItem> get cart => List.unmodifiable(_cart);
  String? get appliedPromoCode => _appliedPromoCode;
  double get promoDiscountPercent => _promoDiscountPercent;

  Set<String> get wishlistIds => _wishlistIds;
  List<OrderModel> get orders => List.unmodifiable(_orders);
  List<InventoryLog> get inventoryLogs => List.unmodifiable(_inventoryLogs);
  List<CategoryItem> get allCategories => List.unmodifiable(_categories);
  List<CategoryItem> get activeCategories => _categories.where((c) => c.isActive).toList();
  List<String> get categoryNames => ['All', ..._categories.where((c) => c.isActive).map((c) => c.name)];

  // Initialize and load saved state
  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load products (using inr key to ensure clean conversion)
      final savedProductsJson = prefs.getString('cyberpulse_inr_products_v3');
      if (savedProductsJson != null) {
        final List<dynamic> decoded = jsonDecode(savedProductsJson);
        _products = decoded.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
      }

      // Load orders
      final savedOrdersJson = prefs.getString('cyberpulse_inr_orders_v3');
      if (savedOrdersJson != null) {
        final List<dynamic> decoded = jsonDecode(savedOrdersJson);
        _orders = decoded.map((item) => OrderModel.fromJson(item as Map<String, dynamic>)).toList();
      }

      // Load categories
      final savedCategoriesJson = prefs.getString('cyberpulse_categories_v1');
      if (savedCategoriesJson != null) {
        final List<dynamic> decoded = jsonDecode(savedCategoriesJson);
        _categories = decoded.map((item) => CategoryItem.fromJson(item as Map<String, dynamic>)).toList();
      }

      // Load inventory logs
      final savedLogsJson = prefs.getString('cyberpulse_inventory_logs_v1');
      if (savedLogsJson != null) {
        final List<dynamic> decoded = jsonDecode(savedLogsJson);
        _inventoryLogs = decoded.map((item) => InventoryLog.fromJson(item as Map<String, dynamic>)).toList();
      }

      // Load wishlist
      final savedWishlist = prefs.getStringList('cyberpulse_wishlist');
      if (savedWishlist != null) {
        _wishlistIds.clear();
        _wishlistIds.addAll(savedWishlist);
      }

      // Load theme preference
      final isDark = prefs.getBool('cyberpulse_dark_mode') ?? true;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

      // Load user authentication session
      final savedUser = await _authService.getSavedSession();
      if (savedUser != null) {
        _currentUser = savedUser;
      }

      // Initialize Supabase if configured and refresh cloud data
      final connected = await SupabaseConfig.initialize();
      if (connected) {
        await refreshFromDatabase();
      }
    } catch (e) {
      debugPrint('Error loading storage: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_products.map((p) => p.toJson()).toList());
      await prefs.setString('cyberpulse_inr_products_v3', encoded);

      for (final p in _products) {
        _databaseService.saveProduct(p);
      }
    } catch (e) {
      debugPrint('Error saving products: $e');
    }
  }

  Future<void> _saveOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_orders.map((o) => o.toJson()).toList());
      await prefs.setString('cyberpulse_inr_orders_v3', encoded);

      for (final o in _orders) {
        _databaseService.saveOrder(o);
      }
    } catch (e) {
      debugPrint('Error saving orders: $e');
    }
  }

  Future<void> _saveCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_categories.map((c) => c.toJson()).toList());
      await prefs.setString('cyberpulse_categories_v1', encoded);

      for (final c in _categories) {
        _databaseService.saveCategory(c);
      }
    } catch (e) {
      debugPrint('Error saving categories: $e');
    }
  }

  Future<void> _saveInventoryLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_inventoryLogs.take(100).map((l) => l.toJson()).toList());
      await prefs.setString('cyberpulse_inventory_logs_v1', encoded);

      if (_inventoryLogs.isNotEmpty) {
        _databaseService.saveInventoryLog(_inventoryLogs.first);
      }
    } catch (e) {
      debugPrint('Error saving inventory logs: $e');
    }
  }

  Future<void> _saveWishlist() async {
    try {
      await _databaseService.setWishlist(_currentUser?.id ?? 'guest', _wishlistIds);
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
        final matchesSku = p.sku.toLowerCase().contains(query);
        if (!matchesName && !matchesBrand && !matchesCategory && !matchesDesc && !matchesSku) {
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
    _priceRange = const RangeValues(0, 300000);
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

  /// Free delivery above ₹999; below that ₹99 shipping across India
  double get shippingFee {
    if (_cart.isEmpty) return 0.0;
    return subtotal >= 999 ? 0.0 : 99.0;
  }

  /// 18% GST (9% CGST + 9% SGST)
  double get estimatedTax => (subtotal - discountAmount) * 0.18;

  double get totalAmount {
    if (_cart.isEmpty) return 0.0;
    return (subtotal - discountAmount) + shippingFee + estimatedTax;
  }

  void addToCart(Product product, {String? color, int quantity = 1}) {
    if (product.isOutOfStock) return;

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
    if (cleaned == 'CYBERINDIA' || cleaned == 'CYBER20') {
      _appliedPromoCode = '$cleaned (20% Off Cyber Deal)';
      _promoDiscountPercent = 0.20;
      notifyListeners();
      return true;
    } else if (cleaned == 'FESTIVE15' || cleaned == 'FUTURE15') {
      _appliedPromoCode = '$cleaned (15% Festive Tech Off)';
      _promoDiscountPercent = 0.15;
      notifyListeners();
      return true;
    } else if (cleaned == 'RUPAY10' || cleaned == 'TECH10' || cleaned == 'CYBER10') {
      _appliedPromoCode = '$cleaned (10% Instant Discount)';
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

  // Place Order & Deduct Stock with Audit Logging
  OrderModel placeOrder({
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String shippingAddress,
    required String paymentMethod,
  }) {
    final randomNum = 10000 + Random().nextInt(90000);
    final orderId = 'CP-IN-$randomNum';
    final trackingCode = 'DELHIVERY-EXP-${Random().nextInt(90000000) + 10000000}';

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
      estimatedDelivery: DateTime.now().add(const Duration(days: 2)),
    );

    // Deduct stock for each cart item and record inventory audit log
    for (final cartItem in _cart) {
      final pIndex = _products.indexWhere((p) => p.id == cartItem.product.id);
      if (pIndex >= 0) {
        final cur = _products[pIndex];
        final prevStock = cur.stockQuantity;
        final newStock = max(0, cur.stockQuantity - cartItem.quantity);

        // Update variant color stock if present
        final updatedColorStock = Map<String, int>.from(cur.colorStock);
        if (cartItem.selectedColor != null && updatedColorStock.containsKey(cartItem.selectedColor)) {
          final curColorStock = updatedColorStock[cartItem.selectedColor] ?? 0;
          updatedColorStock[cartItem.selectedColor!] = max(0, curColorStock - cartItem.quantity);
        }

        _products[pIndex] = cur.copyWith(
          stockQuantity: newStock,
          colorStock: updatedColorStock,
        );

        // Record stock movement log
        final log = InventoryLog(
          id: 'LOG-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999)}',
          productId: cur.id,
          productName: cur.name,
          sku: cur.sku,
          type: StockMovementType.orderSale,
          quantityChanged: -cartItem.quantity,
          previousStock: prevStock,
          newStock: newStock,
          warehouse: cur.warehouseLocation,
          note: 'Customer Order #$orderId fulfilled for $customerName (${cartItem.quantity} unit${cartItem.quantity > 1 ? "s" : ""})',
          performedBy: 'Storefront Checkout System',
        );
        _inventoryLogs.insert(0, log);
      }
    }

    _orders.insert(0, order);
    _saveOrders();
    _saveProducts();
    _saveInventoryLogs();
    clearCart();

    return order;
  }

  // Admin Order Actions with Automatic Stock Restoral on Cancel
  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final previousOrder = _orders[index];
      
      // If moving to cancelled from a non-cancelled state, return stock!
      if (previousOrder.status != OrderStatus.cancelled && newStatus == OrderStatus.cancelled) {
        for (final item in previousOrder.items) {
          final pIndex = _products.indexWhere((p) => p.id == item.product.id);
          if (pIndex >= 0) {
            final cur = _products[pIndex];
            final prevStock = cur.stockQuantity;
            final restoredStock = cur.stockQuantity + item.quantity;

            final updatedColorStock = Map<String, int>.from(cur.colorStock);
            if (item.selectedColor != null && updatedColorStock.containsKey(item.selectedColor)) {
              final curColorStock = updatedColorStock[item.selectedColor] ?? 0;
              updatedColorStock[item.selectedColor!] = curColorStock + item.quantity;
            }

            _products[pIndex] = cur.copyWith(
              stockQuantity: restoredStock,
              colorStock: updatedColorStock,
            );

            // Log stock return
            _inventoryLogs.insert(
              0,
              InventoryLog(
                id: 'LOG-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999)}',
                productId: cur.id,
                productName: cur.name,
                sku: cur.sku,
                type: StockMovementType.orderCancelled,
                quantityChanged: item.quantity,
                previousStock: prevStock,
                newStock: restoredStock,
                warehouse: cur.warehouseLocation,
                note: 'Order #$orderId cancelled. Restored ${item.quantity} unit(s) to inventory.',
                performedBy: 'Admin (Order Manager)',
              ),
            );
          }
        }
        _saveProducts();
        _saveInventoryLogs();
      }

      _orders[index] = previousOrder.copyWith(status: newStatus);
      _saveOrders();
      notifyListeners();
    }
  }

  void cancelOrder(String orderId, {String reason = 'Customer requested cancellation'}) {
    updateOrderStatus(orderId, OrderStatus.cancelled);
  }

  // Admin Product CRUD
  void addProduct(Product product) {
    _products.insert(0, product);
    // Log creation
    _inventoryLogs.insert(
      0,
      InventoryLog(
        id: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
        productId: product.id,
        productName: product.name,
        sku: product.sku,
        type: StockMovementType.initial,
        quantityChanged: product.stockQuantity,
        previousStock: 0,
        newStock: product.stockQuantity,
        warehouse: product.warehouseLocation,
        note: 'New product listed: ${product.name}',
        performedBy: 'Admin Portal',
      ),
    );
    _saveProducts();
    _saveInventoryLogs();
    notifyListeners();
  }

  void updateProduct(Product updatedProduct) {
    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index >= 0) {
      final current = _products[index];
      if (current.stockQuantity != updatedProduct.stockQuantity) {
        final diff = updatedProduct.stockQuantity - current.stockQuantity;
        _inventoryLogs.insert(
          0,
          InventoryLog(
            id: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
            productId: updatedProduct.id,
            productName: updatedProduct.name,
            sku: updatedProduct.sku,
            type: diff > 0 ? StockMovementType.restock : StockMovementType.adjustment,
            quantityChanged: diff,
            previousStock: current.stockQuantity,
            newStock: updatedProduct.stockQuantity,
            warehouse: updatedProduct.warehouseLocation,
            note: 'Stock updated via Product Editor',
            performedBy: 'Admin Portal',
          ),
        );
        _saveInventoryLogs();
      }
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

  // Comprehensive Stock & Inventory Management
  void adjustStock(
    String productId,
    int newQuantity, {
    required StockMovementType type,
    required String reason,
    String? warehouse,
    String? performedBy,
  }) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      final current = _products[index];
      final targetQty = max(0, newQuantity);
      final diff = targetQty - current.stockQuantity;

      if (diff == 0) return; // No change

      _products[index] = current.copyWith(
        stockQuantity: targetQty,
        warehouseLocation: warehouse ?? current.warehouseLocation,
      );

      _inventoryLogs.insert(
        0,
        InventoryLog(
          id: 'LOG-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999)}',
          productId: current.id,
          productName: current.name,
          sku: current.sku,
          type: type,
          quantityChanged: diff,
          previousStock: current.stockQuantity,
          newStock: targetQty,
          warehouse: warehouse ?? current.warehouseLocation,
          note: reason,
          performedBy: performedBy ?? 'Admin Portal',
        ),
      );

      _saveProducts();
      _saveInventoryLogs();
      notifyListeners();
    }
  }

  void restockProduct(String productId, int addQuantity, {String? reason, String? performedBy}) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      final current = _products[index];
      adjustStock(
        productId,
        current.stockQuantity + addQuantity,
        type: StockMovementType.restock,
        reason: reason ?? 'Restocked +$addQuantity units from supplier shipment',
        performedBy: performedBy ?? 'Admin Portal',
      );
    }
  }

  void bulkRestockLowStock({int addPerItem = 25, String? reason}) {
    final lowOrOutItems = _products.where((p) => p.isLowStock || p.isOutOfStock).toList();
    if (lowOrOutItems.isEmpty) return;

    for (final p in lowOrOutItems) {
      final pIndex = _products.indexWhere((item) => item.id == p.id);
      if (pIndex >= 0) {
        final cur = _products[pIndex];
        final prev = cur.stockQuantity;
        final newStock = prev + addPerItem;

        // Distribute proportionally among colors if present
        final updatedColorStock = Map<String, int>.from(cur.colorStock);
        if (updatedColorStock.isNotEmpty) {
          final addPerColor = (addPerItem / updatedColorStock.length).ceil();
          updatedColorStock.updateAll((key, val) => val + addPerColor);
        }

        _products[pIndex] = cur.copyWith(
          stockQuantity: newStock,
          colorStock: updatedColorStock,
        );

        _inventoryLogs.insert(
          0,
          InventoryLog(
            id: 'LOG-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999)}',
            productId: cur.id,
            productName: cur.name,
            sku: cur.sku,
            type: StockMovementType.restock,
            quantityChanged: addPerItem,
            previousStock: prev,
            newStock: newStock,
            warehouse: cur.warehouseLocation,
            note: reason ?? 'Automated bulk replenishment: +$addPerItem units allocated',
            performedBy: 'Batch Restock System',
          ),
        );
      }
    }

    _saveProducts();
    _saveInventoryLogs();
    notifyListeners();
  }

  void updateVariantStock(String productId, Map<String, int> newColorStock) =>
      updateProductVariantStock(productId, newColorStock);

  void bulkRestockLowItems(int addPerItem) =>
      bulkRestockLowStock(addPerItem: addPerItem);

  void updateProductVariantStock(String productId, Map<String, int> newColorStock, {String? note}) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      final current = _products[index];
      final totalFromColors = newColorStock.values.fold(0, (sum, count) => sum + count);
      final diff = totalFromColors - current.stockQuantity;

      _products[index] = current.copyWith(
        colorStock: newColorStock,
        stockQuantity: totalFromColors,
      );

      _inventoryLogs.insert(
        0,
        InventoryLog(
          id: 'LOG-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999)}',
          productId: current.id,
          productName: current.name,
          sku: current.sku,
          type: StockMovementType.adjustment,
          quantityChanged: diff,
          previousStock: current.stockQuantity,
          newStock: totalFromColors,
          warehouse: current.warehouseLocation,
          note: note ?? 'Variant stock breakdown updated',
          performedBy: 'Admin Inventory Desk',
        ),
      );

      _saveProducts();
      _saveInventoryLogs();
      notifyListeners();
    }
  }

  // Category Management & Analytics
  Future<void> addCategory(CategoryItem category) async {
    _categories.add(category);
    await _saveCategories();
    notifyListeners();
  }

  Future<void> updateCategory(CategoryItem updatedCategory) async {
    final index = _categories.indexWhere((c) => c.id == updatedCategory.id);
    if (index != -1) {
      final oldName = _categories[index].name;
      _categories[index] = updatedCategory;
      if (oldName != updatedCategory.name) {
        _products = _products.map((p) {
          if (p.category.toLowerCase() == oldName.toLowerCase()) {
            return p.copyWith(category: updatedCategory.name);
          }
          return p;
        }).toList();
        await _saveProducts();
      }
      await _saveCategories();
      notifyListeners();
    }
  }

  Future<bool> deleteCategory(String categoryId, {String? reassignToCategory}) async {
    final catIndex = _categories.indexWhere((c) => c.id == categoryId);
    if (catIndex == -1) return false;
    final cat = _categories[catIndex];

    final matchingProducts = _products.where((p) => p.category.toLowerCase() == cat.name.toLowerCase()).toList();
    if (matchingProducts.isNotEmpty && (reassignToCategory == null || reassignToCategory.isEmpty)) {
      return false;
    }

    if (matchingProducts.isNotEmpty && reassignToCategory != null) {
      _products = _products.map((p) {
        if (p.category.toLowerCase() == cat.name.toLowerCase()) {
          return p.copyWith(category: reassignToCategory);
        }
        return p;
      }).toList();
      await _saveProducts();
    }

    final deletedId = cat.id;
    _categories.removeAt(catIndex);
    if (_selectedCategory == cat.name) {
      _selectedCategory = 'All';
    }
    await _saveCategories();
    _databaseService.deleteCategory(deletedId);
    notifyListeners();
    return true;
  }

  Future<void> toggleCategoryActive(String categoryId) async {
    final index = _categories.indexWhere((c) => c.id == categoryId);
    if (index != -1) {
      _categories[index] = _categories[index].copyWith(isActive: !_categories[index].isActive);
      await _saveCategories();
      notifyListeners();
    }
  }

  int getProductCountForCategory(String categoryName) {
    return _products.where((p) => p.category.toLowerCase() == categoryName.toLowerCase()).length;
  }

  int getStockUnitsForCategory(String categoryName) {
    return _products
        .where((p) => p.category.toLowerCase() == categoryName.toLowerCase())
        .fold(0, (sum, p) => sum + p.stockQuantity);
  }

  double getValuationForCategory(String categoryName) {
    return _products
        .where((p) => p.category.toLowerCase() == categoryName.toLowerCase())
        .fold(0.0, (sum, p) => sum + p.totalValuation);
  }

  double getRevenueForCategory(String categoryName) {
    return categorySalesRevenue[categoryName] ?? 0.0;
  }

  // Inventory Metrics & Analytics
  int get totalInventoryUnits =>
      _products.fold(0, (sum, p) => sum + p.stockQuantity);

  double get totalInventoryValuation =>
      _products.fold(0.0, (sum, p) => sum + p.totalValuation);

  int get outOfStockCount => _products.where((p) => p.isOutOfStock).length;
  int get lowStockCount => _products.where((p) => p.isLowStock).length;
  int get healthyStockCount => _products.where((p) => p.stockQuantity > p.lowStockThreshold).length;

  List<Product> get lowStockProducts =>
      _products.where((p) => p.isLowStock).toList();

  List<Product> get outOfStockProducts =>
      _products.where((p) => p.isOutOfStock).toList();

  List<Product> get wellStockedProducts =>
      _products.where((p) => p.stockQuantity > p.lowStockThreshold).toList();

  Map<String, int> get warehouseDistribution {
    final Map<String, int> distribution = {};
    for (final p in _products) {
      final hub = p.warehouseLocation.split(' - ').first;
      distribution[hub] = (distribution[hub] ?? 0) + p.stockQuantity;
    }
    return distribution;
  }

  // Admin Metrics & Analytics
  double get totalRevenue => _orders
      .where((o) => o.status != OrderStatus.cancelled)
      .fold(0.0, (sum, o) => sum + o.total);

  int get totalOrdersCount => _orders.length;
  int get activeProductsCount => _products.where((p) => p.isInStock).length;

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

  bool trySetAdminMode(bool value) {
    if (value && !isCurrentUserAdmin) {
      return false;
    }
    _isAdminMode = value;
    notifyListeners();
    return true;
  }

  // Authentication Actions
  Future<AuthResult> signIn(String email, String password) async {
    final result = await _authService.signIn(email: email, password: password);
    if (result.isSuccess && result.user != null) {
      _currentUser = result.user;
      notifyListeners();
    }
    return result;
  }

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    UserRole role = UserRole.customer,
    String street = '',
    String city = '',
    String state = '',
    String pincode = '',
  }) async {
    final result = await _authService.signUp(
      name: name,
      email: email,
      password: password,
      phone: phone,
      role: role,
      street: street,
      city: city,
      state: state,
      pincode: pincode,
    );
    if (result.isSuccess && result.user != null) {
      _currentUser = result.user;
      notifyListeners();
    }
    return result;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    if (_isAdminMode) {
      _isAdminMode = false;
    }
    notifyListeners();
  }

  Future<void> loginAsDemoCustomer() async {
    _currentUser = await _authService.quickCustomerLogin();
    notifyListeners();
  }

  Future<void> loginAsDemoAdmin() async {
    _currentUser = await _authService.quickAdminLogin();
    notifyListeners();
  }

  Future<void> updateCurrentUser(UserModel updated) async {
    _currentUser = await _authService.updateProfile(updated);
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
