class Supplier {
  final String id;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final List<String> categories;

  Supplier({
    required this.id,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.categories = const [],
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['_id'],
      name: json['name'],
      contactPerson: json['contactPerson'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : [],
    );
  }
}
