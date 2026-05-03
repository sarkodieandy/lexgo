import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/course.dart';
import '../../providers/cases_provider.dart';
import '../../providers/courses_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/navigation/app_back_button.dart';

class UploadNewCaseScreen extends StatefulWidget {
  const UploadNewCaseScreen({super.key});

  @override
  State<UploadNewCaseScreen> createState() => _UploadNewCaseScreenState();
}

class _UploadNewCaseScreenState extends State<UploadNewCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _sourceController = TextEditingController();
  final _codeController = TextEditingController();
  final _courseIdController = TextEditingController();
  String? _category;
  Course? _selectedCourse;
  PlatformFile? _selectedFile;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Load courses when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoursesProvider>().loadCourses();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _sourceController.dispose();
    _codeController.dispose();
    _courseIdController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'docx'],
      withData: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _submitCase() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final provider = context.read<CasesProvider>();

    // Use dropdown selection or fallback text field
    final courseId = _selectedCourse?.id ?? _courseIdController.text.trim();
    if (courseId.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please select or enter a course ID')),
      );
      return;
    }
    final file = _selectedFile;
    if (file?.path?.isEmpty ?? true) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please upload a document first')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await provider.createCase(
        courseId: courseId,
        title: _titleController.text.trim(),
        sourceOfCase: _sourceController.text.trim(),
        caseCode: _codeController.text.trim(),
        caseCategory: _category ?? 'General',
        documentPath: file!.path!,
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Case uploaded successfully')),
      );
      navigator.pop();
    } catch (err) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to upload case: ${err.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final coursesProvider = context.watch<CoursesProvider>();
    return Scaffold(
      backgroundColor: AppColors.brandDark,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: AppColors.brandDark)),
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCourseDropdown(coursesProvider),
                            const SizedBox(height: 14),
                            _buildField(
                              'Case Title',
                              'eg. The Republic vs. John Smith',
                              _titleController,
                            ),
                            const SizedBox(height: 14),
                            _buildField(
                              'Source of Case',
                              'eg. Supreme Court of Ghana',
                              _sourceController,
                            ),
                            const SizedBox(height: 14),
                            _buildField(
                              'Case Code',
                              'eg. [YYYY] GHASC 15',
                              _codeController,
                            ),
                            const SizedBox(height: 14),
                            _buildCategoryField(),
                            const SizedBox(height: 24),
                            _buildDocumentUpload(),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _submitCase,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.brandWhite,
                                  side: const BorderSide(
                                    color: AppColors.brandDark,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  _isSubmitting ? 'Uploading…' : 'Upload Case',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.brandDark,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseDropdown(CoursesProvider coursesProvider) {
    final courses = coursesProvider.courses;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Course',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        if (coursesProvider.isLoading)
          const Center(child: Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(strokeWidth: 2),
          ))
        else if (courses.isNotEmpty)
          DropdownButtonFormField<String>(
            value: _selectedCourse?.id,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            hint: const Text('Select a course'),
            items: courses.map((course) {
              return DropdownMenuItem(
                value: course.id,
                child: Text('${course.title} (${course.code})'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCourse = courses.firstWhere((c) => c.id == value);
              });
            },
            validator: (value) =>
                value == null ? 'Please select a course' : null,
          )
        else
          // Fallback: text field for course ID when API fetch fails
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (coursesProvider.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: AppColors.mutedText),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Could not load courses. Enter the Course ID manually.',
                          style: TextStyle(color: AppColors.mutedText, fontSize: 12),
                        ),
                      ),
                      TextButton(
                        onPressed: () => coursesProvider.loadCourses(),
                        child: const Text('Retry', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              TextFormField(
                controller: _courseIdController,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Paste your Course ID here',
                  hintStyle: TextStyle(color: AppColors.mutedText),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                ),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Please enter the course ID' : null,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildField(
    String label,
    String placeholder,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: AppColors.mutedText),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
          ),
          validator: (value) =>
              (value?.isEmpty ?? true) ? 'Please fill this field' : null,
        ),
      ],
    );
  }

  Widget _buildCategoryField() {
    const categories = [
      'Administrative Law',
      'Constitutional Law',
      'Contract Law',
      'Criminal Law',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Case Category',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _category,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          hint: const Text('Select category'),
          items: categories
              .map(
                (category) =>
                    DropdownMenuItem(value: category, child: Text(category)),
              )
              .toList(),
          onChanged: (value) => setState(() => _category = value),
        ),
      ],
    );
  }

  Widget _buildDocumentUpload() {
    return GestureDetector(
      onTap: _pickDocument,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBFC4D3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.upload_file, size: 32),
            const SizedBox(height: 8),
            Text(
              _selectedFile?.name ?? 'Click to Upload or drag and drop',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.brandDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'PDF/Docx up to 100MB',
              style: TextStyle(color: AppColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      color: AppColors.brandDark,
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 16),
          const Text(
            'Upload Case',
            style: TextStyle(
              color: AppColors.brandWhite,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
