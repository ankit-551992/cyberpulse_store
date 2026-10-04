import 'cart_item.dart';

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }
}

class OrderModel {
  final String id;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String shippingAddress;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double shippingFee;
  final double tax;
  final double total;
  final OrderStatus status;
  final String paymentMethod;
  final String trackingNumber;
  final DateTime createdAt;
  final DateTime estimatedDelivery;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.shippingAddress,
    required this.items,
    required this.subtotal,
    this.discount = 0.0,
    this.shippingFee = 0.0,
    this.tax = 0.0,
    required this.total,
    this.status = OrderStatus.pending,
    required this.paymentMethod,
    required this.trackingNumber,
    DateTime? createdAt,
    DateTime? estimatedDelivery,
  })  : createdAt = createdAt ?? DateTime.now(),
        estimatedDelivery = estimatedDelivery ??
            DateTime.now().add(const Duration(days: 4));

  OrderModel copyWith({
    String? id,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? shippingAddress,
    List<CartItem>? items,
    double? subtotal,
    double? discount,
    double? shippingFee,
    double? tax,
    double? total,
    OrderStatus? status,
    String? paymentMethod,
    String? trackingNumber,
    DateTime? createdAt,
    DateTime? estimatedDelivery,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      shippingFee: shippingFee ?? this.shippingFee,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      createdAt: createdAt ?? this.createdAt,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerName': customerName,
    'customerEmail': customerEmail,
    'customerPhone': customerPhone,
    'shippingAddress': shippingAddress,
    'items': items.map((i) => i.toJson()).toList(),
    'subtotal': subtotal,
    'discount': discount,
    'shippingFee': shippingFee,
    'tax': tax,
    'total': total,
    'status': status.name,
    'paymentMethod': paymentMethod,
    'trackingNumber': trackingNumber,
    'createdAt': createdAt.toIso8601String(),
    'estimatedDelivery': estimatedDelivery.toIso8601String(),
  };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'] as String,
    customerName: json['customerName'] as String,
    customerEmail: json['customerEmail'] as String,
    customerPhone: json['customerPhone'] as String,
    shippingAddress: json['shippingAddress'] as String,
    items: (json['items'] as List<dynamic>)
        .map((i) => CartItem.fromJson(i as Map<String, dynamic>))
        .toList(),
    subtotal: (json['subtotal'] as num).toDouble(),
    discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
    shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0.0,
    tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
    total: (json['total'] as num).toDouble(),
    status: OrderStatusExtension.fromString(json['status'] as String),
    paymentMethod: json['paymentMethod'] as String,
    trackingNumber: json['trackingNumber'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    estimatedDelivery: DateTime.parse(json['estimatedDelivery'] as String),
  );
}
