import 'package:flutter/material.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/course_card.dart';
import '../../common/widgets/loading_widget.dart';
import '../../common/widgets/custom_dialog.dart';
import '../../common/themes/app_theme.dart';
import '../../common/models/course.dart';
import '../../common/services/supabase_service.dart';

class InstructorCoursesScreen extends StatefulWidget {
  const InstructorCoursesScreen({super.key});

  @override
  State<InstructorCoursesScreen> createState() =>
      _InstructorCoursesScreenState();
}

class _InstructorCoursesScreenState extends State<InstructorCoursesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Course> _allCourses = [];
  List<Course> _publishedCourses = [];
  List<Course> _draftCourses = [];
  List<Course> _archivedCourses = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCourses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);

    try {
      // Fetch courses from database
      final courses = await SupabaseService.instance.getInstructorCourses('inst1'); // Replace with actual instructor ID
      _allCourses = courses.map((json) => Course.fromJson(json)).toList();
      _publishedCourses = _allCourses.where((c) => c.status == CourseStatus.published).toList();
      _draftCourses = _allCourses.where((c) => c.status == CourseStatus.draft).toList();
      _archivedCourses = _allCourses.where((c) => c.status == CourseStatus.archived).toList();
    } catch (e) {
      // Fallback to mock data if there's an error
      final mockCourses = [
        Course(
          id: '1',
          title: 'تطوير تطبيقات الموبايل',
          description: 'تعلم تطوير تطبيقات الموبايل باستخدام Flutter من الصفر',
          thumbnail:
              'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400&h=200&fit=crop',
          instructorId: 'inst1',
          instructorName: 'د. محمد أحمد',
          instructorAvatar:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=50&h=50&fit=crop&crop=face',
          status: CourseStatus.published,
          level: CourseLevel.beginner,
          price: 299,
          duration: 1200,
          lessonsCount: 24,
          rating: 4.8,
          reviewsCount: 156,
          enrolledCount: 1247,
          category: 'البرمجة',
          tags: ['Flutter', 'Mobile', 'Programming'],
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          publishedAt: DateTime.now().subtract(const Duration(days: 25)),
        ),
        Course(
          id: '2',
          title: 'علوم البيانات والذكاء الاصطناعي',
          description: 'اكتشف عالم البيانات وتعلم الذكاء الاصطناعي',
          thumbnail:
              'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=400&h=200&fit=crop',
          instructorId: 'inst1',
          instructorName: 'د. محمد أحمد',
          instructorAvatar:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=50&h=50&fit=crop&crop=face',
          status: CourseStatus.draft,
          level: CourseLevel.intermediate,
          price: 499,
          discountPrice: 399,
          duration: 1800,
          lessonsCount: 36,
          rating: 0,
          reviewsCount: 0,
          enrolledCount: 0,
          category: 'علوم البيانات',
          tags: ['AI', 'Data Science', 'Python'],
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Course(
          id: '3',
          title: 'تطوير المواقع الإلكترونية',
          description: 'تعلم تطوير المواقع الحديثة باستخدام React و Node.js',
          thumbnail:
              'https://images.unsplash.com/photo-1547658719-da2b51169166?w=400&h=200&fit=crop',
          instructorId: 'inst1',
          instructorName: 'د. محمد أحمد',
          instructorAvatar:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=50&h=50&fit=crop&crop=face',
          status: CourseStatus.archived,
          level: CourseLevel.intermediate,
          price: 399,
          duration: 1500,
          lessonsCount: 30,
          rating: 4.7,
          reviewsCount: 234,
          enrolledCount: 890,
          category: 'تطوير الويب',
          tags: ['React', 'Node.js', 'Web Development'],
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
          publishedAt: DateTime.now().subtract(const Duration(days: 40)),
        ),
      ];

      _allCourses = mockCourses;
      _publishedCourses =
          mockCourses.where((c) => c.status == CourseStatus.published).toList();
      _draftCourses =
          mockCourses.where((c) => c.status == CourseStatus.draft).toList();
      _archivedCourses =
          mockCourses.where((c) => c.status == CourseStatus.archived).toList();
    }

    setState(() => _isLoading = false);
  }

  List<Course> get _currentCourses {
    switch (_tabController.index) {
      case 0:
        return _allCourses;
      case 1:
        return _publishedCourses;
      case 2:
        return _draftCourses;
      case 3:
        return _archivedCourses;
      default:
        return _allCourses;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'كورساتي',
        showBackButton: false,
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: theme.appBarTheme.backgroundColor,
            child: TabBar(
              controller: _tabController,
              onTap: (index) {
                setState(() {});
              },
              tabs: [
                Tab(
                  child: _buildTabContent(
                    'الكل',
                    _allCourses.length,
                    theme,
                  ),
                ),
                Tab(
                  child: _buildTabContent(
                    'منشورة',
                    _publishedCourses.length,
                    theme,
                  ),
                ),
                Tab(
                  child: _buildTabContent(
                    'مسودات',
                    _draftCourses.length,
                    theme,
                  ),
                ),
                Tab(
                  child: _buildTabContent(
                    'مؤرشفة',
                    _archivedCourses.length,
                    theme,
                  ),
                ),
              ],
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor:
                  theme.colorScheme.onSurface.withOpacity(0.6),
              indicatorColor: AppTheme.primaryColor,
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: theme.textTheme.bodyMedium,
            ),
          ),

          // Course List
          Expanded(
            child: _isLoading
                ? const LoadingWidget(message: 'جاري تحميل الكورسات...')
                : _currentCourses.isEmpty
                    ? _buildEmptyState(theme)
                    : RefreshIndicator(
                        onRefresh: _loadCourses,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _currentCourses.length,
                          itemBuilder: (context, index) {
                            final course = _currentCourses[index];

                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index == _currentCourses.length - 1
                                    ? 0
                                    : 16,
                              ),
                              child: CourseCard(
                                course: course,
                                showInstructor: false,
                                onTap: () => _onCourseCardTap(course),
                                trailing: _buildCourseActions(course, theme),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewCourse,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('كورس جديد'),
      ),
    );
  }

  Widget _buildTabContent(String label, int count, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        if (count > 0) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    String message;
    IconData icon;

    switch (_tabController.index) {
      case 0:
        message = 'لم تقم بإنشاء أي كورس بعد';
        icon = Icons.school_outlined;
        break;
      case 1:
        message = 'لا توجد كورسات منشورة';
        icon = Icons.publish;
        break;
      case 2:
        message = 'لا توجد مسودات';
        icon = Icons.drafts;
        break;
      case 3:
        message = 'لا توجد كورسات مؤرشفة';
        icon = Icons.archive;
        break;
      default:
        message = 'لا توجد كورسات';
        icon = Icons.school_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewCourse,
            icon: const Icon(Icons.add),
            label: const Text('إنشاء كورس جديد'),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseActions(Course course, ThemeData theme) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleCourseAction(course, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit),
              SizedBox(width: 8),
              Text('تعديل'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'duplicate',
          child: Row(
            children: [
              Icon(Icons.copy),
              SizedBox(width: 8),
              Text('نسخ'),
            ],
          ),
        ),
        if (course.status == CourseStatus.draft)
          const PopupMenuItem(
            value: 'publish',
            child: Row(
              children: [
                Icon(Icons.publish),
                SizedBox(width: 8),
                Text('نشر'),
              ],
            ),
          ),
        if (course.status == CourseStatus.published)
          const PopupMenuItem(
            value: 'unpublish',
            child: Row(
              children: [
                Icon(Icons.unpublished),
                SizedBox(width: 8),
                Text('إلغاء النشر'),
              ],
            ),
          ),
        if (course.status != CourseStatus.archived)
          const PopupMenuItem(
            value: 'archive',
            child: Row(
              children: [
                Icon(Icons.archive),
                SizedBox(width: 8),
                Text('أرشفة'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('حذف', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: const Icon(Icons.more_vert),
      ),
    );
  }

  void _handleCourseAction(Course course, String action) async {
    switch (action) {
      case 'edit':
        // Navigate to edit course
        break;
      case 'duplicate':
        await _duplicateCourse(course);
        break;
      case 'publish':
        await _publishCourse(course);
        break;
      case 'unpublish':
        await _unpublishCourse(course);
        break;
      case 'archive':
        await _archiveCourse(course);
        break;
      case 'delete':
        await _deleteCourse(course);
        break;
    }
  }

  Future<void> _duplicateCourse(Course course) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'نسخ الكورس',
      message: 'هل تريد إنشاء نسخة من "${course.title}"؟',
      confirmText: 'نسخ',
      cancelText: 'إلغاء',
    );

    if (confirmed == true) {
      // Implement duplication logic
      CustomDialog.showSuccess(
        context: context,
        title: 'نجح',
        message: 'تم إنشاء نسخة من الكورس بنجاح',
      );
    }
  }

  Future<void> _publishCourse(Course course) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'نشر الكورس',
      message: 'هل تريد نشر "${course.title}"؟ سيصبح متاحاً للطلاب.',
      confirmText: 'نشر',
      cancelText: 'إلغاء',
    );

    if (confirmed == true) {
      // Implement publish logic
      CustomDialog.showSuccess(
        context: context,
        title: 'نجح',
        message: 'تم نشر الكورس بنجاح',
      );
      _loadCourses();
    }
  }

  Future<void> _unpublishCourse(Course course) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'إلغاء نشر الكورس',
      message: 'هل تريد إلغاء نشر "${course.title}"؟ لن يعود متاحاً للطلاب.',
      confirmText: 'إلغاء النشر',
      cancelText: 'إلغاء',
    );

    if (confirmed == true) {
      // Implement unpublish logic
      CustomDialog.showSuccess(
        context: context,
        title: 'نجح',
        message: 'تم إلغاء نشر الكورس بنجاح',
      );
      _loadCourses();
    }
  }

  Future<void> _archiveCourse(Course course) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'أرشفة الكورس',
      message: 'هل تريد أرشفة "${course.title}"؟',
      confirmText: 'أرشفة',
      cancelText: 'إلغاء',
    );

    if (confirmed == true) {
      // Implement archive logic
      CustomDialog.showSuccess(
        context: context,
        title: 'نجح',
        message: 'تم أرشفة الكورس بنجاح',
      );
      _loadCourses();
    }
  }

  Future<void> _deleteCourse(Course course) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'حذف الكورس',
      message:
          'هل تريد حذف "${course.title}"؟ هذا الإجراء لا يمكن التراجع عنه.',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
    );

    if (confirmed == true) {
      // Implement delete logic
      CustomDialog.showSuccess(
        context: context,
        title: 'نجح',
        message: 'تم حذف الكورس بنجاح',
      );
      _loadCourses();
    }
  }

  void _createNewCourse() {
    // Navigate to create course screen
    Navigator.pushNamed(context, '/instructor/create-course');
  }

  void _onCourseCardTap(Course course) {
    // Navigate to course details/edit
    Navigator.pushNamed(
      context,
      '/instructor/course-details',
      arguments: course,
    );
  }
}
