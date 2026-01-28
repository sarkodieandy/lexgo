import 'package:flutter/material.dart';

import '../models/course.dart';
import '../models/course_assignment.dart';

class CreateNewAssignment extends StatelessWidget {
  const CreateNewAssignment({
    super.key,
    required this.course,
    required this.assignmentNumber,
    this.onCreate,
  });

  final Course course;
  final int assignmentNumber;
  final ValueChanged<CourseAssignment>? onCreate;

  void _handleSubmit(BuildContext context) {
    final assignment = CourseAssignment(
      id: '${course.code}-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Assignment $assignmentNumber : ${course.title}',
      description: 'Created via assignment sheet.',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      dueTime: '11:59 PM',
      points: 10,
      gradeScale: '100 marks',
      submissionType: 'file Upload',
    );
    onCreate?.call(assignment);
    Navigator.of(context).pop();
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Text(
            'Create New Assignment',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF020F20),
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          splashRadius: 20,
          icon: const Icon(Icons.close, color: Color(0xFF020F20)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: text,
            style: const TextStyle(
              color: Color(0xFF6D6565),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const TextSpan(
            text: ' *',
            style: TextStyle(
              color: Color(0xFFFF0000),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String hint, {int maxLines = 1}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        hint,
        style: const TextStyle(color: Color(0xFF6D6565), fontSize: 14),
      ),
    );
  }

  Widget _buildUploadField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F2F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E3EB)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFE6E2FF),
            ),
            child: const Icon(Icons.upload_file, color: Color(0xFF020F20)),
          ),
          const SizedBox(height: 10),
          const Text(
            'Click to Upload or drag and drop',
            style: TextStyle(
              color: Color(0xFF6D6565),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'PDF/Docx up to 100MB',
            style: TextStyle(color: Color(0xFF6D6565)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 520, maxHeight: maxHeight),
            child: Material(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              child: SizedBox(
                height: maxHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 16),
                        _buildLabel('Assignment Title'),
                        const SizedBox(height: 6),
                        _buildField('eg. constitutional Law Essay'),
                        const SizedBox(height: 12),
                        _buildLabel('Detailed Instruction'),
                        const SizedBox(height: 6),
                        _buildField(
                          'Brief overview of the assignment...',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        _buildLabel('Due Date'),
                        const SizedBox(height: 6),
                        _buildField('DD/MM/YY'),
                        const SizedBox(height: 12),
                        _buildLabel('Max Points'),
                        const SizedBox(height: 6),
                        _buildField('eg. 100'),
                        const SizedBox(height: 12),
                        _buildLabel('Submission Type'),
                        const SizedBox(height: 6),
                        _buildField('File Upload'),
                        const SizedBox(height: 16),
                        _buildUploadField(),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _handleSubmit(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF020F20),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Create Assignment',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
