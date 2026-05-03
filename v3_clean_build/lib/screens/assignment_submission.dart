import 'package:flutter/material.dart';

import '../models/assignment_submission.dart';
import '../models/course_assignment.dart';
import '../models/submission_filters.dart';
import '../screens/submission_detail_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/assignments/assignment_submission_card.dart';
import '../widgets/assignments/filter_sort_sheet.dart';

class GradeAssignmentsScreen extends StatefulWidget {
  const GradeAssignmentsScreen({super.key, required this.assignment});

  final CourseAssignment assignment;

  static const List<AssignmentSubmission> _records = [
    AssignmentSubmission(
      studentName: 'Mike Adjatey',
      studentId: '22189872',
      email: 'mike.adjatey@law.edu',
      fileName: 'Assignment_one_paused.pdf',
      submittedAt: 'Submitted Oct 29, 2025 07:30PM',
      timeTaken: 'Time Taken : 30 minutes',
      score: '--',
      status: SubmissionStatus.pending,
      dueTime: '11:59 PM',
    ),
    AssignmentSubmission(
      studentName: 'Elkanah Wiseman',
      studentId: '22178690',
      email: 'elkanah@lawschool.edu',
      fileName: 'Assignment_one_elkanahWiseman.pdf',
      submittedAt: 'Submitted Oct 29, 2025 07:30PM',
      timeTaken: 'Time Taken : 50 minutes',
      score: '20/20',
      status: SubmissionStatus.graded,
      dueTime: '11:59 PM',
    ),
    AssignmentSubmission(
      studentName: 'Kofi Mensah',
      studentId: '22125693',
      email: 'kofi.m@law.edu',
      fileName: 'Assignment_one_kofiMensah.pdf',
      submittedAt: 'Submitted Oct 29, 2025 07:30PM',
      timeTaken: 'Time Taken : 1 hour 10 minutes',
      score: '19/20',
      status: SubmissionStatus.graded,
      dueTime: '11:59 PM',
    ),
    AssignmentSubmission(
      studentName: 'Ama Boateng',
      studentId: '22130074',
      email: 'ama@law.edu',
      fileName: 'Assignment_one_amaBoateng.pdf',
      submittedAt: 'Submitted Oct 29, 2025 07:30PM',
      timeTaken: 'Time Taken : 1 hour 40 minutes',
      score: '18/20',
      status: SubmissionStatus.graded,
      dueTime: '11:59 PM',
    ),
    AssignmentSubmission(
      studentName: 'Andrew Kaine',
      studentId: '22153103',
      email: 'andrew.kaine@law.edu',
      fileName: 'Assignment_one_andrewKaine.pdf',
      submittedAt: 'Submitted Oct 29, 2025 07:30PM',
      timeTaken: 'Time Taken : 1 hour 50 minutes',
      score: '--',
      status: SubmissionStatus.pending,
      dueTime: '11:59 PM',
    ),
    AssignmentSubmission(
      studentName: 'Yaw Darko',
      studentId: '22174641',
      email: 'y.d@law.edu',
      fileName: 'Assignment_one_yawDarko.pdf',
      submittedAt: 'Submitted Oct 29, 2025 07:30PM',
      timeTaken: 'Time Taken : 1 hour 36 minutes',
      score: '--',
      status: SubmissionStatus.pending,
      dueTime: '11:59 PM',
    ),
    AssignmentSubmission(
      studentName: 'Kojo Asante',
      studentId: '22195055',
      email: 'kojo.asante@law.edu',
      fileName: 'Assignment_one_kojoAsante.pdf',
      submittedAt: 'Submitted Oct 29, 2025 07:30PM',
      timeTaken: 'Time Taken : 1 hour 50 minutes',
      score: '14/20',
      status: SubmissionStatus.graded,
      dueTime: '11:59 PM',
    ),
  ];

  @override
  State<GradeAssignmentsScreen> createState() => _GradeAssignmentsScreenState();
}

