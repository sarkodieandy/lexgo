import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class Course {
  const Course({
    required this.code,
    required this.title,
    required this.category,
    required this.institution,
    required this.image,
  });

  final String code;
  final String title;
  final String category;
  final String institution;
  final String image;
}

class Courses extends StatelessWidget {
  Courses({super.key});

  final List<Course> _courses = const [
    Course(
      code: 'LAW 001',
      title: 'Introduction to Law',
      category: 'Administrative Law',
      institution: 'University of Ghana School of Law',
      image: 'assets/Course Card2.png',
    ),
    Course(
      code: 'LAW 301',
      title: 'Law Implementation',
      category: 'Administrative Law',
      institution: 'University of Ghana School of Law',
      image: 'assets/course_card1.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandDark,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.brandWhite,
        onPressed: () {},
        child: const Icon(Icons.add, color: AppColors.brandDark),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Courses',
                    style: TextStyle(
                      color: AppColors.brandWhite,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.brandWhite,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(Icons.menu, color: AppColors.brandDark),
                        ),
                        Positioned(
                          right: 0,
                          top: 8,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: AppColors.brandDanger,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '6',
                              style: TextStyle(
                                color: AppColors.brandWhite,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.search, color: AppColors.mutedText),
                          SizedBox(width: 10),
                          Text(
                            '|Search Courses...',
                            style: TextStyle(
                              color: AppColors.brandDark,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.tune, color: AppColors.brandDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  final course = _courses[index];
                  return Container(
                    margin: EdgeInsets.only(
                      bottom: index == _courses.length - 1 ? 80 : 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandWhite,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: Image.asset(
                            course.image,
                            fit: BoxFit.cover,
                            height: 140,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: AppColors.brandDark,
                                  height: 140,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${course.code} : ${course.title}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.brandDark,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.more_vert,
                                      color: AppColors.brandDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                course.category,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.mutedText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                course.institution,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
