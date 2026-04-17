import 'package:flutter/material.dart';
import 'package:lexgo/screens/assignment_details_screen.dart';
import 'package:provider/provider.dart';

import '../../models/course.dart';
import '../../providers/course_assignments_provider.dart';
import '../../providers/course_resources_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/resource.dart';
import '../../widgets/courses/add_resource_sheet.dart';
import '../../widgets/courses/add_topic_sheet.dart';
import '../../widgets/courses/course_assignments_section.dart';
import '../../widgets/courses/qa_tab.dart';
import '../../widgets/create_newassignmentfab.dart';
import 'pdf_preview_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key, required this.course});

  final Course course;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final CourseResourcesProvider _resourcesProvider;

  void _openAddTopicSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const AddTopicSheet(),
      ),
    );
  }

  void _openAddResourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddResourceSheet(),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    if (_tabController.index == 1) {
      return FloatingActionButton(
        onPressed: () {
          final provider = context.read<CourseAssignmentsProvider>();
          final nextNumber = provider.assignmentsFor(widget.course).length + 1;
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => CreateNewAssignment(
              course: widget.course,
              assignmentNumber: nextNumber,
              onCreate: (assignment) =>
                  provider.addAssignment(widget.course, assignment),
            ),
          );
        },
        backgroundColor: AppColors.brandDark,
        child: const Icon(Icons.add, color: AppColors.brandWhite),
      );
    }
    if (_tabController.index == 2) {
      return FloatingActionButton(
        onPressed: () => _openAddResourceSheet(context),
        backgroundColor: AppColors.brandDark,
        child: const Icon(Icons.add, color: AppColors.brandWhite),
      );
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final course = widget.course;
    final courseId = course.id.isNotEmpty ? course.id : course.code;
    _resourcesProvider = CourseResourcesProvider(courseId: courseId);
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        setState(() {});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resourcesProvider.load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _resourcesProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _resourcesProvider,
      child: Builder(
        builder: (context) {
          final course = widget.course;
          final topics = [
            'Separation of Powers',
            'Fundamental Rights',
            'Judicial Review',
            'Constitutional Interpretation',
            'Free Speech',
            'Religious Freedom',
          ];
          final subtitles = [
            'Distribution of Authority',
            'Human Rights',
            'Review',
            'Translation',
            'Freedom of speech',
            'African Religion',
          ];
          final assignments = context
              .watch<CourseAssignmentsProvider>()
              .assignmentsFor(course);
          return Scaffold(
            backgroundColor: AppColors.brandDark,
            floatingActionButton: _buildFloatingActionButton(context),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: AppColors.brandDark,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).maybePop(),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.brandNavy,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: AppColors.brandWhite,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                course.title,
                                style: const TextStyle(
                                  color: AppColors.brandWhite,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              width: 48,
                              height: 48,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.brandWhite,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Image.asset(
                                'assets/Union.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          indicatorColor: AppColors.brandWhite,
                          indicatorWeight: 3,
                          tabs: const [
                            Tab(text: 'Topics'),
                            Tab(text: 'Assignments'),
                            Tab(text: 'Resources'),
                            Tab(text: 'Q&A'),
                          ],
                        ),
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
                          left: 24,
                          right: 24,
                          bottom: 80,
                        ),
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            ListView.separated(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: topics.length + 1,
                              physics: const BouncingScrollPhysics(),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return _TopicsHeader(
                                    onAddTopic: () =>
                                        _openAddTopicSheet(context),
                                  );
                                }
                                final topicIndex = index - 1;
                                return _TopicTile(
                                  number: topicIndex + 1,
                                  title: topics[topicIndex],
                                  subtitle: subtitles[topicIndex],
                                );
                              },
                            ),
                            CourseAssignmentsSection(
                              assignments: assignments,
                              onAssignmentTap: (assignment) =>
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AssignmentDetailsScreen(
                                        assignment: assignment,
                                      ),
                                    ),
                                  ),
                            ),
                            Consumer<CourseResourcesProvider>(
                              builder: (context, provider, _) {
                                if (provider.isLoading &&
                                    provider.resources.isEmpty) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (provider.error != null &&
                                    provider.resources.isEmpty) {
                                  return Center(
                                    child: Text(
                                      provider.error!,
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  );
                                }

                                final resources = provider.resources;
                                if (resources.isEmpty) {
                                  return RefreshIndicator(
                                    onRefresh: () => provider.load(),
                                    child: ListView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      children: const [
                                        SizedBox(height: 120),
                                        Center(
                                          child: Text('No resources yet'),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return RefreshIndicator(
                                  onRefresh: () => provider.load(),
                                  child: _ResourceList(
                                    resources: resources,
                                    onResourceTap: (resource) =>
                                        Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => PdfPreviewScreen(
                                          resourceId: resource.id,
                                          title: resource.title,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const CourseQATab(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  final int number;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.brandDark,
            child: Text(
              number.toString(),
              style: const TextStyle(color: AppColors.brandWhite),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.mutedText),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.brandDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.brandWhite,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicsHeader extends StatelessWidget {
  const _TopicsHeader({required this.onAddTopic});

  final VoidCallback onAddTopic;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Topics',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        ElevatedButton.icon(
          onPressed: onAddTopic,
          icon: const Icon(Icons.add, size: 16),
          label: const Text(
            'Add Topic',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandDark,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}

typedef ResourceTap = void Function(CourseResource resource);

class _ResourceList extends StatelessWidget {
  const _ResourceList({required this.resources, required this.onResourceTap});

  final List<CourseResource> resources;
  final ResourceTap onResourceTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: resources.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final resource = resources[index];
        return InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => onResourceTap(resource),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            margin: const EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              color: AppColors.brandWhite,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6E2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.insert_drive_file,
                    color: AppColors.brandDark,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        resource.formattedTimestamp,
                        style: const TextStyle(color: AppColors.mutedText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
