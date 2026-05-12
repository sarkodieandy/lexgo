import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AddTopicSheet extends StatelessWidget {
  const AddTopicSheet({super.key});

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.brandDark,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.mutedText),
      filled: true,
      fillColor: const Color(0xFFF9F5FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(top: 32),
        decoration: const BoxDecoration(
          color: AppColors.brandWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 6,
                  width: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7E5EA),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add New Topic',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _label('Topic Title *'),
                const SizedBox(height: 6),
                TextField(
                  style: const TextStyle(color: AppColors.brandDark),
                  maxLines: 1,
                  decoration: _inputDecoration('eg.constitutional Law Essay'),
                ),
                const SizedBox(height: 16),
                _label('Description *'),
                const SizedBox(height: 6),
                TextField(
                  style: const TextStyle(color: AppColors.brandDark),
                  maxLines: 4,
                  decoration: _inputDecoration('Brief topic overview'),
                ),
                const SizedBox(height: 20),
                _label('Upload Document'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F0F6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD8D2E2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.upload_file,
                        size: 32,
                        color: AppColors.mutedText,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Click to Upload or drag and drop',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandDark,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'PDF/Docx up to 100MB',
                        style: TextStyle(color: AppColors.mutedText),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandDark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Add Topic',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandWhite,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
