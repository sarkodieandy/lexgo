import 'package:flutter/material.dart';

import '../models/quiz_item.dart';
import '../theme/app_colors.dart';

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
              _Header(title: quiz.title, onBack: () => Navigator.of(context).maybePop()),
              Container(
                color: AppColors.brandDark,
                child: TabBar(
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(color: AppColors.brandWhite, width: 2),
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
                  child: const TabBarView(
                    children: [
                      SizedBox.expand(child: Center(child: Text('Questions tab content'))),
                      _QuizSettingsTab(),
                      SizedBox.expand(child: Center(child: Text('Submissions tab content'))),
                      SizedBox.expand(child: Center(child: Text('Analysis tab content'))),
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
              FieldSpec(label: 'Quiz Title', placeholder: 'eg. Criminal Law', required: true),
              FieldSpec(label: 'Course', placeholder: 'Introduction to law', dropdown: true),
              FieldSpec(label: 'Description/Instruction', placeholder: 'Brief description of what the quiz covers...'),
            ],
          ),
          SizedBox(height: 18),
          SectionCard(
            title: 'Time Settings',
            description: 'Configure quiz duration and availability',
            fields: [
              FieldSpec(label: 'Quiz Duration', placeholder: 'eg. 30mins', icon: Icons.schedule),
              FieldSpec(label: 'Start Date', placeholder: 'DD/MM/YY', icon: Icons.calendar_today),
              FieldSpec(label: 'Start Time', placeholder: 'HH:MM', icon: Icons.schedule),
              FieldSpec(label: 'End Date', placeholder: 'DD/MM/YY', icon: Icons.calendar_today),
              FieldSpec(label: 'End Time', placeholder: 'HH:MM', icon: Icons.schedule),
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
              FieldSpec(label: 'Maximum Attempts', placeholder: '1', dropdown: true),
            ],
          ),
          SizedBox(height: 18),
          SectionCard(
            title: 'Grading Settings',
            description: 'Configure how the quiz is graded',
            toggles: [
              ToggleSpec(label: 'Show Scores Immediately'),
            ],
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
          ...fields
              .map((field) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildField(field),
                  ))
              ,
          ...dropdownFields
              .map((field) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildDropdown(field),
                  ))
              ,
          ...toggles
              .map((toggle) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildToggle(toggle),
                  ))
              ,
        ],
      ),
    );
  }

  Widget _buildField(FieldSpec spec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          spec.label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
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
        Text(
          spec.label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
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
            Text(toggle.label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('Present questions in random order for each student',
                style: TextStyle(color: AppColors.mutedText, fontSize: 12)),
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
