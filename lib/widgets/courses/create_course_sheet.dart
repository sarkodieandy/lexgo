import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class CreateCourseSheet extends StatefulWidget {
  const CreateCourseSheet({super.key});

  @override
  State<CreateCourseSheet> createState() => _CreateCourseSheetState();
}

class _CreateCourseSheetState extends State<CreateCourseSheet> {
  static const _categories = [
    'Criminal Law',
    'Contract Law',
    'Tort Law',
    'Evidence Law',
    'Property Law',
    'Administrative Law',
    'Corporate Law',
    'Family Law',
  ];

  static const _institutions = [
    'University of Ghana, Legon',
    'University of Cape Coast',
    'Kwame Nkrumah University of Science and Technology',
  ];

  final _courseCode = TextEditingController();
  final _courseTitle = TextEditingController();
  final _description = TextEditingController();
  String? _category;
  String? _institution;
  PlatformFile? _selectedImage;

  @override
  void dispose() {
    _courseCode.dispose();
    _courseTitle.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result?.files.isNotEmpty ?? false) {
      setState(() {
        _selectedImage = result!.files.first;
      });
    }
  }

  void _submit() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Course created')));
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.brandWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Create New Course',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: AppColors.brandDark),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Course Image *',
                style: TextStyle(
                  color: AppColors.brandDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: media.width * 0.4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F5FB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFCCCCCC)),
                  ),
                  child: Center(
                    child: _selectedImage == null
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 32,
                                color: AppColors.brandDark,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Click to Upload Image',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 4),
                              Text('PNG or JPEG files up to 10MB'),
                            ],
                          )
                        : Text(
                            _selectedImage!.name,
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _courseCode,
                label: 'Course Code *',
                hint: 'Enter Course Code',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _courseTitle,
                label: 'Course Title *',
                hint: 'Enter Course title',
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Category *',
                value: _category,
                hint: 'Select a category',
                items: _categories,
                onChanged: (value) => setState(() => _category = value),
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Institution *',
                value: _institution,
                hint: 'University of Ghana, Legon',
                items: _institutions,
                onChanged: (value) => setState(() => _institution = value),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _description,
                label: 'Description (Optional)',
                hint: 'Type your Note...',
                minLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: AppColors.brandDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Create Course',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int minLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: minLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF6F5FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F5FB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(hint),
              isExpanded: true,
              items: items
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
