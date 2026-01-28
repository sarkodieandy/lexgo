import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  static const _students = [
    'Mike Adjatey',
    'Andrew Kaine',
    'Kofi Mensah',
    'Ama Boateng',
    'Kojo Asante',
    'Yaw Darko',
    'Kwesi Nimo',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        backgroundColor: AppColors.brandDark,
      ),
      backgroundColor: AppColors.brandWhite,
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: _students.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final student = _students[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.brandDark,
                  child: Text(
                    student[0],
                    style: const TextStyle(color: AppColors.brandWhite),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    student,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.brandDark),
              ],
            ),
          );
        },
      ),
    );
  }
}
