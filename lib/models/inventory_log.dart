enum StockMovementType {
  restock,
  orderSale,
  orderCancelled,
  adjustment,
  damaged,
  initial,
  customerReturn,
  transfer,
}

extension StockMovementTypeExt on StockMovementType {
  String get label {
    switch (this) {
      case StockMovementType.restock:
        return 'Restock / Inbound';
      case StockMovementType.orderSale:
        return 'Order Sale Deduct';
      case StockMovementType.orderCancelled:
        return 'Order Cancel Restock';
      case StockMovementType.adjustment:
        return 'Manual Audit Correction';
      case StockMovementType.damaged:
        return 'Damaged / Defect Write-off';
      case StockMovementType.initial:
        return 'Catalog Initialization';
      case StockMovementType.customerReturn:
        return 'Customer RMA Return';
      case StockMovementType.transfer:
        return 'Warehouse Transfer';
    }
  }

  String get code {
    switch (this) {
      case StockMovementType.restock:
        return 'INBOUND';
      case StockMovementType.orderSale:
        return 'SALE';
      case StockMovementType.orderCancelled:
        return 'RETURN';
      case StockMovementType.adjustment:
        return 'AUDIT';
      case StockMovementType.damaged:
        return 'LOSS';
      case StockMovementType.initial:
        return 'INIT';
      case StockMovementType.customerReturn:
        return 'RMA';
      case StockMovementType.transfer:
        return 'TRANSFER';
    }
  }
}

class InventoryLog {
  final String id;
  final String productId;
  final String productName;
  final String sku;
  final StockMovementType type;
  final int quantityChanged;
  final int previousStock;
  final int newStock;
  final String warehouse;
  final DateTime timestamp;
  final String note;
  final String performedBy;
  final String? referenceId;

  InventoryLog({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.type,
    required this.quantityChanged,
    required this.previousStock,
    required this.newStock,
    required this.warehouse,
    DateTime? timestamp,
    this.note = '',
    this.performedBy = 'Warehouse Automation',
    this.referenceId,
  }) : timestamp = timestamp ?? DateTime.now();

  // Aliases for compatibility
  int get quantityDelta => quantityChanged;
  int get previousQuantity => previousStock;
  int get newQuantity => newStock;
  String get reason => note;

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'productName': productName,
    'sku': sku,
    'type': type.name,
    'quantityChanged': quantityChanged,
    'previousStock': previousStock,
    'newStock': newStock,
    'warehouse': warehouse,
    'timestamp': timestamp.toIso8601String(),
    'note': note,
    'performedBy': performedBy,
    'referenceId': referenceId,
  };

  factory InventoryLog.fromJson(Map<String, dynamic> json) {
    return InventoryLog(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      sku: json['sku'] as String? ?? 'SKU-UNKNOWN',
      type: StockMovementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => StockMovementType.adjustment,
      ),
      quantityChanged: (json['quantityChanged'] as num).toInt(),
      previousStock: (json['previousStock'] as num).toInt(),
      newStock: (json['newStock'] as num).toInt(),
      warehouse: json['warehouse'] as String? ?? 'Bengaluru Central Hub',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      note: json['note'] as String? ?? '',
      performedBy: json['performedBy'] as String? ?? 'System Admin',
      referenceId: json['referenceId'] as String?,
    );
  }
}
