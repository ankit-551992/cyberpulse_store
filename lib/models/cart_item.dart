import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  String? selectedColor;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedColor,
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
    'selectedColor': selectedColor,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    product: Product.fromJson(json['product'] as Map<String, dynamic>),
    quantity: json['quantity'] as int? ?? 1,
    selectedColor: json['selectedColor'] as String?,
  );
}
