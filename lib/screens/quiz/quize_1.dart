import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/quiz/submission_record.dart';
import '../../models/quiz/quiz_question.dart';
import '../../providers/courses_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/quiz/analysis/analysis_tab.dart';
import '../../widgets/quiz/submissions/submissions_tab.dart';
import 'review_quiz_screen.dart';

class Quiz1 extends StatefulWidget {
  const Quiz1({super.key, this.title = 'Quiz one'});

  final String title;

  @override
  State<Quiz1> createState() => _Quiz1State();
}

class _Quiz1State extends State<Quiz1> with SingleTickerProviderStateMixin {
  final List<String> tabs = [
    'Questions',
    'Settings',
    'Submissions',
    'Analysis',
  ];
  final List<String> setupOptions = ['Manual Creation', 'Upload Document'];
  String? selectedCourseId;
  final List<String> attemptOptions = ['1', '2', '3', '4', '5', 'Unlimited'];
  final List<QuestionEntry> questionEntries = const [
    QuestionEntry(
      title: 'Question 1',
      text: 'Which type of crime typically does NOT require a mens rea?',
      questionType: 'Multiple Choice',
      points: '1 point',
      options: [
        QuestionOption(text: 'Robbery', isCorrect: true),
        QuestionOption(text: 'Murder'),
        QuestionOption(text: 'Strict liability offenses'),
        QuestionOption(text: 'Assault'),
      ],
    ),
    QuestionEntry(
      title: 'Question 2',
      text:
          'Who is widely considered the proponent of the doctrine of the separation of powers?',
      questionType: 'Multiple Choice',
      points: '1 point',
      options: [
        QuestionOption(text: 'Lord Listowel', isCorrect: true),
        QuestionOption(text: 'Sir Baldwin'),
        QuestionOption(text: 'Montesquieu'),
        QuestionOption(text: 'Sir Ako Korsah'),
      ],
    ),
  ];

  final List<SubmissionRecord> submissions = [
    SubmissionRecord(
      name: 'Mike Adjatey',
      id: '22189872',
      score: 18,
      total: 20,
      correctAnswers: 18,
      submittedAt: 'Oct 29, 2025 07:30PM',
      duration: '30 minutes',
      avatarColor: Color(0xFFE53935),
      category: 'Criminal Law',
      submittedAtDate: DateTime(2025, 10, 29, 19, 30),
    ),
    SubmissionRecord(
      name: 'Andrew Kaine',
      id: '22153103',
      score: 18,
      total: 20,
      correctAnswers: 18,
      submittedAt: 'Oct 29, 2025 07:30PM',
      duration: '1 hour 50 minutes',
      avatarColor: Color(0xFF673AB7),
      category: 'Contract Law',
      submittedAtDate: DateTime(2025, 10, 29, 19, 30),
    ),
    SubmissionRecord(
      name: 'Kofi',
      id: '22125693',
      score: 14,
      total: 20,
      correctAnswers: 14,
      submittedAt: 'Oct 29, 2025 07:30PM',
      duration: '1 hour 50 minutes',
      avatarColor: Color(0xFF3F51B5),
      category: 'Administrative Law',
      submittedAtDate: DateTime(2025, 10, 29, 19, 30),
    ),
    SubmissionRecord(
      name: 'Kojo',
      id: '22195055',
      score: 14,
      total: 20,
      correctAnswers: 18,
      submittedAt: 'Oct 29, 2025 07:30PM',
      duration: '1 hour 50 minutes',
      avatarColor: Color(0xFF9C27B0),
      category: 'Constitutional Law',
      submittedAtDate: DateTime(2025, 10, 29, 19, 30),
    ),
    SubmissionRecord(
      name: 'Yaw',
      id: '22174641',
      score: 12,
      total: 20,
      correctAnswers: 12,
      submittedAt: 'Oct 29, 2025 07:30PM',
      duration: '1 hour 50 minutes',
      avatarColor: Color(0xFFFF9800),
      category: 'Property Law',
      submittedAtDate: DateTime(2025, 10, 29, 19, 30),
    ),
    SubmissionRecord(
      name: 'Ama',
      id: '22130074',
      score: 12,
      total: 20,
      correctAnswers: 12,
      submittedAt: 'Oct 29, 2025 07:30PM',
      duration: '1 hour 50 minutes',
      avatarColor: Color(0xFF9C27B0),
      category: 'Family Law',
      submittedAtDate: DateTime(2025, 10, 29, 19, 30),
    ),
    SubmissionRecord(
      name: 'Kwesi',
      id: '22191057',
      score: 10,
      total: 20,
      correctAnswers: 10,
      submittedAt: 'Oct 29, 2025 07:30PM',
      duration: '1 hour 50 minutes',
      avatarColor: Color(0xFF3F51B5),
      category: 'Corporate Law',
      submittedAtDate: DateTime(2025, 10, 29, 19, 30),
    ),
  ];
  final List<ManualQuestion> manualQuestions = [];