class _GradeAssignmentsScreenState extends State<GradeAssignmentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  SubmissionFilter _filter = SubmissionFilter.all;
  SubmissionSort _sortOption = SubmissionSort.alphabetical;

  List<AssignmentSubmission> get _filteredRecords {
    final term = _searchController.text.trim().toLowerCase();
    final filtered = GradeAssignmentsScreen._records.where((record) {
      final matchesStatus =
          _filter == SubmissionFilter.all ||
          (_filter == SubmissionFilter.graded &&
              record.status == SubmissionStatus.graded) ||
          (_filter == SubmissionFilter.pending &&
              record.status == SubmissionStatus.pending);
      if (!matchesStatus) return false;
      if (term.isEmpty) return true;
      final searchable = [
        record.studentName,
        record.email,
        record.fileName,
      ].map((item) => item.toLowerCase());
      return searchable.any((value) => value.contains(term));
    }).toList();
    filtered.sort(_sortRecords);
    return filtered;
  }

  String get _filterLabel {
    switch (_filter) {
      case SubmissionFilter.graded:
        return 'Graded';
      case SubmissionFilter.pending:
        return 'Pending';
      case SubmissionFilter.all:
        return 'All';
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AssignmentFilterSortSheet(
        initialFilter: _filter,
        initialSort: _sortOption,
        onApply: (filter, sort) {
          setState(() {
            _filter = filter;
            _sortOption = sort;
          });
        },
      ),
    );
  }

  int _sortRecords(AssignmentSubmission a, AssignmentSubmission b) {
    switch (_sortOption) {
      case SubmissionSort.alphabetical:
        return a.studentName.compareTo(b.studentName);
    }
  }

  void _openSubmission(AssignmentSubmission submission) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            AssignmentSubmissionDetailScreen(submission: submission),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = GradeAssignmentsScreen._records.length;
    final graded = GradeAssignmentsScreen._records
        .where((element) => element.status == SubmissionStatus.graded)
        .length;
    final pending = total - graded;

    return Scaffold(
      backgroundColor: AppColors.brandDark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B2138),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.brandWhite,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Grade Assignments',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.brandWhite,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 56),
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
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 24,
                    left: 20,
                    right: 20,
                    bottom: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.assignment.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F5FF),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFFFF0F7)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _StatTile(
                                label: 'Total',
                                value: total.toString(),
                                valueColor: AppColors.brandDark,
                                borderColor: const Color(0xFFEAEAEA),
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatTile(
                                label: 'Graded',
                                value: graded.toString(),
                                valueColor: const Color(0xFF008833),
                                borderColor: const Color(0xFFE3F7E5),
                                color: const Color(0xFFF3FFF7),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatTile(
                                label: 'Pending',
                                value: pending.toString(),
                                valueColor: const Color(0xFF9B7500),
                                borderColor: const Color(0xFFFAEBC8),
                                color: const Color(0xFFFFF7E8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F6F8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: AppColors.mutedText,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (_) => setState(() {}),
                                style: const TextStyle(
                                  color: AppColors.brandDark,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '|Search Submissions...',
                                  hintStyle: TextStyle(
                                    color: AppColors.mutedText,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: _showFilterSheet,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppColors.brandDark,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.tune,
                                  color: AppColors.brandWhite,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'All Submissions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Filter: $_filterLabel',
                            style: const TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _filteredRecords.isEmpty
                            ? const Center(
                                child: Text(
                                  'No matching submissions.',
                                  style: TextStyle(color: AppColors.mutedText),
                                ),
                              )
                            : ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                itemCount: _filteredRecords.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) => InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: () =>
                                      _openSubmission(_filteredRecords[index]),
                                  child: AssignmentSubmissionCard(
                                    submission: _filteredRecords[index],
                                  ),
                                ),
                              ),
                      ),
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.borderColor,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color color;
  final Color borderColor;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
