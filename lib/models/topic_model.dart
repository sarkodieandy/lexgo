class Subtopic {
  final String id;
  final String title;

  Subtopic({required this.id, required this.title});

  factory Subtopic.fromJson(Map<String, dynamic> json) {
    return Subtopic(
      id: json['_id'] ?? '',
      title: json['title'] ?? 'Unknown Subtopic',
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'title': title};
  }
}

class Topic {
  final String id;
  final String title;
  final String? pagesInfo;
  final List<Subtopic>?
  subtopics; // Make nullable to avoid deeply fetching everything at once sometimes

  Topic({
    required this.id,
    required this.title,
    this.pagesInfo,
    this.subtopics,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['_id'] ?? '',
      title: json['title'] ?? 'Unknown Topic',
      pagesInfo: json['pagesInfo'],
      subtopics: json['subtopics'] != null
          ? (json['subtopics'] as List)
                .map((i) => Subtopic.fromJson(i))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'pagesInfo': pagesInfo,
      'subtopics': subtopics?.map((e) => e.toJson()).toList(),
    };
  }
}
