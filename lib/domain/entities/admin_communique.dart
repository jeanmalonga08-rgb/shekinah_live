class AdminCommunique {
  const AdminCommunique({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.status,
    this.imageUrl,
    this.publishedAt,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String body;
  final int type;
  final int status;
  final String? imageUrl;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isDraft => status == 0;
  bool get isPublished => status == 1;
  bool get isArchived => status == 2;

  factory AdminCommunique.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(Object? value) =>
        value == null ? null : DateTime.tryParse(value.toString());

    return AdminCommunique(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      type: (json['type'] as num?)?.toInt() ?? 1,
      status: (json['status'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl']?.toString(),
      publishedAt: parseDate(json['publishedAt']),
      expiresAt: parseDate(json['expiresAt']),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }
}

class AdminSession {
  const AdminSession({
    required this.accessToken,
    required this.expiresAt,
    required this.fullName,
    required this.role,
  });

  final String accessToken;
  final DateTime expiresAt;
  final String fullName;
  final String role;

  bool get isExpired => !expiresAt.isAfter(DateTime.now());

  factory AdminSession.fromJson(Map<String, dynamic> json) => AdminSession(
        accessToken: json['accessToken']?.toString() ?? '',
        expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? '') ??
            DateTime.now(),
        fullName: json['fullName']?.toString() ?? '',
        role: json['role']?.toString() ?? '',
      );
}