import 'package:flutter/material.dart';
import '../../models/ai_material.dart';
import '../../theme/app_colors.dart';

class AiMaterialDetailsScreen extends StatelessWidget {
  const AiMaterialDetailsScreen({super.key, required this.material});

  final AiMaterial material;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.brandNavy,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.brandWhite,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      material.topic,
                      style: const TextStyle(
                        color: AppColors.brandWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.auto_awesome, color: Colors.blueAccent, size: 20),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.brandNavy.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'AI GENERATED CONTENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                            color: AppColors.brandNavy,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        material.topic,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brandDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (material.tags.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: material.tags.map((tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          )).toList(),
                        ),
                      const SizedBox(height: 32),
                      Text(
                        material.content,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.7,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
