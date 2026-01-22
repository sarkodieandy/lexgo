import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/quiz_item.dart';

class QuizCard extends StatelessWidget {
  const QuizCard({super.key, required this.item});

  final QuizItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.brandWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFEAF8EE),
                child: Icon(Icons.help_outline, color: Colors.green.shade700),
              ),
              const SizedBox(width: 12),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.subtitle,
            style: const TextStyle(color: AppColors.mutedText),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.mutedText),
              const SizedBox(width: 6),
              Text(
                'Due ${item.dueDate.month}/${item.dueDate.day},${item.dueDate.year} • ${item.dueDate.hour.toString().padLeft(2, '0')}:${item.dueDate.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.list_alt_outlined, size: 16, color: AppColors.mutedText),
              const SizedBox(width: 6),
              Text(
                '${item.questions} Questions',
                style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
              ),
              const SizedBox(width: 16),
              Icon(Icons.timer_outlined, size: 16, color: AppColors.mutedText),
              const SizedBox(width: 6),
              Text(
                '${item.duration.inHours}hr ${item.duration.inMinutes % 60}Minutes',
                style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
