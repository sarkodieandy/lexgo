import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ReviewQuizScreen extends StatelessWidget {
  const ReviewQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandDark,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              color: AppColors.brandDark,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.brandNavy,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_back_ios_new, color: AppColors.brandWhite, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Review Quiz',
                        style: TextStyle(
                          color: AppColors.brandWhite,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.brandWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Review Quiz',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brandDark,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildSection(
                          title: 'Quiz Information',
                          children: const [
                            _KeyValuePair(label: 'Title', value: 'Quiz one'),
                            _KeyValuePair(label: 'Description', value: 'First Quiz to test your knowledge'),
                            _KeyValuePair(label: 'Instruction', value: 'Make sure to answer all questions'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSection(
                          title: 'Quiz Information',
                          children: const [
                            _KeyValuePair(label: 'Total Questions', value: '20'),
                            SizedBox(height: 4),
                            Text(
                              '18 Multiple choice, 2 Checkboxes, 1 Short answer',
                              style: TextStyle(
                                color: AppColors.mutedText,
                                fontSize: 12,
                                height: 1.33,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSection(
                          title: 'Settings',
                          children: const [
                            _KeyValuePair(label: 'Duration', value: '45 minutes'),
                            _KeyValuePair(label: 'Max Attempts', value: '1'),
                            _KeyValuePair(label: 'Shuffle Questions', value: 'Yes'),
                            _KeyValuePair(label: 'Shuffle Answers', value: 'Yes'),
                            _KeyValuePair(label: 'Show Scores Immediately', value: 'Yes'),
                            _KeyValuePair(label: 'Starting Date and Time', value: '12 Sept 2025, 09:00PM'),
                            _KeyValuePair(label: 'Ending Date and Time', value: '14 Sept 2025, 09:00PM'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: AppColors.brandWhite,
                                  side: const BorderSide(color: AppColors.brandDark),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).maybePop(),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: AppColors.brandDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.brandDark,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Quiz published')),
                                  );
                                },
                                child: const Text(
                                  'Publish Quiz',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: const Color(0xFFFFFBFB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadows: const [
          BoxShadow(
            color: Color(0x14F5F5F5),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _KeyValuePair extends StatelessWidget {
  const _KeyValuePair({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label : ',
            style: const TextStyle(
              color: AppColors.brandDark,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.brandDark,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
