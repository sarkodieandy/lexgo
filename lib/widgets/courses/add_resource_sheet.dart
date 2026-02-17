import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/course_resources_provider.dart';
import '../../theme/app_colors.dart';

class AddResourceSheet extends StatefulWidget {
  const AddResourceSheet({super.key});

  @override
  State<AddResourceSheet> createState() => _AddResourceSheetState();
}

class _AddResourceSheetState extends State<AddResourceSheet> {
  PlatformFile? _selectedFile;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  Future<void> _handleAdd() async {
    final filePath = _selectedFile?.path;
    if (filePath == null || filePath.isEmpty) return;

    final provider = context.read<CourseResourcesProvider>();
    try {
      await provider.upload(filePath);
      if (!mounted) return;
      Navigator.of(context).maybePop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Failed to upload resource')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseResourcesProvider>();
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(top: 32),
        decoration: const BoxDecoration(
          color: AppColors.brandWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add resource',
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
                if (_selectedFile != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F1F4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6E2FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.insert_drive_file,
                            color: AppColors.brandDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedFile!.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${(_selectedFile!.size / (1024 * 1024)).toStringAsFixed(1)}MB • ${_selectedFile!.extension?.toUpperCase() ?? 'FILE'}',
                                style: const TextStyle(
                                  color: AppColors.mutedText,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _selectedFile = null),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFBFC4D3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.upload_file, size: 32),
                        SizedBox(height: 8),
                        Text(
                          'Click to Upload or drag and drop',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.brandDark,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'PDF/Docx up to 100MB',
                          style: TextStyle(color: AppColors.mutedText),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: provider.isUploading ? null : _handleAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandDark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    provider.isUploading ? 'Uploading…' : 'Add Resource',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
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
