import 'user_model.dart';
import 'course_model.dart';

class EnrollmentRequest {
  final String id;
  final User? user; // Populated when fetching requests as a lecturer
  final Course? course; // Populated optionally, depending on the endpoint
  final String status;
  final DateTime? createdAt;

  EnrollmentRequest({
    required this.id,
    this.user,
    this.course,
    required this.status,
    this.createdAt,
  });

  factory EnrollmentRequest.fromJson(Map<String, dynamic> json) {
    return EnrollmentRequest(
      id: json['_id'] ?? '',
      user: json['userId'] != null ? User.fromJson(json['userId']) : null,
      course: json['courseId'] != null
          ? Course.fromJson(json['courseId'])
          : null,
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': user?.toJson(),
      'courseId': course?.toJson(),
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
