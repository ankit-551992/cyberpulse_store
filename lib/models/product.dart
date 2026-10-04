class Product {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String description;
  final double price;
  final double originalPrice;
  final int stockQuantity;
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
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.stockQuantity,
    this.rating = 4.8,
    this.reviewCount = 0,
    required this.imageUrls,
    this.tags = const [],
    this.specs = const {},
    this.colors = const [],
    this.isFeatured = false,
    this.isTrending = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get discountPercentage {
    if (originalPrice <= price) return 0;
    return (((originalPrice - price) / originalPrice) * 100).round();
  }

  bool get isInStock => stockQuantity > 0;
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= 5;

  Product copyWith({
    String? id,
    String? name,
    String? brand,
    String? category,
    String? description,
    double? price,
    double? originalPrice,
    int? stockQuantity,
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
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
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
    'name': name,
    'brand': brand,
    'category': category,
    'description': description,
    'price': price,
    'originalPrice': originalPrice,
    'stockQuantity': stockQuantity,
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
    name: json['name'] as String,
    brand: json['brand'] as String,
    category: json['category'] as String,
    description: json['description'] as String,
    price: (json['price'] as num).toDouble(),
    originalPrice: (json['originalPrice'] as num).toDouble(),
    stockQuantity: (json['stockQuantity'] as num).toInt(),
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
