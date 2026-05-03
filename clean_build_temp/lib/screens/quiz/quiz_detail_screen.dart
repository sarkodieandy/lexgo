import 'package:flutter/material.dart';

import '../../models/quiz/quiz_model.dart';
import '../../models/quiz/quiz_analysis.dart';
import '../../models/quiz/submission_record.dart';
import '../../models/quiz_item.dart';
import '../../providers/quiz_provider.dart';
import '../../theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class QuizDetailScreen extends StatelessWidget {
  const QuizDetailScreen({super.key, required this.quiz});

  final QuizItem quiz;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.brandDark,
        body: SafeArea(
          child: Column(
            children: [
              _Header(
                title: quiz.title,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Container(
                color: AppColors.brandDark,
                child: TabBar(
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(
                      color: AppColors.brandWhite,
                      width: 2,
                    ),
                    insets: EdgeInsets.symmetric(horizontal: 20),
                  ),
                  labelColor: AppColors.brandWhite,
                  unselectedLabelColor: Colors.white70,
                  tabs: const [
                    Tab(text: 'Questions'),
                    Tab(text: 'Settings'),
                    Tab(text: 'Submissions'),
                    Tab(text: 'Analysis'),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: TabBarView(
                    children: [
                      const SizedBox.expand(
                        child: Center(child: Text('Questions tab content')),
                      ),
                      const _QuizSettingsTab(),
                      _SubmissionsTab(quizId: quiz.id),
                      _AnalysisTab(quizId: quiz.id),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
      color: AppColors.brandDark,
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.brandWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.arrow_back_ios, color: AppColors.brandDark),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.brandWhite,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.brandWhite),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _QuizSettingsTab extends StatelessWidget {
  const _QuizSettingsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SectionCard(
            title: 'Quiz Info',
            description: 'Provide core information of the quiz',
            fields: [
              FieldSpec(
                label: 'Quiz Title',
                placeholder: 'eg. Criminal Law',
                required: true,
              ),
              FieldSpec(
                label: 'Course',
                placeholder: 'Introduction to law',
                dropdown: true,
              ),
              FieldSpec(
                label: 'Description/Instruction',
                placeholder: 'Brief description of what the quiz covers...',
              ),
            ],
          ),
          SizedBox(height: 18),
          SectionCard(
            title: 'Time Settings',
            description: 'Configure quiz duration and availability',
            fields: [
              FieldSpec(
                label: 'Quiz Duration',
                placeholder: 'eg. 30mins',
                icon: Icons.schedule,
              ),
              FieldSpec(
                label: 'Start Date',
                placeholder: 'DD/MM/YY',
                icon: Icons.calendar_today,
              ),
              FieldSpec(
                label: 'Start Time',
                placeholder: 'HH:MM',
                icon: Icons.schedule,
              ),
              FieldSpec(
                label: 'End Date',
                placeholder: 'DD/MM/YY',
                icon: Icons.calendar_today,
              ),
              FieldSpec(
                label: 'End Time',
                placeholder: 'HH:MM',
                icon: Icons.schedule,
              ),
            ],
          ),
          SizedBox(height: 18),
          SectionCard(
            title: 'Attempt & Access',
            description: 'Control how students can take the quiz',
            toggles: [
              ToggleSpec(label: 'Shuffle Questions'),
              ToggleSpec(label: 'Shuffle Answers'),
            ],
            dropdownFields: [
              FieldSpec(
                label: 'Maximum Attempts',
                placeholder: '1',
                dropdown: true,
              ),
            ],
          ),
          SizedBox(height: 18),
          SectionCard(
            title: 'Grading Settings',
            description: 'Configure how the quiz is graded',
            toggles: [ToggleSpec(label: 'Show Scores Immediately')],
            fields: [
              FieldSpec(label: 'Mark Per Question', placeholder: '20'),
              FieldSpec(label: 'Total Grade', placeholder: 'eg. 100'),
            ],
          ),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.description,
    this.fields = const [],
    this.dropdownFields = const [],
    this.toggles = const [],
  });

  final String title;
  final String description;
  final List<FieldSpec> fields;
  final List<FieldSpec> dropdownFields;
  final List<ToggleSpec> toggles;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.brandWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
          ),
          const SizedBox(height: 14),
          ...fields.map(
            (field) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildField(field),
            ),
          ),
          ...dropdownFields.map(
            (field) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildDropdown(field),
            ),
          ),
          ...toggles.map(
            (toggle) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildToggle(toggle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(FieldSpec spec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(spec.label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: spec.placeholder,
            filled: true,
            fillColor: const Color(0xFFF8F9FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            suffixIcon: spec.icon != null ? Icon(spec.icon) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(FieldSpec spec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(spec.label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  spec.placeholder,
                  style: const TextStyle(color: AppColors.mutedText),
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggle(ToggleSpec toggle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              toggle.label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              'Present questions in random order for each student',
              style: TextStyle(color: AppColors.mutedText, fontSize: 12),
            ),
          ],
        ),
        Switch(value: true, onChanged: (_) {}),
      ],
    );
  }
}

class FieldSpec {
  final String label;
  final String placeholder;
  final IconData? icon;
  final bool required;
  final bool dropdown;

  const FieldSpec({
    required this.label,
    required this.placeholder,
    this.icon,
    this.required = false,
    this.dropdown = false,
  });
}

class ToggleSpec {
  final String label;

  const ToggleSpec({required this.label});
}

class _SubmissionsTab extends StatefulWidget {
  const _SubmissionsTab({required this.quizId});
  final String quizId;

  @override
  State<_SubmissionsTab> createState() => _SubmissionsTabState();
}

class _SubmissionsTabState extends State<_SubmissionsTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().loadSubmissions(widget.quizId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, provider, _) {
        final query = _searchController.text.toLowerCase();
        final filteredSubmissions = provider.submissions.where((sub) {
          return sub.name.toLowerCase().contains(query) ||
              sub.id.toLowerCase().contains(query);
        }).toList();

        return Column(
          children: [
            const SizedBox(height: 24),
            // Search & Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(0xFF98A2B3),
                            size: 22,
                          ),
                          hintText: 'Search Students...',
                          hintStyle: TextStyle(
                            color: Color(0xFF98A2B3),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D253F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () =>
                          provider.loadSubmissions(widget.quizId),
                      child: filteredSubmissions.isEmpty
                          ? const Center(child: Text('No submissions found'))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              itemCount: filteredSubmissions.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return _SubmissionCard(submission: filteredSubmissions[index]);
                              },
                            ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({required this.submission});
  final SubmissionRecord submission;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
    final submittedAtDate = submission.submittedAtDate;
    final submittedAt = dateFormat.format(submittedAtDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: submission.avatarColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    submission.name.isEmpty ? '?' : submission.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D0D0D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      submission.id,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF98A2B3),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${submission.score}/${submission.total}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0D0D0D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.description_outlined,
            'Correct Answer: ${submission.correctAnswers}/${submission.total}',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Submitted $submittedAt',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.access_time_outlined,
            'Time Taken : ${submission.duration}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF98A2B3)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF667085),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AnalysisTab extends StatefulWidget {
  const _AnalysisTab({required this.quizId});
  final String quizId;

  @override
  State<_AnalysisTab> createState() => _AnalysisTabState();
}

class _AnalysisTabState extends State<_AnalysisTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().loadAnalysis(widget.quizId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.analysis == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final analysis = provider.analysis ?? QuizAnalysis.mock();

        return RefreshIndicator(
          onRefresh: () => provider.loadAnalysis(widget.quizId),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Stats
                Row(
                  children: [
                    Expanded(
                      child: _SummaryStatCard(
                        label: 'Lowest Score',
                        value: '${analysis.lowestScore}%',
                        valueColor: const Color(0xFFFF3D71),
                        icon: Icons.trending_down,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryStatCard(
                        label: 'Avg Score',
                        value: '${analysis.avgScore}%',
                        valueColor: const Color(0xFF0D0D0D),
                        icon: Icons.bar_chart,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryStatCard(
                        label: 'Highest Score',
                        value: '${analysis.highestScore}%',
                        valueColor: const Color(0xFF00D68F),
                        icon: Icons.trending_up,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Bar Chart Distribution
                Text(
                  'Score Graph Distribution for Quiz 1',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D0D0D),
                  ),
                ),
                const SizedBox(height: 20),
                _ScoreBarChart(distribution: analysis.scoreDistribution),
                const SizedBox(height: 40),

                // Pie Chart
                const Text(
                  'Pie Chart Distribution for Quiz 1',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D0D0D),
                  ),
                ),
                const SizedBox(height: 20),
                _ScorePieChart(
                  distribution: analysis.scoreDistribution,
                  totalStudents: analysis.totalStudents,
                ),
                const SizedBox(height: 40),

                // Top Performers
                const Text(
                  'Top Performers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D0D0D),
                  ),
                ),
                const SizedBox(height: 16),
                if (analysis.topPerformers.isEmpty)
                  const Center(child: Text('Analysis complete. View top students in Submissions.'))
                else
                  ...analysis.topPerformers.map(
                    (student) => _SubmissionCard(submission: student),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  const _SummaryStatCard({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.icon,
  });

  final String label;
  final String value;
  final Color valueColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: const Color(0xFF98A2B3)),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF98A2B3),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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

class _ScoreBarChart extends StatelessWidget {
  const _ScoreBarChart({required this.distribution});
  final Map<String, int> distribution;

  @override
  Widget build(BuildContext context) {
    final entries = distribution.entries.toList();
    final maxValue = entries.isEmpty ? 100.0 : entries.map((e) => e.value.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2;

    return Container(
      height: 300,
      padding: const EdgeInsets.only(top: 20, right: 20, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxValue,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < entries.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        entries[index].key,
                        style: const TextStyle(color: Color(0xFF98A2B3), fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: const Text(
                'Number of Students',
                style: TextStyle(fontSize: 10, color: Color(0xFF98A2B3), fontWeight: FontWeight.w500),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Color(0xFF98A2B3), fontSize: 10),
                ),
                reservedSize: 40,
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxValue / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: const Color(0xFFF2F4F7),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: entries.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value.toDouble(),
                  color: const Color(0xFF0D1724),
                  width: 28,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ScorePieChart extends StatelessWidget {
  const _ScorePieChart({required this.distribution, required this.totalStudents});
  final Map<String, int> distribution;
  final int totalStudents;

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF0055FF),
      const Color(0xFF0D1724),
      const Color(0xFFFF3D71),
      const Color(0xFF00D68F),
      const Color(0xFFFFAA00),
      const Color(0xFF3366FF),
    ];

    final sortedEntries = distribution.entries.toList();

    final sections = sortedEntries.asMap().entries.map((e) {
      final percentage = totalStudents == 0 ? 0 : (e.value.value / totalStudents) * 100;
      return PieChartSectionData(
        color: colors[e.key % colors.length],
        value: e.value.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Students', style: TextStyle(color: Color(0xFF98A2B3), fontSize: 12)),
          Text(totalStudents.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 0,
                      sections: sections,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sortedEntries.asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colors[e.key % colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            e.value.key,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF0D0D0D), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
