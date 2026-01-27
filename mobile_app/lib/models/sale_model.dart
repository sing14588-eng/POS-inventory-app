class SaleItem {
  final String productId;
  final String productName;
  final int quantity;
  final String unitType;
  final int pricePerUnit;
  final int total;
  final String? shelfLocation;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitType,
    required this.pricePerUnit,
    required this.total,
    this.shelfLocation,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    String? location;
    if (json['product'] is Map && json['product']['shelfLocation'] != null) {
      location = json['product']['shelfLocation'];
    }

    return SaleItem(
      productId:
          json['product'] is String ? json['product'] : json['product']['_id'],
      productName: json['productName'] ??
          (json['product'] is Map ? json['product']['name'] : 'Unknown'),
      quantity: json['quantity'],
      unitType: json['unitType'],
      pricePerUnit: json['pricePerUnit'],
      total: json['total'],
      shelfLocation: location,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': productId,
      'productName': productName,
      'quantity': quantity,
      'unitType': unitType,
      'pricePerUnit': pricePerUnit,
      'total': total,
      // 'shelfLocation' is read-only from backend, no need to send back usually, but valid to keep
    };
  }
}

class Sale {
  final String id;
  final List<SaleItem> items;
  final int totalAmount;
  final double vatAmount;
  final bool isCredit;
  final String status;
  final bool isPrepared;
  final String createdAt;
  final String refundStatus;
  final String? refundReason;
  final bool creditSettled;

  Sale({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.vatAmount,
    required this.isCredit,
    required this.status,
    required this.isPrepared,
    required this.createdAt,
    this.refundStatus = 'none',
    this.refundReason,
    this.creditSettled = true,
    this.branchId,
  });

  final String? branchId;

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['_id'],
      items: (json['items'] as List).map((i) => SaleItem.fromJson(i)).toList(),
      totalAmount: json['totalAmount'],
      vatAmount: (json['vatAmount'] ?? 0).toDouble(),
      isCredit: json['isCredit'],
      status: json['status'],
      isPrepared: json['isPrepared'] ?? false,
      createdAt: json['createdAt'],
      refundStatus: json['refundStatus'] ?? 'none',
      refundReason: json['refundReason'],
      creditSettled:
          json['creditSettled'] ?? true, // Default to true if missing
      branchId: json['branch'],
    );
  }
}
