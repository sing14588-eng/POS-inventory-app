class Branch {
  final String id;
  final String companyId;
  final String name;
  final String? address;
  final String? phone;
  final bool isActive;

  Branch({
    required this.id,
    required this.companyId,
    required this.name,
    this.address,
    this.phone,
    this.isActive = true,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['_id'],
      companyId: json['company'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      isActive: json['isActive'] ?? true,
    );
  }
}