  int activeTab = 0;
  String selectedSetup = 'Upload Document';
  String selectedCourse = 'LAW001 : Introduction to law';
  String selectedAttempts = '1';
  bool shuffleQuestions = true;
  bool shuffleAnswers = false;
  bool showScoresImmediately = true;

  final TextEditingController _quizTitleController = TextEditingController(
    text: 'Create quiz',
  );
  final TextEditingController _instructionController = TextEditingController(
    text: 'Brief description of what the quiz covers...',
  );
  int durationMinutesLabel = 45;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 12, minute: 0);
  PlatformFile? selectedDocument;
  DateTime? documentUploadTime;
  bool _isGenerating = false;
  bool _hasGenerated = false;
  final bool _isCreatingQuiz = true;
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnimation;

  bool get _isManualMode => selectedSetup == 'Manual Creation';

  String get durationLabel => '$durationMinutesLabel minutes';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoursesProvider>().loadCourses();
    });
    manualQuestions.addAll([
      ManualQuestion(
        id: 1,
        initialText:
            'Which type of crime typically does NOT require a mens rea?',
        questionType: 'Multiple Choice',
        options: [
          ManualOption(text: 'Robbery', isCorrect: true),
          ManualOption(text: 'Murder'),
          ManualOption(text: 'Strict liability offenses'),
          ManualOption(text: 'Assault'),
        ],
      ),
      ManualQuestion(
        id: 2,
        initialText:
            'Who is widely considered the proponent of the doctrine of the separation of powers?',
        questionType: 'Multiple Choice',
        options: [
          ManualOption(text: 'Lord Listowel', isCorrect: true),
          ManualOption(text: 'Sir Baldwin'),
          ManualOption(text: 'Montesquieu'),
          ManualOption(text: 'Sir Ako Korsah'),
        ],
      ),
    ]);
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(_shimmerController);
  }

  @override
  void dispose() {
    _quizTitleController.dispose();
    _instructionController.dispose();
    _shimmerController.dispose();
    for (var question in manualQuestions) {
      question.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandDark,
      floatingActionButton: activeTab == 0
          ? FloatingActionButton(
              onPressed: _isManualMode ? _addManualQuestion : null,
              backgroundColor: _isManualMode
                  ? AppColors.brandDark
                  : AppColors.brandDark.withAlpha(77),
              child: const Icon(Icons.add, color: AppColors.brandWhite),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                _buildTabBar(),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                      child: _buildTabContent(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isGenerating) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      color: AppColors.brandDark,
      child: Row(
        children: [
          Material(
            color: AppColors.brandDark,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 44,
                height: 44,
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
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _isCreatingQuiz ? 'Create Quiz' : widget.title,
              style: const TextStyle(
                color: AppColors.brandWhite,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: _publishQuiz,
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: AppColors.brandWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.send, color: AppColors.brandDark),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'unpublish') _showUnpublishDialog();
            },
            color: AppColors.brandWhite,
            itemBuilder: (_) => [
              const PopupMenuItem<String>(
                value: 'unpublish',
                child: Text('Unpublish Quiz'),
              ),
            ],
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.brandNavy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.more_vert, color: AppColors.brandWhite),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.brandDark,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final selected = index == activeTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => activeTab = index),
              child: Column(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected
                            ? AppColors.brandWhite
                            : const Color(0x99FFFFFF),
                        fontSize: 16,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 3,
                    width: selected ? 48 : 28,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.brandWhite
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    if (activeTab == 0) return _buildQuestionsTab();
    if (activeTab == 1) return _buildSettingsContent();
    if (activeTab == 2) {
      return SubmissionsTab(submissions: submissions);
    }
    return const AnalysisTab();
  }

  Widget _buildQuestionsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestionSetupCard(),
        const SizedBox(height: 16),
        if (_isManualMode) ...[
          _buildManualQuestionsSection(),
        ] else ...[
          _buildUploadDocumentCard(),
          const SizedBox(height: 20),
          ...questionEntries.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildQuestionCard(entry.value, entry.key + 1),
            ),
          ),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSettingsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Quiz Info',
          children: [
            _buildTextField(
              label: 'Quiz Title',
              hint: 'eg. Criminal Law',
              controller: _quizTitleController,
              required: true,
            ),
            const SizedBox(height: 12),
            _buildCourseDropdown(),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Description / Instruction',
              hint: 'Brief description of what the quiz covers...',
              controller: _instructionController,
              minLines: 3,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSectionCard(
          title: 'Time Settings',
          subtitle: 'Configure quiz duration and availability',
          children: [
            _buildPickerField(
              label: 'Quiz Duration',
              hint: durationLabel,
              onTap: _showDurationDialog,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateTimeTile(
                    label: 'Start Date',
                    hint: _formatDate(startDate),
                    icon: Icons.calendar_today_outlined,
                    onTap: () => _pickDate(isStart: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateTimeTile(
                    label: 'Start Time',
                    hint: _formatTime(startTime),
                    icon: Icons.access_time,
                    onTap: () => _pickTime(isStart: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateTimeTile(
                    label: 'End Date',
                    hint: _formatDate(endDate),
                    icon: Icons.calendar_today_outlined,
                    onTap: () => _pickDate(isStart: false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateTimeTile(
                    label: 'End Time',
                    hint: _formatTime(endTime),
                    icon: Icons.access_time,
                    onTap: () => _pickTime(isStart: false),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSectionCard(
          title: 'Attempt & Access',
          subtitle: 'Control how students can take the quiz',
          children: [
            _buildDropdownField(
              label: 'Maximum Attempts',
              value: selectedAttempts,
              items: attemptOptions,
              onChanged: (value) => setState(() {
                selectedAttempts = value;
              }),
            ),
            const SizedBox(height: 12),
            _buildToggleRow(
              label: 'Shuffle Questions',
              value: shuffleQuestions,
              onChanged: (value) => setState(() {
                shuffleQuestions = value;
              }),
            ),
            const SizedBox(height: 12),
            _buildToggleRow(
              label: 'Shuffle Answers',
              value: shuffleAnswers,
              onChanged: (value) => setState(() {
                shuffleAnswers = value;
              }),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSectionCard(
          title: 'Grading Settings',
          subtitle: 'Configure how the quiz is graded',
          children: [
            _buildToggleRow(
              label: 'Show Scores Immediately',
              value: showScoresImmediately,
              onChanged: (value) => setState(() {
                showScoresImmediately = value;
              }),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Mark Per Question',
              hint: '20',
              inputType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Total Grade',
              hint: 'eg. 100',
              inputType: TextInputType.number,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildUnpublishCard(),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    List<Widget>? children,
    String? subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.brandWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppColors.mutedText)),
          ],
          if (children != null && children.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...children,
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionSetupCard() {
    return _buildSectionCard(
      title: 'Question Setup',
      subtitle: 'Choose your preferred method to create a quiz',
      children: [
        _buildDropdownField(
          label: 'Quiz Setup',
          value: selectedSetup,
          items: setupOptions,
          onChanged: _handleSetupChange,
        ),
      ],
    );
  }

  Widget _buildUploadDocumentCard() {
    final hasDocument = selectedDocument != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.brandWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Document',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Upload a document containing your questions',
            style: TextStyle(color: AppColors.mutedText),
          ),
          const SizedBox(height: 16),
          hasDocument ? _buildDocumentPreview() : _buildDocumentPlaceholder(),
          if (hasDocument) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _startGeneration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _hasGenerated ? 'Regenerate Questions' : 'Generate Questions',
                  style: const TextStyle(
                    color: AppColors.brandWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildManualQuestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: manualQuestions
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildManualQuestionCard(entry.value, entry.key + 1),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDocumentPlaceholder() {
    return GestureDetector(
      onTap: _pickDocument,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.brandDark.withAlpha(102),
            width: 1.5,
          ),
        ),
        child: Column(
          children: const [
            Icon(Icons.upload_file, size: 32, color: AppColors.brandDark),
            SizedBox(height: 8),
            Text('Click to upload or drag and drop'),
            SizedBox(height: 4),
            Text(
              'PDF or DOCX files up to 10MB',
              style: TextStyle(color: AppColors.mutedText, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentPreview() {
    final file = selectedDocument!;
    final uploadedAt = documentUploadTime ?? DateTime.now();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.description, color: Colors.green, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatFileSize(file.size)} • ${_formatDate(uploadedAt)} • ${_formatTime(TimeOfDay.fromDateTime(uploadedAt))}',
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() {
              selectedDocument = null;
              documentUploadTime = null;
              _hasGenerated = false;
            }),
            icon: const Icon(
              Icons.close,
              size: 18,
              color: AppColors.brandDanger,
            ),
          ),
        ],
      ),
    );
  }

  void _startGeneration() async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() {
      _isGenerating = false;
      _hasGenerated = true;
    });
  }

  void _showUnpublishDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unpublish Quiz'),
        content: const Text('Are you sure you want to unpublish this quiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandDark,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Quiz unpublished')));
            },
            child: const Text('Unpublish'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withAlpha(128),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  final value = _shimmerAnimation.value;
                  return Container(
                    width: 280,
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment(value - 1, 0),
                        end: Alignment(value, 0),
                        colors: const [
                          Colors.white24,
                          Colors.white70,
                          Colors.white24,
                        ],
                      ),
                    ),
                    child: const Text(
                      'Please wait while we set up your questions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              const Text(
                'Everything is being configured just for you.',
                style: TextStyle(color: AppColors.brandWhite),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: AppColors.brandWhite),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualQuestionCard(ManualQuestion question, int index) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.brandWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question $index',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Question Text',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: question.textController,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF6F5FB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Question Choices',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildManualQuestionTypeDropdown(question),
          const SizedBox(height: 14),
          const Text(
            'Select the correct answer(s)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Column(
            children: question.options
                .asMap()
                .entries
                .map((entry) => _buildManualOptionRow(question, entry.key))
                .toList(),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () {
              setState(() {
                question.addOption();
              });
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.brandDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add, color: AppColors.brandDark),
                SizedBox(width: 8),
                Text('Add another Option'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualQuestionTypeDropdown(ManualQuestion question) {
    const options = ['Multiple Choice', 'Manual Entry'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F0F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: question.questionType,
          items: options
              .map(
                (choice) =>
                    DropdownMenuItem(value: choice, child: Text(choice)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => question.questionType = value);
            }
          },
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.mutedText,
          ),
        ),
      ),
    );
  }

  Widget _buildManualOptionRow(ManualQuestion question, int optionIndex) {
    final option = question.options[optionIndex];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F5FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => option.isCorrect = !option.isCorrect),
            child: Icon(
              option.isCorrect
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: option.isCorrect
                  ? AppColors.brandDark
                  : AppColors.mutedText,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: option.controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Option text',
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              if (question.options.length <= 1) return;
              setState(() => question.options.removeAt(optionIndex).dispose());
            },
            icon: const Icon(Icons.close, size: 20),
          ),
        ],
      ),
    );
  }

  void _addManualQuestion() {
    final newIndex = manualQuestions.length + 1;
    setState(() {
      manualQuestions.add(
        ManualQuestion(
          id: newIndex,
          initialText: '',
          questionType: 'Multiple Choice',
          options: [
            ManualOption(text: 'Option 1', isCorrect: true),
            ManualOption(text: 'Option 2'),
          ],
        ),
      );
    });
  }

  void _handleSetupChange(String value) {
    setState(() {
      selectedSetup = value;
      if (value != 'Upload Document') {
        selectedDocument = null;
        documentUploadTime = null;
        _hasGenerated = false;
      }
    });
    if (value == 'Upload Document') {
      _pickDocument();
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: false,
    );
    if (result?.files.isNotEmpty ?? false) {
      final picked = result!.files.first;
      const maxBytes = 10 * 1024 * 1024;
      if (picked.size > maxBytes) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected file exceeds 10MB limit')),
        );
        return;
      }
      setState(() {
        selectedDocument = picked;
        documentUploadTime = DateTime.now();
        _hasGenerated = false;
      });
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  Widget _buildQuestionCard(QuestionEntry question, int index) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.brandWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            question.points,
            style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
          ),
          const SizedBox(height: 10),
          const Text(
            'Question Text',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F5FB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              question.text,
              style: const TextStyle(color: AppColors.brandDark),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Question Choices',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildQuestionTypeDropdown(question.questionType),
          const SizedBox(height: 14),
          const Text(
            'Select the correct answer(s)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Column(
            children: question.options
                .map((option) => _buildAnswerOption(option))
                .toList(),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.brandDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add, color: AppColors.brandDark),
                SizedBox(width: 8),
                Text('Add another Option'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionTypeDropdown(String value) {
    const questionChoiceOptions = ['Multiple Choice', 'Manual Entry'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F0F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: questionChoiceOptions
              .map(
                (choice) =>
                    DropdownMenuItem(value: choice, child: Text(choice)),
              )
              .toList(),
          onChanged: (_) {},
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.mutedText,
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOption(QuestionOption option) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F5FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            option.isCorrect
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: option.isCorrect ? AppColors.brandDark : AppColors.mutedText,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(option.text, style: const TextStyle(fontSize: 14)),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.close, size: 20)),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    TextEditingController? controller,
    TextInputType inputType = TextInputType.text,
    int minLines = 1,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (required)
              const Text(' *', style: TextStyle(color: AppColors.brandDanger)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          minLines: minLines,
          maxLines: minLines > 1 ? minLines : 1,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF2F0F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          dropdownColor: AppColors.brandWhite,
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF2F0F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPickerField({
    required String label,
    required String hint,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F0F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hint,
                    style: const TextStyle(color: AppColors.mutedText),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_right,
                  color: AppColors.mutedText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeTile({
    required String label,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F0F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.mutedText),
                const SizedBox(width: 8),
                Text(hint, style: const TextStyle(color: AppColors.mutedText)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = (date.year % 100).toString().padLeft(2, '0');
    return '$day/$month/$year';
  }

  String _formatTime(TimeOfDay time) {
    final displayHour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${displayHour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? startDate : endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.brandDark,
              onPrimary: AppColors.brandWhite,
              surface: AppColors.brandWhite,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.brandDark),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          if (picked.isAfter(endDate)) {
            endDate = picked;
          }
        } else {
          endDate = picked;
          if (picked.isBefore(startDate)) {
            startDate = picked;
          }
        }
      });
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart ? startTime : endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppColors.brandWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  Widget _buildToggleRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F0F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.brandBlue,
            activeTrackColor: AppColors.brandBlue.withAlpha(120),
          ),
        ],
      ),
    );
  }

  Widget _buildUnpublishCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.brandWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF2F0F5)),
      ),
      child: Row(
        children: const [
          Icon(Icons.logout, color: AppColors.brandDanger),
          SizedBox(width: 16),
          Text(
            'Unpublish Quiz',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showDurationDialog() {
    showDialog(
      context: context,
      builder: (_) => _SelectDurationDialog(
        initialHours: durationHours,
        initialMinutes: durationMinutes,
        onConfirmed: (hours, minutes) {
          setState(() {
            durationHours = hours;
            durationMinutes = minutes;
          });
        },
      ),
    );
  }
}

class QuestionEntry {
  const QuestionEntry({
    required this.title,
    required this.text,
    required this.questionType,
    required this.options,
    this.points = '1 point',
  });

  final String title;
  final String text;
  final String questionType;
  final List<QuestionOption> options;
  final String points;
}

class QuestionOption {
  const QuestionOption({required this.text, this.isCorrect = false});

  final String text;
  final bool isCorrect;
}

class ManualQuestion {
  ManualQuestion({
    required this.id,
    required this.initialText,
    required this.options,
    this.questionType = 'Multiple Choice',
  }) : textController = TextEditingController(text: initialText);

  final int id;
  final String initialText;
  final TextEditingController textController;
  String questionType;
  final List<ManualOption> options;

  void addOption({String text = ''}) {
    options.add(ManualOption(text: text));
  }

  void dispose() {
    textController.dispose();
    for (var option in options) {
      option.dispose();
    }
  }
}

class ManualOption {
  ManualOption({required String text, this.isCorrect = false})
    : controller = TextEditingController(text: text);

  final TextEditingController controller;
  bool isCorrect;

  void dispose() => controller.dispose();
}

class _SelectDurationDialog extends StatefulWidget {
  const _SelectDurationDialog({
    required this.initialHours,
    required this.initialMinutes,
    required this.onConfirmed,
  });

  final int initialHours;
  final int initialMinutes;
  final void Function(int hours, int minutes) onConfirmed;

  @override
  State<_SelectDurationDialog> createState() => _SelectDurationDialogState();
}

class _SelectDurationDialogState extends State<_SelectDurationDialog> {
  late int hours;
  late int minutes;
  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;

  @override
  void initState() {
    super.initState();
    hours = widget.initialHours;
    minutes = widget.initialMinutes;
    hourController = FixedExtentScrollController(initialItem: hours);
    minuteController = FixedExtentScrollController(initialItem: minutes);
  }

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.brandWhite,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Duration',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Hours',
                          style: TextStyle(color: AppColors.mutedText),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: hourController,
                            itemExtent: 36,
                            onSelectedItemChanged: (value) =>
                                setState(() => hours = value),
                            children: List.generate(
                              24,
                              (index) => Center(
                                child: Text(index.toString().padLeft(2, '0')),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Minutes',
                          style: TextStyle(color: AppColors.mutedText),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: minuteController,
                            itemExtent: 36,
                            onSelectedItemChanged: (value) =>
                                setState(() => minutes = value),
                            children: List.generate(
                              60,
                              (index) => Center(
                                child: Text(index.toString().padLeft(2, '0')),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.brandDark,
                      side: const BorderSide(color: AppColors.brandDark),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onConfirmed(hours, minutes);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('OK'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseDropdown() {
    final coursesProvider = context.watch<CoursesProvider>();
    final courses = coursesProvider.courses;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Course *',
          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.brandDark),
        ),
        const SizedBox(height: 6),
        if (coursesProvider.isLoading)
          const LinearProgressIndicator()
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCourseId,
                isExpanded: true,
                hint: const Text('Select a course'),
                items: courses.map((course) {
                  return DropdownMenuItem(
                    value: course.id,
                    child: Text('${course.code}: ${course.title}'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedCourseId = value),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _publishQuiz() async {
    if (selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a course')),
      );
      return;
    }

    final title = _quizTitleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a quiz title')),
      );
      return;
    }

    setState(() => _isGenerating = true); 
    try {
      final quizProvider = context.read<QuizProvider>();
      final startTimeDateTime = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        startTime.hour,
        startTime.minute,
      );
      final endTimeDateTime = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        endTime.hour,
        endTime.minute,
      );

      final attempts = selectedAttempts == 'Unlimited' ? -1 : int.tryParse(selectedAttempts) ?? 1;

      if (_isManualMode) {
        final payloadQuestions = manualQuestions.map((q) => {
          'question': q.textController.text.trim(),
          'options': q.options.map((o) => o.textController.text.trim()).toList(),
          'correctAnswer': q.options.firstWhere((o) => o.isCorrect).textController.text.trim(),
          'explanation': '',
          'mark': 1,
        }).toList();

        await quizProvider.createManualQuiz(
          courseId: selectedCourseId!,
          title: title,
          description: _instructionController.text.trim(),
          quizDurationMinutes: durationMinutesLabel,
          quizStartTime: startTimeDateTime,
          quizEndTime: endTimeDateTime,
          attempts: attempts,
          shuffleQuestions: shuffleQuestions,
          shuffleAnswers: shuffleAnswers,
          showScoresImmediately: showScoresImmediately,
          questions: payloadQuestions,
        );
      } else {
        if (selectedDocument == null) {
          throw Exception('Please upload a document first');
        }
        await quizProvider.createAutoQuiz(
          courseId: selectedCourseId!,
          title: title,
          description: _instructionController.text.trim(),
          documentPath: selectedDocument!.path!,
          quizDurationMinutes: durationMinutesLabel,
          quizStartTime: startTimeDateTime,
          quizEndTime: endTimeDateTime,
          attempts: attempts,
          shuffleQuestions: shuffleQuestions,
          shuffleAnswers: shuffleAnswers,
          showScoresImmediately: showScoresImmediately,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz published successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish quiz: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (bytes.toString().length - 1) ~/ 3;
    var value = bytes / (1 << (i * 10));
    return '${value.toStringAsFixed(1)} ${suffixes[i]}';
  }
}
