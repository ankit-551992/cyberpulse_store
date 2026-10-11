class Product {
  final String id;
  final String sku;
  final String name;
  final String brand;
  final String category;
  final String description;
  final double price;
  final double originalPrice;
  final int stockQuantity;
  final int lowStockThreshold;
  final String warehouseLocation;
  final Map<String, int> colorStock;
  final double rating;
  final int reviewCount;
  final List<String> imageUrls;
  final List<String> tags;
  final Map<String, String> specs;
  final List<String> colors;
  final bool isFeatured;
  final bool isTrending;
  final DateTime createdAt;

  Product({
    required this.id,
    String? sku,
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.stockQuantity,
    this.lowStockThreshold = 5,
    this.warehouseLocation = 'Bengaluru Central Hub - Bay A-1',
    Map<String, int>? colorStock,
    this.rating = 4.8,
    this.reviewCount = 0,
    required this.imageUrls,
    this.tags = const [],
    this.specs = const {},
    this.colors = const [],
    this.isFeatured = false,
    this.isTrending = false,
    DateTime? createdAt,
  })  : sku = sku ?? 'SKU-${id.toUpperCase().replaceAll("PROD-", "")}',
        colorStock = colorStock ?? {},
        createdAt = createdAt ?? DateTime.now();

  int get discountPercentage {
    if (originalPrice <= price) return 0;
    return (((originalPrice - price) / originalPrice) * 100).round();
  }

  bool get isInStock => stockQuantity > 0;
  bool get isOutOfStock => stockQuantity <= 0;
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= lowStockThreshold;

  double get totalValuation => stockQuantity * price;

  int getStockForColor(String color) {
    if (colorStock.containsKey(color)) {
      return colorStock[color] ?? 0;
    }
    // If colorStock is not specifically broken down, distribute stock or return total
    return stockQuantity;
  }

  Product copyWith({
    String? id,
    String? sku,
    String? name,
    String? brand,
    String? category,
    String? description,
    double? price,
    double? originalPrice,
    int? stockQuantity,
    int? lowStockThreshold,
    String? warehouseLocation,
    Map<String, int>? colorStock,
    double? rating,
    int? reviewCount,
    List<String>? imageUrls,
    List<String>? tags,
    Map<String, String>? specs,
    List<String>? colors,
    bool? isFeatured,
    bool? isTrending,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      warehouseLocation: warehouseLocation ?? this.warehouseLocation,
      colorStock: colorStock ?? this.colorStock,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrls: imageUrls ?? this.imageUrls,
      tags: tags ?? this.tags,
      specs: specs ?? this.specs,
      colors: colors ?? this.colors,
      isFeatured: isFeatured ?? this.isFeatured,
      isTrending: isTrending ?? this.isTrending,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sku': sku,
    'name': name,
    'brand': brand,
    'category': category,
    'description': description,
    'price': price,
    'originalPrice': originalPrice,
    'stockQuantity': stockQuantity,
    'lowStockThreshold': lowStockThreshold,
    'warehouseLocation': warehouseLocation,
    'colorStock': colorStock,
    'rating': rating,
    'reviewCount': reviewCount,
    'imageUrls': imageUrls,
    'tags': tags,
    'specs': specs,
    'colors': colors,
    'isFeatured': isFeatured,
    'isTrending': isTrending,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    sku: json['sku'] as String?,
    name: json['name'] as String,
    brand: json['brand'] as String,
    category: json['category'] as String,
    description: json['description'] as String,
    price: (json['price'] as num).toDouble(),
    originalPrice: (json['originalPrice'] as num).toDouble(),
    stockQuantity: (json['stockQuantity'] as num).toInt(),
    lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 5,
    warehouseLocation: json['warehouseLocation'] as String? ?? 'Bengaluru Central Hub - Bay A-1',
    colorStock: json['colorStock'] != null
        ? Map<String, int>.from(json['colorStock'] as Map)
        : {},
    rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
    reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
    imageUrls: List<String>.from(json['imageUrls'] ?? []),
    tags: List<String>.from(json['tags'] ?? []),
    specs: Map<String, String>.from(json['specs'] ?? {}),
    colors: List<String>.from(json['colors'] ?? []),
    isFeatured: json['isFeatured'] as bool? ?? false,
    isTrending: json['isTrending'] as bool? ?? false,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
  );
}
