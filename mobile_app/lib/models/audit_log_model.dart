class AuditLog {
  final String id;
  final String userName;
  final String? branchName;
  final String? companyName;
  final String action;
  final String? description;
  final String? itemType;
  final String? itemId;
  final DateTime createdAt;

  AuditLog({
    required this.id,
    required this.userName,
    this.branchName,
    this.companyName,
    required this.action,
    this.description,
    this.itemType,
    this.itemId,
    required this.createdAt,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['_id'],
      userName: json['user'] != null && json['user'] is Map
          ? json['user']['name']
          : 'Unknown',
      branchName: json['branch'] != null && json['branch'] is Map
          ? json['branch']['name']
          : null,
      companyName: json['company'] != null && json['company'] is Map
          ? json['company']['name']
          : null,
      action: json['action'],
      description: json['description'] ?? json['details'],
      itemType: json['itemType'],
      itemId: json['itemId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
