class Course {
  const Course({
    required this.code,
    required this.title,
    required this.category,
    required this.institution,
    required this.image,
    required this.createdAt,
  });

  final String code;
  final String title;
  final String category;
  final String institution;
  final String image;
  final DateTime createdAt;
}
