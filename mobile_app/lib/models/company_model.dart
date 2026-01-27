class Company {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final bool isActive;
  final String plan;
  final String logoUrl;
  final String primaryColor;
  final String secondaryColor;
  final String currencySymbol;
  final String? receiptHeader;
  final String receiptFooter;

  Company({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    required this.isActive,
    required this.plan,
    required this.logoUrl,
    required this.primaryColor,
    required this.secondaryColor,
    required this.currencySymbol,
    this.receiptHeader,
    this.receiptFooter = 'Thank you for your business!',
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      isActive: json['isActive'] ?? true,
      plan: json['plan'] ?? 'basic',
      logoUrl: json['logoUrl'] ?? '',
      primaryColor: json['primaryColor'] ?? '#000000',
      secondaryColor: json['secondaryColor'] ?? '#666666',
      currencySymbol: json['currencySymbol'] ?? '\$',
      receiptHeader: json['receiptHeader'],
      receiptFooter: json['receiptFooter'] ?? 'Thank you for your business!',
    );
  }
}
