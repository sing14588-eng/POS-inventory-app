class User {
  final String id;
  final String name;
  final String email;
  final String role; // Active role
  final List<String> roles; // All assigned roles
  final String token;
  final String? companyId;
  final String? companyName;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.roles,
    required this.token,
    this.companyId,
    this.companyName,
    this.branchId,
    this.branchName,
    this.onboardingCompleted = false,
  });

  final String? branchId;
  final String? branchName;
  final bool onboardingCompleted;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] ??
          (json['roles'] != null && (json['roles'] as List).isNotEmpty
              ? json['roles'][0]
              : ''),
      roles: json['roles'] != null ? List<String>.from(json['roles']) : [],
      token: json['token'],
      companyId: json['company'] != null
          ? (json['company'] is String
              ? json['company']
              : json['company']['_id'])
          : null,
      companyName: json['company'] != null && json['company'] is Map
          ? json['company']['name']
          : null,
      branchId: json['branch'] != null
          ? (json['branch'] is String ? json['branch'] : json['branch']['_id'])
          : null,
      branchName: json['branch'] != null && json['branch'] is Map
          ? json['branch']['name']
          : null,
      onboardingCompleted: json['onboardingCompleted'] ?? false,
    );
  }
}
