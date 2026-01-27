class AuditLog {
  final String id;
  final String userName;
  final String? branchName;
  final String action;
  final String? details;
  final String? itemType;
  final String? itemId;
  final String createdAt;

  AuditLog({
    required this.id,
    required this.userName,
    this.branchName,
    required this.action,
    this.details,
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
      action: json['action'],
      details: json['details'],
      itemType: json['itemType'],
      itemId: json['itemId'],
      createdAt: json['createdAt'],
    );
  }
}
