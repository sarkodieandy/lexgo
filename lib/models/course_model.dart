class Course {
  final String id;
  final String title;
  final String? courseCode;
  final String? institution;
  final String? level;

  Course({
    required this.id,
    required this.title,
    this.courseCode,
    this.institution,
    this.level,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['_id'] ?? '',
      title: json['title'] ?? 'Unknown Course',
      courseCode: json['courseCode'],
      institution: json['institution'],
      level: json['level'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'courseCode': courseCode,
      'institution': institution,
      'level': level,
    };
  }
}
