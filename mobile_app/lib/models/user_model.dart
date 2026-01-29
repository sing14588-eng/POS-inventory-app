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
    this.isActive = true,
    this.onboardingCompleted = false,
    this.passwordChanged = true,
  });

  final String? branchId;
  final String? branchName;
  final bool isActive;
  final bool onboardingCompleted;
  final bool passwordChanged;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      role: json['roles'] != null && (json['roles'] as List).isNotEmpty
          ? json['roles'][0] // Default active role is the first one
          : (json['role'] ?? ''), // Fallback to legacy role
      roles: json['roles'] != null
          ? List<String>.from(json['roles'])
          : (json['role'] != null ? [json['role']] : []), // Fallback
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
      isActive: json['isActive'] ?? true,
      onboardingCompleted: json['onboardingCompleted'] ?? false,
      passwordChanged: json['passwordChanged'] ?? true,
    );
  }
}
