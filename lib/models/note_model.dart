class Note {
  final String id;
  final String userId;
  final String title;
  final String legalTopic;
  final String importanceLevel;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.legalTopic,
    required this.importanceLevel,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: (json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      legalTopic: (json['legalTopic'] ?? '').toString(),
      importanceLevel: (json['importanceLevel'] ?? 'Low Priority').toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'title': title,
      'legalTopic': legalTopic,
      'importanceLevel': importanceLevel,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Pagination {
  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;
  final int startIndex;
  final int endIndex;

  Pagination({
    required this.page,
    required this.limit,
    required this.totalItems,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
    required this.startIndex,
    required this.endIndex,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      hasPrevPage: json['hasPrevPage'] as bool? ?? false,
      startIndex: (json['startIndex'] as num?)?.toInt() ?? 0,
      endIndex: (json['endIndex'] as num?)?.toInt() ?? 0,
    );
  }
}
