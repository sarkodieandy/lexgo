class CourseResource {
  const CourseResource({
    required this.id,
    required this.title,
    required this.size,
    required this.timestamp,
    this.downloadUrl,
  });

  final String id;
  final String title;
  final String size;
  final DateTime timestamp;
  final String? downloadUrl;

  String get formattedTimestamp {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = monthNames[timestamp.month - 1];
    final day = timestamp.day.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final isPm = timestamp.hour >= 12;
    final hour = (timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12)
        .toString()
        .padLeft(2, '0');
    final suffix = isPm ? 'PM' : 'AM';
    return '$size • $month $day, ${timestamp.year} • $hour:$minute $suffix';
  }

  factory CourseResource.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(
          json['createdAt'] as String? ?? '',
        ) ??
        DateTime.tryParse(json['timestamp'] as String? ?? '') ??
        DateTime.now();

    final title =
        (json['title'] as String?) ??
        (json['name'] as String?) ??
        (json['originalName'] as String?) ??
        (json['fileName'] as String?) ??
        'Resource';

    String parseSize(dynamic value) {
      if (value == null) return '0MB';
      if (value is String && value.trim().isNotEmpty) return value;
      if (value is num) {
        final mb = value / (1024 * 1024);
        return '${mb.toStringAsFixed(1)}MB';
      }
      return '0MB';
    }

    final downloadUrl = json['downloadUrl'] as String? ?? json['url'] as String?;

    return CourseResource(
      id: json['_id'] as String? ?? '',
      title: title,
      size: parseSize(json['size'] ?? json['fileSize'] ?? json['bytes']),
      timestamp: createdAt,
      downloadUrl: downloadUrl,
    );
  }
}
