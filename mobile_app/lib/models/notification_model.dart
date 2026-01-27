class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // INFO, WARNING, SUCCESS, ERROR
  final bool isRead;
  final String createdAt;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id'],
      title: json['title'],
      message: json['message'],
      type: json['type'] ?? 'INFO',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'],
      data:
          json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
    );
  }
}
