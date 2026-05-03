import 'package:flutter/material.dart';
import 'package:lexgo/screens/assignment_details_screen.dart';
import 'package:provider/provider.dart';

import '../../models/course.dart';
import '../../providers/course_assignments_provider.dart';
import '../../providers/course_resources_provider.dart';
import '../../providers/ai_materials_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/resource.dart';
import '../../widgets/navigation/app_back_button.dart';
import '../../widgets/courses/add_resource_sheet.dart';
import '../../widgets/courses/add_topic_sheet.dart';
import '../../widgets/courses/course_assignments_section.dart';
import '../../widgets/courses/qa_tab.dart';
import '../../widgets/create_newassignmentfab.dart';
import 'pdf_preview_screen.dart';
import 'ai_material_details_screen.dart';

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
  late final AiMaterialsProvider _aiMaterialsProvider;
  final ScrollController _resourcesScrollController = ScrollController();

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
    _aiMaterialsProvider = AiMaterialsProvider(courseId: courseId);
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        setState(() {});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resourcesProvider.load();
      _aiMaterialsProvider.loadMaterials();
    });
    _resourcesScrollController.addListener(_onResourcesScroll);
  }

  void _onResourcesScroll() {
    if (_resourcesScrollController.position.pixels >=
        _resourcesScrollController.position.maxScrollExtent - 200) {
      _resourcesProvider.loadMore();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _resourcesProvider.dispose();
    _aiMaterialsProvider.dispose();
    _resourcesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _resourcesProvider),
        ChangeNotifierProvider.value(value: _aiMaterialsProvider),
      ],
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
                            const AppBackButton(),
                            const SizedBox(width: 16),
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
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: AppColors.brandWhite),
                              onSelected: (value) async {
                                if (value == 'delete') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Course'),
                                      content: const Text('Are you sure you want to delete this course? All data will be lost.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    try {
                                      await _resourcesProvider.deleteCourse();
                                      if (mounted) Navigator.pop(context, true);
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Failed to delete course: $e')),
                                        );
                                      }
                                    }
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'delete', child: Text('Delete Course', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                            const SizedBox(width: 8),
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
                            Consumer<AiMaterialsProvider>(
                              builder: (context, aiProvider, _) {
                                final aiTopics = aiProvider.materials;
                                final totalCount = 1 + topics.length + aiTopics.length;
                                
                                return ListView.separated(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  itemCount: totalCount,
                                  physics: const BouncingScrollPhysics(),
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 14),
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      return _TopicsHeader(
                                        onAddTopic: () => _openAddTopicSheet(context),
                                        onGenerateAI: () => aiProvider.startGeneration(),
                                        isGenerating: aiProvider.status.isInProgress,
                                      );
                                    }
                                    
                                    final itemIndex = index - 1;
                                    if (itemIndex < topics.length) {
                                      return _TopicTile(
                                        number: itemIndex + 1,
                                        title: topics[itemIndex],
                                        subtitle: subtitles[itemIndex],
                                      );
                                    }

                                    final aiIndex = itemIndex - topics.length;
                                    final aiMaterial = aiTopics[aiIndex];
                                    return _TopicTile(
                                      number: itemIndex + 1,
                                      title: aiMaterial.topic,
                                      subtitle: 'AI Generated Content',
                                      isAi: true,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => AiMaterialDetailsScreen(
                                              material: aiMaterial,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
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
                                    scrollController: _resourcesScrollController,
                                    resources: resources,
                                    isLoadingMore: provider.isLoadingMore,
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
    this.isAi = false,
    this.onTap,
  });

  final int number;
  final String title;
  final String subtitle;
  final bool isAi;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: isAi ? Border.all(color: AppColors.brandNavy.withOpacity(0.2), width: 1.5) : null,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: isAi ? AppColors.brandNavy : AppColors.brandDark,
              child: isAi ? const Icon(Icons.auto_awesome, size: 14, color: AppColors.brandWhite) : Text(
                number.toString(),
                style: const TextStyle(color: AppColors.brandWhite),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (isAi)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.brandNavy.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('AI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandNavy)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.mutedText),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isAi ? AppColors.brandNavy : AppColors.brandDark,
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
      ),
    );
  }
}

class _TopicsHeader extends StatelessWidget {
  const _TopicsHeader({
    required this.onAddTopic,
    required this.onGenerateAI,
    this.isGenerating = false,
  });

  final VoidCallback onAddTopic;
  final VoidCallback onGenerateAI;
  final bool isGenerating;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
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
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: isGenerating ? null : onGenerateAI,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A5F), Color(0xFF0D1B2A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandNavy.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: isGenerating 
                    ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.auto_awesome, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGenerating ? 'Generating Materials...' : 'Generate with AI',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isGenerating ? 'Please wait, our AI is building your course content.' : 'Automagically create course topics and materials.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isGenerating)
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

typedef ResourceTap = void Function(CourseResource resource);

class _ResourceList extends StatelessWidget {
  const _ResourceList({
    required this.resources,
    required this.onResourceTap,
    this.scrollController,
    this.isLoadingMore = false,
  });

  final List<CourseResource> resources;
  final ResourceTap onResourceTap;
  final ScrollController? scrollController;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: resources.length + (isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == resources.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
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
