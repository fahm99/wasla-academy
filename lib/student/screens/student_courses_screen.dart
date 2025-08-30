import 'package:flutter/material.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/course_card.dart';
import '../../common/widgets/loading_widget.dart';
import '../../common/themes/app_theme.dart';
import '../../common/models/course.dart';
import '../../common/services/supabase_service.dart';

enum CourseFilter {
  all,
  inProgress,
  completed,
  notStarted,
}

class StudentCoursesScreen extends StatefulWidget {
  const StudentCoursesScreen({super.key});

  @override
  State<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends State<StudentCoursesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Course> _allCourses = [];
  List<Course> _inProgressCourses = [];
  List<Course> _completedCourses = [];
  List<Course> _notStartedCourses = [];
  CourseFilter _currentFilter = CourseFilter.all;

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
      final coursesData = await SupabaseService.instance
          .getStudentCoursesWithProgress(
              'student_id'); // Replace with actual student ID
      _allCourses = coursesData.map((json) => Course.fromJson(json)).toList();

      // Categorize courses
      _inProgressCourses =
          _allCourses.where((c) => c.progress > 0 && c.progress < 100).toList();
      _completedCourses = _allCourses.where((c) => c.progress == 100).toList();
      _notStartedCourses = _allCourses.where((c) => c.progress == 0).toList();
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
          tags: ['Flutter', 'Mobile', 'Programming'],
          category: 'البرمجة',
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
          instructorId: 'inst2',
          instructorName: 'د. فاطمة علي',
          instructorAvatar:
              'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=50&h=50&fit=crop&crop=face',
          status: CourseStatus.published,
          level: CourseLevel.intermediate,
          price: 499,
          discountPrice: 399,
          duration: 1800,
          lessonsCount: 36,
          rating: 4.9,
          reviewsCount: 89,
          enrolledCount: 567,
          tags: ['AI', 'Data Science', 'Python'],
          category: 'علوم البيانات',
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          publishedAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
        Course(
          id: '3',
          title: 'تطوير المواقع الإلكترونية',
          description: 'تعلم تطوير المواقع الحديثة باستخدام React و Node.js',
          thumbnail:
              'https://images.unsplash.com/photo-1547658719-da2b51169166?w=400&h=200&fit=crop',
          instructorId: 'inst3',
          instructorName: 'أ. سارة محمود',
          instructorAvatar:
              'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=50&h=50&fit=crop&crop=face',
          status: CourseStatus.published,
          level: CourseLevel.intermediate,
          price: 399,
          duration: 1500,
          lessonsCount: 30,
          rating: 4.7,
          reviewsCount: 234,
          enrolledCount: 890,
          tags: ['React', 'Node.js', 'Web Development'],
          category: 'تطوير الويب',
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
          publishedAt: DateTime.now().subtract(const Duration(days: 40)),
        ),
      ];

      _allCourses = mockCourses;
      _inProgressCourses = [mockCourses[0], mockCourses[2]];
      _completedCourses = [mockCourses[1]];
      _notStartedCourses = [];
    }

    setState(() => _isLoading = false);
  }

  List<Course> get _filteredCourses {
    switch (_currentFilter) {
      case CourseFilter.all:
        return _allCourses;
      case CourseFilter.inProgress:
        return _inProgressCourses;
      case CourseFilter.completed:
        return _completedCourses;
      case CourseFilter.notStarted:
        return _notStartedCourses;
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
                setState(() {
                  _currentFilter = CourseFilter.values[index];
                });
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
                    'قيد التقدم',
                    _inProgressCourses.length,
                    theme,
                  ),
                ),
                Tab(
                  child: _buildTabContent(
                    'مكتملة',
                    _completedCourses.length,
                    theme,
                  ),
                ),
                Tab(
                  child: _buildTabContent(
                    'لم تبدأ',
                    _notStartedCourses.length,
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
                : _filteredCourses.isEmpty
                    ? _buildEmptyState(theme)
                    : RefreshIndicator(
                        onRefresh: _loadCourses,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredCourses.length,
                          itemBuilder: (context, index) {
                            final course = _filteredCourses[index];
                            final isInProgress =
                                _inProgressCourses.contains(course);
                            final isCompleted =
                                _completedCourses.contains(course);

                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index == _filteredCourses.length - 1
                                    ? 0
                                    : 16,
                              ),
                              child: CourseCard(
                                course: course,
                                showProgress: isInProgress || isCompleted,
                                progress: isCompleted
                                    ? 100
                                    : isInProgress
                                        ? (index == 0 ? 65 : 30)
                                        : null,
                                onTap: () => _onCourseCardTap(course),
                                trailing: _buildCourseTrailing(
                                  course,
                                  isInProgress,
                                  isCompleted,
                                  theme,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
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

    switch (_currentFilter) {
      case CourseFilter.all:
        message = 'لم تسجل في أي كورس بعد';
        icon = Icons.school_outlined;
        break;
      case CourseFilter.inProgress:
        message = 'لا توجد كورسات قيد التقدم';
        icon = Icons.play_circle_outline;
        break;
      case CourseFilter.completed:
        message = 'لم تكمل أي كورس بعد';
        icon = Icons.check_circle_outline;
        break;
      case CourseFilter.notStarted:
        message = 'لا توجد كورسات لم تبدأ';
        icon = Icons.pause_circle_outline;
        break;
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
            onPressed: () {
              // Navigate to course catalog
            },
            icon: const Icon(Icons.explore),
            label: const Text('استكشف الكورسات'),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseTrailing(
    Course course,
    bool isInProgress,
    bool isCompleted,
    ThemeData theme,
  ) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.successColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'مكتمل',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else if (isInProgress) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.play_circle,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'متابعة',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.warningColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'ابدأ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }

  void _onCourseCardTap(Course course) {
    // Navigate to course details
    Navigator.pushNamed(
      context,
      '/student/course-details',
      arguments: course,
    );
  }
}
