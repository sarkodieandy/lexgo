import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SubmissionRecord {
  const SubmissionRecord({
    required this.name,
    required this.id,
    required this.submittedAt,
    required this.timeTaken,
    required this.score,
    required this.correctAnswer,
    required this.color,
  });

  final String name;
  final String id;
  final String submittedAt;
  final String timeTaken;
  final String score;
  final String correctAnswer;
  final Color color;
}

class SubmissionsPage extends StatelessWidget {
  const SubmissionsPage({super.key});

  static final List<SubmissionRecord> _records = [
    SubmissionRecord(
      name: 'Mike Adjatey',
      id: '22189872',
      submittedAt: 'Submitted Oct 29, 2025 07:30PM',
      timeTaken: 'Time Taken : 30minutes',
      score: '18/20',
      correctAnswer: 'Correct Answer: 18/20',
      color: Colors.red,
    ),
    SubmissionRecord(
      name: 'Andrew Kaine',
      id: '22153103',
      submittedAt: 'Submitted Oct 29, 2025 07:30PM',
      timeTaken: 'Time Taken : 1hour 50minutes',
      score: '18/20',
      correctAnswer: 'Correct Answer: 18/20',
      color: Colors.pink,
    ),
    SubmissionRecord(
      name: 'Kofi',
      id: '22125693',
      submittedAt: 'Submitted Oct 29, 2025 07:30PM',
      timeTaken: 'Time Taken : 1hour 50minutes',
      score: '14/20',
      correctAnswer: 'Correct Answer: 18/20',
      color: Colors.purple,
    ),
    SubmissionRecord(
      name: 'Kojo',
      id: '22195055',
      submittedAt: 'Submitted Oct 29, 2025 07:30PM',
      timeTaken: 'Time Taken : 1hour 50minutes',
      score: '14/20',
      correctAnswer: 'Correct Answer: 18/20',
      color: Colors.deepPurple,
    ),
    SubmissionRecord(
      name: 'Yaw',
      id: '22174641',
      submittedAt: 'Submitted Oct 29, 2025 07:30PM',
      timeTaken: 'Time Taken : 1hour 50minutes',
      score: '12/20',
      correctAnswer: 'Correct Answer: 18/20',
      color: Colors.amber,
    ),
    SubmissionRecord(
      name: 'Ama',
      id: '22130074',
      submittedAt: 'Submitted Oct 29, 2025 07:30PM',
      timeTaken: 'Time Taken : 1hour 50minutes',
      score: '12/20',
      correctAnswer: 'Correct Answer: 18/20',
      color: Colors.amberAccent,
    ),
    SubmissionRecord(
      name: 'Kwesi',
      id: '22191057',
      submittedAt: 'Submitted Oct 29, 2025 07:30PM',
      timeTaken: 'Time Taken : 1hour 50minutes',
      score: '10/20',
      correctAnswer: 'Correct Answer: 18/20',
      color: Colors.indigo,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020F20),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B2138),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Quiz one',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B2138),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.more_vert, color: Colors.white),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.brandWhite,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.mutedText),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '|Search Courses...',
                        hintStyle: TextStyle(color: AppColors.mutedText),
                      ),
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B2138),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _records.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _records[index];
                    return _SubmissionCard(record: item);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({required this.record});

  final SubmissionRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.brandWhite,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: record.color,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.id,
                      style: const TextStyle(color: AppColors.mutedText),
                    ),
                  ],
                ),
              ),
              Text(
                record.score,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 16,
                color: AppColors.mutedText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  record.correctAnswer,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.mutedText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  record.submittedAt,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.mutedText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  record.timeTaken,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
