import 'package:flutter/material.dart';

class AssignmentSubmissionScreen extends StatefulWidget {
  final String assignmentTitle;
  final String status;

  const AssignmentSubmissionScreen({
    super.key,
    required this.assignmentTitle,
    required this.status,
  });

  @override
  State<AssignmentSubmissionScreen> createState() =>
      _AssignmentSubmissionScreenState();
}

class _AssignmentSubmissionScreenState
    extends State<AssignmentSubmissionScreen> {
  bool _isSubmittedSuccess = false;

  @override
  Widget build(BuildContext context) {
    if (_isSubmittedSuccess) {
      return _buildSuccessScreen();
    }
    return _buildSubmissionForm();
  }

  Widget _buildSubmissionForm() {
    final bool isSubmitted = widget.status == 'Submitted';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grey background
      appBar: AppBar(
        title: const Text(
          'Assignment Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0F172A),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDetailRow('Title :', widget.assignmentTitle),
              const SizedBox(height: 16),
              _buildDetailRow('Due Date :', 'Jul 30,2025, 09:59PM'),
              const SizedBox(height: 16),
              _buildDetailRow('No. of submissions :', 'Unlimited'),
              const SizedBox(height: 16),
              _buildDetailRow('Grade Scale :', '100 marks'),
              const SizedBox(height: 16),
              _buildDetailRow('Submission Type :', 'file Upload'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   const Text(
                    'Plagiarism Report:',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  isSubmitted ? const Row(
                    children: [
                       Icon(Icons.circle, size: 10, color: Colors.green),
                       SizedBox(width: 4),
                       Text('10%', style: TextStyle(color: Colors.black54, decoration: TextDecoration.underline)),
                    ],
                  ) : const Row(
                    children: [
                       Icon(Icons.access_time, size: 14, color: Colors.black54),
                       SizedBox(width: 4),
                       Text('Pending', style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Detailed Instructions :',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Make sure to answer all questions',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Additional resources for assignment',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: Colors.grey.shade200),
                   boxShadow: [
                     BoxShadow(
                       color: Colors.black.withValues(alpha: 0.02),
                       blurRadius: 5,
                       offset: const Offset(0, 2),
                     ),
                   ],
                 ),
                 child: ListTile(
                  leading: const Icon(Icons.description_outlined, color: Colors.green),
                  title: const Text('Assignment Questions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('5MB • Sept 17, 2025 - 10:00AM', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  onTap: () {},
                ),
              ),
              if (isSubmitted) ...[
                const SizedBox(height: 24),
                const Text(
                  'Submitted Attachments',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildAttachmentCard('Introduction to Criminal Law'),
                const SizedBox(height: 8),
                _buildAttachmentCard('Introduction to Consitutional Law 8'),
              ],
              const SizedBox(height: 24),
              // Mock file dropzone
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                     Positioned.fill(
                       child: DecoratedBox(
                         decoration: BoxDecoration(
                           border: Border.all(color: Colors.grey.shade400, width: 1.5),
                           borderRadius: BorderRadius.circular(12)
                         )
                       ),
                     ),
                     Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.insert_drive_file_outlined, size: 32, color: Colors.grey),
                          const SizedBox(height: 8),
                          const Text(
                            'Click to Upload or drag and drop',
                            style: TextStyle(color: Colors.black87, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'PDF, Docx, XLS, MP4, PNG, JPEG\nup to 100MB',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                          ),
                        ],
                      ),
                     ),
                  ]
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isSubmittedSuccess = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentCard(String filename) {
    return Container(
       decoration: BoxDecoration(
         color: Colors.grey.shade100,
         borderRadius: BorderRadius.circular(12),
       ),
       child: ListTile(
        leading: const Icon(Icons.description_outlined, color: Colors.green),
        title: Text(filename, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: const Text('5MB • Sept 17, 2025 - 10:00AM', style: TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
              )
            ]
          ),
          child: const Icon(Icons.close, color: Colors.red, size: 16)
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
             Center(
               child: Container(
                 width: 120,
                 height: 120,
                 decoration: BoxDecoration(
                   color: Colors.grey.shade100,
                   shape: BoxShape.circle,
                 ),
                 child: Center(
                   child: Container(
                     width: 80,
                     height: 80,
                     decoration: const BoxDecoration(
                       color: Colors.white,
                       shape: BoxShape.circle,
                     ),
                     child: Center(
                       child: Container(
                         width: 50,
                         height: 50,
                         decoration: const BoxDecoration(
                           color: Color(0xFF0F172A),
                           shape: BoxShape.circle,
                         ),
                         child: const Icon(Icons.check, color: Colors.white, size: 30),
                       )
                     )
                   )
                 )
               ),
             ),
            const SizedBox(height: 32),
            const Text(
              'Submission Successful',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your Assignment has been submitted successfully',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 64),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                 const SizedBox(width: 12),
                 const Text('Date', style: TextStyle(color: Colors.grey, fontSize: 14)),
                 const Spacer(),
                 const Text('July 20, 2024', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 const Icon(Icons.insert_drive_file_outlined, size: 18, color: Colors.grey),
                 const SizedBox(width: 12),
                 const Text('Files Uploaded', style: TextStyle(color: Colors.grey, fontSize: 14)),
                 const Spacer(),
                 const Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text('• Introduction to Law', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)),
                     SizedBox(height: 4),
                     Text('• Criminal Law', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)),
                   ],
                 ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
