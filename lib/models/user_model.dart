class UserProgress {
  final int lessonsCompleted;
  final int learningStreak;

  UserProgress({required this.lessonsCompleted, required this.learningStreak});

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      lessonsCompleted: json['lessonsCompleted'] ?? 0,
      learningStreak: json['learningStreak'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonsCompleted': lessonsCompleted,
      'learningStreak': learningStreak,
    };
  }
}

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String? otherName;
  final String? phoneNumber;
  final String? university;
  final String? acadamicLevel;
  final String? program;
  final String? studentId;
  final String email;
  final String role;
  final UserProgress progress;
  final String? detectedCountry;
  final DateTime? createdAt;
  final bool isVerified;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.otherName,
    this.phoneNumber,
    this.university,
    this.acadamicLevel,
    this.program,
    this.studentId,
    required this.email,
    required this.role,
    required this.progress,
    this.detectedCountry,
    this.createdAt,
    this.isVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      otherName: json['otherName'],
      phoneNumber: json['phoneNumber'],
      university: json['university'],
      acadamicLevel: json['acadamicLevel'],
      program: json['program'],
      studentId: json['studentId'],
      email: json['email'] ?? '',
      role: json['role'] ?? 'student',
      progress: json['progress'] != null
          ? UserProgress.fromJson(json['progress'])
          : UserProgress(lessonsCompleted: 0, learningStreak: 0),
      detectedCountry: json['detectedCountry'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'otherName': otherName,
      'phoneNumber': phoneNumber,
      'university': university,
      'acadamicLevel': acadamicLevel,
      'program': program,
      'studentId': studentId,
      'email': email,
      'role': role,
      'progress': progress.toJson(),
      'detectedCountry': detectedCountry,
      'createdAt': createdAt?.toIso8601String(),
      'isVerified': isVerified,
    };
  }
}
