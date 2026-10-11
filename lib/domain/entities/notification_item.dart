class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.topic,
    this.refType,
    this.refId,
    required this.route,
    required this.publishedAt,
    required this.unread,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final String? imageUrl;
  final String topic;
  final String? refType;
  final String? refId;
  final String route;
  final DateTime publishedAt;
  final bool unread;

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'General',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      topic: json['topic']?.toString() ?? 'all',
      refType: json['refType']?.toString(),
      refId: json['refId']?.toString(),
      route: json['route']?.toString() ?? '/',
      publishedAt: DateTime.tryParse(json['publishedAt']?.toString() ?? '') ??
          DateTime.now(),
      unread: json['unread'] == true,
    );
  }
}
