class NotificationItem {
  final String title;
  final String message;
  final DateTime timestamp;

  NotificationItem({
    required this.title,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
      };

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        title: json['title'],
        message: json['message'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}
