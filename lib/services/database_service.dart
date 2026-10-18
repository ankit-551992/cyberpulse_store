import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/category_item.dart';
import '../models/order.dart';
import '../models/inventory_log.dart';
import '../data/mock_data.dart';
import 'supabase_config.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Storage keys for local caching
  static const String _productsKey = 'cyberpulse_inr_products_v3';
  static const String _categoriesKey = 'cyberpulse_categories_v1';
  static const String _ordersKey = 'cyberpulse_inr_orders_v3';
  static const String _logsKey = 'cyberpulse_inventory_logs_v1';
  static const String _wishlistKey = 'cyberpulse_wishlist';

  // ---------------------------------------------------------------------------
  // CONNECTION TEST & DIAGNOSTICS
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> testConnection() async {
    final client = SupabaseConfig.client;
    if (client == null) {
      return {
        'success': false,
        'mode': 'Local Cache',
        'latencyMs': 0,
        'message': 'Supabase is not configured or offline. Running locally.',
      };
    }

    final stopwatch = Stopwatch()..start();
    try {
      final res = await client.from('categories').select('id').limit(1);
      stopwatch.stop();
      return {
        'success': true,
        'mode': 'Supabase Cloud (PostgreSQL)',
        'latencyMs': stopwatch.elapsedMilliseconds,
        'message': 'Connected! Latency: ${stopwatch.elapsedMilliseconds}ms. Found ${res.length} sample records.',
      };
    } catch (e) {
      stopwatch.stop();
      return {
        'success': false,
        'mode': 'Error',
        'latencyMs': stopwatch.elapsedMilliseconds,
        'message': 'Connection error: $e',
      };
    }
  }

  // ---------------------------------------------------------------------------
  // CATEGORIES
  // ---------------------------------------------------------------------------
  Future<List<CategoryItem>> getCategories() async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final List<dynamic> data = await client
            .from('categories')
            .select()
            .order('created_at', ascending: true);

        if (data.isNotEmpty) {
          final categories = data.map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            // Convert database snake_case columns if present
            if (map.containsKey('icon_code_point')) {
              map['iconCodePoint'] = map['icon_code_point'];
            }
            if (map.containsKey('gradient_colors')) {
              final raw = map['gradient_colors'];
              if (raw is List) {
                map['gradientColors'] = raw.map((c) {
                  if (c is int) return c;
                  if (c is String) return int.tryParse(c.replaceAll('0x', ''), radix: 16) ?? 0xFF00F0FF;
                  return 0xFF00F0FF;
                }).toList();
              }
            }
            if (map.containsKey('is_active')) {
              map['isActive'] = map['is_active'];
            }
            return CategoryItem.fromJson(map);
          }).toList();

          // Update local cache
          await _saveLocalJson(_categoriesKey, categories.map((c) => c.toJson()).toList());
          return categories;
        }
      } catch (e) {
        debugPrint('DatabaseService: Supabase getCategories failed ($e), falling back to local.');
      }
    }

    // Local fallback
    return _getLocalCategories();
  }

  Future<void> saveCategory(CategoryItem category) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final payload = {
          'id': category.id,
          'name': category.name,
          'slug': category.slug,
          'description': category.description,
          'icon_code_point': category.iconCodePoint,
          'icon_font_family': category.iconFontFamily,
          'gradient_colors': category.gradientColors,
          'featured': category.featured,
          'is_active': category.isActive,
          'created_at': category.createdAt.toIso8601String(),
        };

        await client.from('categories').upsert(payload);
        debugPrint('DatabaseService: Category ${category.name} synced to Supabase.');
      } catch (e) {
        debugPrint('DatabaseService: Supabase saveCategory error: $e');
      }
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        await client.from('categories').delete().eq('id', categoryId);
        debugPrint('DatabaseService: Category $categoryId deleted from Supabase.');
      } catch (e) {
        debugPrint('DatabaseService: Supabase deleteCategory error: $e');
      }
    }
  }

  // ---------------------------------------------------------------------------
  // PRODUCTS
  // ---------------------------------------------------------------------------
  Future<List<Product>> getProducts() async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final List<dynamic> data = await client
            .from('products')
            .select()
            .order('created_at', ascending: false);

        if (data.isNotEmpty) {
          final products = data.map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            // Map snake_case database columns to Product.fromJson
            if (map.containsKey('original_price')) map['originalPrice'] = map['original_price'];
            if (map.containsKey('stock_quantity')) map['stockQuantity'] = map['stock_quantity'];
            if (map.containsKey('low_stock_threshold')) map['lowStockThreshold'] = map['low_stock_threshold'];
            if (map.containsKey('warehouse_location')) map['warehouseLocation'] = map['warehouse_location'];
            if (map.containsKey('color_stock')) map['colorStock'] = map['color_stock'];
            if (map.containsKey('review_count')) map['reviewCount'] = map['review_count'];
            if (map.containsKey('image_urls')) map['imageUrls'] = map['image_urls'];
            if (map.containsKey('is_featured')) map['isFeatured'] = map['is_featured'];
            if (map.containsKey('is_trending')) map['isTrending'] = map['is_trending'];
            if (map.containsKey('created_at')) map['createdAt'] = map['created_at'];

            return Product.fromJson(map);
          }).toList();

          // Update local cache
          await _saveLocalJson(_productsKey, products.map((p) => p.toJson()).toList());
          return products;
        }
      } catch (e) {
        debugPrint('DatabaseService: Supabase getProducts failed ($e), falling back to local.');
      }
    }

    // Local fallback
    return _getLocalProducts();
  }

  Future<void> saveProduct(Product product) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final payload = {
          'id': product.id,
          'sku': product.sku,
          'name': product.name,
          'brand': product.brand,
          'category': product.category,
          'description': product.description,
          'price': product.price,
          'original_price': product.originalPrice,
          'stock_quantity': product.stockQuantity,
          'low_stock_threshold': product.lowStockThreshold,
          'warehouse_location': product.warehouseLocation,
          'color_stock': product.colorStock,
          'rating': product.rating,
          'review_count': product.reviewCount,
          'image_urls': product.imageUrls,
          'tags': product.tags,
          'specs': product.specs,
          'colors': product.colors,
          'is_featured': product.isFeatured,
          'is_trending': product.isTrending,
          'created_at': product.createdAt.toIso8601String(),
        };

        await client.from('products').upsert(payload);
        debugPrint('DatabaseService: Product ${product.name} synced to Supabase.');
      } catch (e) {
        debugPrint('DatabaseService: Supabase saveProduct error: $e');
      }
    }
  }

  Future<void> deleteProduct(String productId) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        await client.from('products').delete().eq('id', productId);
        debugPrint('DatabaseService: Product $productId deleted from Supabase.');
      } catch (e) {
        debugPrint('DatabaseService: Supabase deleteProduct error: $e');
      }
    }
  }

  Future<void> updateStockQuantity(String productId, int newQuantity, {Map<String, int>? colorStock}) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final payload = <String, dynamic>{
          'stock_quantity': newQuantity,
        };
        if (colorStock != null) {
          payload['color_stock'] = colorStock;
        }
        await client.from('products').update(payload).eq('id', productId);
        debugPrint('DatabaseService: Product $productId stock updated to $newQuantity.');
      } catch (e) {
        debugPrint('DatabaseService: Supabase updateStockQuantity error: $e');
      }
    }
  }

  // ---------------------------------------------------------------------------
  // ORDERS
  // ---------------------------------------------------------------------------
  Future<List<OrderModel>> getOrders() async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final List<dynamic> data = await client
            .from('orders')
            .select()
            .order('created_at', ascending: false);

        if (data.isNotEmpty) {
          final orders = data.map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            if (map.containsKey('customer_name')) map['customerName'] = map['customer_name'];
            if (map.containsKey('customer_email')) map['customerEmail'] = map['customer_email'];
            if (map.containsKey('customer_phone')) map['customerPhone'] = map['customer_phone'];
            if (map.containsKey('shipping_address')) map['shippingAddress'] = map['shipping_address'];
            if (map.containsKey('shipping_fee')) map['shippingFee'] = map['shipping_fee'];
            if (map.containsKey('payment_method')) map['paymentMethod'] = map['payment_method'];
            if (map.containsKey('tracking_number')) map['trackingNumber'] = map['tracking_number'];
            if (map.containsKey('created_at')) map['createdAt'] = map['created_at'];
            if (map.containsKey('estimated_delivery')) map['estimatedDelivery'] = map['estimated_delivery'];

            return OrderModel.fromJson(map);
          }).toList();

          await _saveLocalJson(_ordersKey, orders.map((o) => o.toJson()).toList());
          return orders;
        }
      } catch (e) {
        debugPrint('DatabaseService: Supabase getOrders failed ($e), falling back to local.');
      }
    }

    return _getLocalOrders();
  }

  Future<void> saveOrder(OrderModel order) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final payload = {
          'id': order.id,
          'customer_name': order.customerName,
          'customer_email': order.customerEmail,
          'customer_phone': order.customerPhone,
          'shipping_address': order.shippingAddress,
          'items': order.items.map((i) => i.toJson()).toList(),
          'subtotal': order.subtotal,
          'discount': order.discount,
          'shipping_fee': order.shippingFee,
          'tax': order.tax,
          'total': order.total,
          'status': order.status.name,
          'payment_method': order.paymentMethod,
          'tracking_number': order.trackingNumber,
          'created_at': order.createdAt.toIso8601String(),
          'estimated_delivery': order.estimatedDelivery.toIso8601String(),
        };

        await client.from('orders').upsert(payload);
        debugPrint('DatabaseService: Order ${order.id} synced to Supabase.');
      } catch (e) {
        debugPrint('DatabaseService: Supabase saveOrder error: $e');
      }
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        await client.from('orders').update({'status': status.name}).eq('id', orderId);
        debugPrint('DatabaseService: Order $orderId status updated to ${status.name}');
      } catch (e) {
        debugPrint('DatabaseService: Supabase updateOrderStatus error: $e');
      }
    }
  }

  // ---------------------------------------------------------------------------
  // INVENTORY LOGS
  // ---------------------------------------------------------------------------
  Future<List<InventoryLog>> getInventoryLogs() async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final List<dynamic> data = await client
            .from('inventory_logs')
            .select()
            .order('timestamp', ascending: false)
            .limit(100);

        if (data.isNotEmpty) {
          final logs = data.map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            if (map.containsKey('product_id')) map['productId'] = map['product_id'];
            if (map.containsKey('product_name')) map['productName'] = map['product_name'];
            if (map.containsKey('quantity_changed')) map['quantityChanged'] = map['quantity_changed'];
            if (map.containsKey('previous_stock')) map['previousStock'] = map['previous_stock'];
            if (map.containsKey('new_stock')) map['newStock'] = map['new_stock'];
            if (map.containsKey('performed_by')) map['performedBy'] = map['performed_by'];
            if (map.containsKey('reference_id')) map['referenceId'] = map['reference_id'];

            return InventoryLog(
              id: map['id'] as String,
              productId: map['productId'] as String,
              productName: map['productName'] as String,
              sku: map['sku'] as String,
              type: StockMovementType.values.firstWhere(
                (t) => t.name == map['type'],
                orElse: () => StockMovementType.adjustment,
              ),
              quantityChanged: (map['quantityChanged'] as num).toInt(),
              previousStock: (map['previousStock'] as num).toInt(),
              newStock: (map['newStock'] as num).toInt(),
              warehouse: map['warehouse'] as String,
              note: map['note'] as String? ?? '',
              performedBy: map['performedBy'] as String? ?? 'Warehouse Automation',
              referenceId: map['referenceId'] as String?,
              timestamp: DateTime.parse(map['timestamp'] as String),
            );
          }).toList();

          await _saveLocalJson(_logsKey, logs.map((l) => l.toJson()).toList());
          return logs;
        }
      } catch (e) {
        debugPrint('DatabaseService: Supabase getInventoryLogs failed ($e), falling back to local.');
      }
    }

    return _getLocalLogs();
  }

  Future<void> saveInventoryLog(InventoryLog log) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final payload = {
          'id': log.id,
          'product_id': log.productId,
          'product_name': log.productName,
          'sku': log.sku,
          'type': log.type.name,
          'quantity_changed': log.quantityChanged,
          'previous_stock': log.previousStock,
          'new_stock': log.newStock,
          'warehouse': log.warehouse,
          'note': log.note,
          'performed_by': log.performedBy,
          'reference_id': log.referenceId,
          'timestamp': log.timestamp.toIso8601String(),
        };

        await client.from('inventory_logs').insert(payload);
        debugPrint('DatabaseService: Inventory log ${log.id} synced to Supabase.');
      } catch (e) {
        debugPrint('DatabaseService: Supabase saveInventoryLog error: $e');
      }
    }
  }

  // ---------------------------------------------------------------------------
  // WISHLIST
  // ---------------------------------------------------------------------------
  Future<Set<String>> getWishlist(String userId) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final List<dynamic> data = await client
            .from('wishlists')
            .select('product_id')
            .eq('user_id', userId);

        final ids = data.map((item) => (item as Map)['product_id'] as String).toSet();
        if (ids.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setStringList(_wishlistKey, ids.toList());
          return ids;
        }
      } catch (e) {
        debugPrint('DatabaseService: Supabase getWishlist failed: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_wishlistKey);
    return saved?.toSet() ?? {};
  }

  Future<void> setWishlist(String userId, Set<String> productIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_wishlistKey, productIds.toList());

    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        // Clear and rewrite user wishlist in Supabase
        await client.from('wishlists').delete().eq('user_id', userId);
        if (productIds.isNotEmpty) {
          final rows = productIds.map((pid) => {
            'user_id': userId,
            'product_id': pid,
          }).toList();
          await client.from('wishlists').insert(rows);
        }
      } catch (e) {
        debugPrint('DatabaseService: Supabase setWishlist error: $e');
      }
    }
  }

  // ---------------------------------------------------------------------------
  // LOCAL CACHE HELPERS
  // ---------------------------------------------------------------------------
  Future<List<CategoryItem>> _getLocalCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_categoriesKey);
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        return decoded.map((item) => CategoryItem.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('DatabaseService: local categories load error: $e');
    }
    return List.from(MockData.initialCategories);
  }

  Future<List<Product>> _getLocalProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_productsKey);
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        return decoded.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('DatabaseService: local products load error: $e');
    }
    return List.from(MockData.initialProducts);
  }

  Future<List<OrderModel>> _getLocalOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_ordersKey);
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        return decoded.map((item) => OrderModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('DatabaseService: local orders load error: $e');
    }
    return List.from(MockData.initialOrders);
  }

  Future<List<InventoryLog>> _getLocalLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_logsKey);
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        return decoded.map((item) => InventoryLog.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('DatabaseService: local inventory logs load error: $e');
    }
    return List.from(MockData.initialInventoryLogs);
  }

  Future<void> _saveLocalJson(String key, dynamic object) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(object));
    } catch (e) {
      debugPrint('DatabaseService: _saveLocalJson error for $key: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // FULL SEED TO SUPABASE
  // ---------------------------------------------------------------------------
  Future<int> seedInitialDataToSupabase() async {
    final client = SupabaseConfig.client;
    if (client == null) throw Exception('Supabase client is not connected.');

    int totalSynced = 0;

    // 1. Categories
    for (final cat in MockData.initialCategories) {
      await saveCategory(cat);
      totalSynced++;
    }

    // 2. Products
    for (final prod in MockData.initialProducts) {
      await saveProduct(prod);
      totalSynced++;
    }

    // 3. Orders
    for (final ord in MockData.initialOrders) {
      await saveOrder(ord);
      totalSynced++;
    }

    // 4. Inventory logs
    for (final log in MockData.initialInventoryLogs) {
      await saveInventoryLog(log);
      totalSynced++;
    }

    return totalSynced;
  }
}
