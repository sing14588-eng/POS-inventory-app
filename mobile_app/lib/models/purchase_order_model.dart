class POItem {
  final String productId;
  final String? productName;
  final int quantity;
  final int costPrice;

  POItem({
    required this.productId,
    this.productName,
    required this.quantity,
    required this.costPrice,
  });

  factory POItem.fromJson(Map<String, dynamic> json) {
    return POItem(
      productId:
          json['product'] is String ? json['product'] : json['product']['_id'],
      productName: json['product'] is Map ? json['product']['name'] : null,
      quantity: json['quantity'],
      costPrice: json['costPrice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': productId,
      'quantity': quantity,
      'costPrice': costPrice,
    };
  }
}

class PurchaseOrder {
  final String id;
  final String supplierName;
  final List<POItem> items;
  final int totalCost;
  final String status;
  final String? receivedDate;
  final String createdAt;

  PurchaseOrder({
    required this.id,
    required this.supplierName,
    required this.items,
    required this.totalCost,
    required this.status,
    this.receivedDate,
    required this.createdAt,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['_id'],
      supplierName:
          json['supplier'] is Map ? json['supplier']['name'] : 'Unknown',
      items: (json['items'] as List).map((i) => POItem.fromJson(i)).toList(),
      totalCost: json['totalCost'],
      status: json['status'],
      receivedDate: json['receivedDate'],
      createdAt: json['createdAt'],
    );
  }
}
