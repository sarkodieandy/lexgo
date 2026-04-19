class Course {
  const Course({
    this.id = '',
    required this.code,
    required this.title,
    required this.category,
    required this.institution,
    required this.image,
    required this.createdAt,
    this.description,
    this.level = '',
  });

  final String id;
  final String code;
  final String title;
  final String category;
  final String institution;
  final String image;
  final DateTime createdAt;
  final String? description;
  final String level;

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      code: json['courseCode'] as String? ?? json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      institution: json['institution'] as String? ?? '',
      image: json['imageUrl'] as String? ?? json['image'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      description: json['description'] as String?,
      level: json['level'] as String? ?? '',
    );
  }
}
