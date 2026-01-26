class Product {
  final String id;
  final String name;
  final String category;
  final String size;
  final int fruitQuantity;
  final String unitType;
  final int currentStock;
  final String shelfLocation;
  final int price;
  final String? barcode;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.size,
    required this.fruitQuantity,
    required this.unitType,
    required this.currentStock,
    required this.shelfLocation,
    required this.price,
    this.barcode,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      category: json['category'],
      size: json['size'],
      fruitQuantity: json['fruitQuantity'],
      unitType: json['unitType'],
      currentStock: json['currentStock'],
      shelfLocation: json['shelfLocation'],
      price: json['price'] ?? 0,
      barcode: json['barcode'],
    );
  }
}
