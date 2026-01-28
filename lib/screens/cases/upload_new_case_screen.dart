import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

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
  String? _category;
  String? _pickedFileName;

  @override
  void dispose() {
    _titleController.dispose();
    _sourceController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'docx'],
      withData: false,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _pickedFileName = file.name;
      });
    }
  }

  void _submitCase() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_pickedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a document first')),
      );
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Case uploaded successfully')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
                                onPressed: _submitCase,
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
                                child: const Text(
                                  'Upload Case',
                                  style: TextStyle(
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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonFormField<String>(
            key: ValueKey(_category ?? 'category_selector'),
            initialValue: _category,
            decoration: const InputDecoration(border: InputBorder.none),
            hint: const Text('Administrative Law'),
            isExpanded: true,
            items: categories
                .map(
                  (category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _category = value),
            validator: (value) => (value == null) ? 'Choose a category' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Document',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text('Upload a document containing your questions'),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickDocument,
          child: DottedBorderBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_upload_outlined,
                  size: 36,
                  color: Colors.black54,
                ),
                const SizedBox(height: 8),
                const Text.rich(
                  TextSpan(
                    text: 'Click to upload',
                    children: [
                      TextSpan(text: ' or '),
                      TextSpan(
                        text: 'drag and drop',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'PDF or DOCX files up to 10MB',
                  style: TextStyle(color: AppColors.mutedText),
                ),
                if (_pickedFileName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _pickedFileName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: const BoxDecoration(color: AppColors.brandDark),
      child: Row(
        children: [
          const Text(
            'Upload New Case',
            style: TextStyle(
              color: AppColors.brandWhite,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: AppColors.brandWhite),
          ),
        ],
      ),
    );
  }
}

class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB8C3D7), width: 1.2),
      ),
      child: child,
    );
  }
}
