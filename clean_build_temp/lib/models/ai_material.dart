enum GenerationJobStatus {
  idle,
  pending,
  processing,
  completed,
  failed;

  static GenerationJobStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return GenerationJobStatus.pending;
      case 'processing':
        return GenerationJobStatus.processing;
      case 'completed':
        return GenerationJobStatus.completed;
      case 'failed':
        return GenerationJobStatus.failed;
      default:
        return GenerationJobStatus.idle;
    }
  }

  bool get isFinal => this == completed || this == failed;
  bool get isInProgress => this == pending || this == processing;
}

class AiMaterial {
  const AiMaterial({
    required this.id,
    required this.topic,
    required this.content,
    this.type = 'topic',
    this.tags = const [],
    this.createdAt,
  });

  final String id;
  final String topic;
  final String content;
  final String type;
  final List<String> tags;
  final DateTime? createdAt;

  factory AiMaterial.fromJson(Map<String, dynamic> json) {
    final tagsRaw = json['tags'];
    final tags = tagsRaw is List ? tagsRaw.map((e) => e.toString()).toList() : <String>[];
    
    return AiMaterial(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      topic: json['topic'] as String? ?? json['title'] as String? ?? 'Untitled Topic',
      content: json['content'] as String? ?? json['text'] as String? ?? '',
      type: json['type'] as String? ?? 'topic',
      tags: tags,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}
