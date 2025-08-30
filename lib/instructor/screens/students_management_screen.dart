import 'package:flutter/material.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/loading_widget.dart';
import '../../common/widgets/custom_dialog.dart';
import '../../common/themes/app_theme.dart';
import '../../common/models/user.dart';
import '../../common/models/course.dart';

class StudentsManagementScreen extends StatefulWidget {
  const StudentsManagementScreen({super.key});

  @override
  State<StudentsManagementScreen> createState() =>
      _StudentsManagementScreenState();
}

class _StudentsManagementScreenState extends State<StudentsManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCourse = 'الكل';
  String _selectedStatus = 'الكل';
  final String _sortBy = 'enrollment_date';

  List<Map<String, dynamic>> _students = [];
  List<Course> _instructorCourses = [];
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock instructor courses
    _instructorCourses = [
      Course(
        id: 'course_1',
        title: 'تطوير تطبيقات Flutter',
        description: 'كورس شامل لتعلم Flutter',
        thumbnail:
            'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=300&h=200&fit=crop',
        instructorId: 'instructor_1',
        instructorName: 'أحمد محمد',
        instructorAvatar: '',
        status: CourseStatus.published,
        level: CourseLevel.intermediate,
        price: 299.0,
        duration: 480,
        lessonsCount: 45,
        rating: 4.8,
        reviewsCount: 156,
        enrolledCount: 1240,
        category: 'البرمجة',
        tags: ['Flutter', 'Dart'],
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Course(
        id: 'course_2',
        title: 'أساسيات البرمجة',
        description: 'مقدمة في البرمجة للمبتدئين',
        thumbnail:
            'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=300&h=200&fit=crop',
        instructorId: 'instructor_1',
        instructorName: 'أحمد محمد',
        instructorAvatar: '',
        status: CourseStatus.published,
        level: CourseLevel.beginner,
        price: 199.0,
        duration: 360,
        lessonsCount: 32,
        rating: 4.6,
        reviewsCount: 89,
        enrolledCount: 567,
        category: 'البرمجة',
        tags: ['Programming', 'Basics'],
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];

    // Mock students data
    _students = [
      {
        'id': 'student_1',
        'user': User(
          id: 'user_1',
          name: 'سارة أحمد',
          email: 'sara@example.com',
          avatar:
              'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=50&h=50&fit=crop&crop=face',
          role: UserRole.student,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        'enrolledCourses': [
          {
            'courseId': 'course_1',
            'courseTitle': 'تطوير تطبيقات Flutter',
            'enrollmentDate': DateTime.now().subtract(const Duration(days: 15)),
            'progress': 0.75,
            'completedLessons': 34,
            'totalLessons': 45,
            'lastActivity': DateTime.now().subtract(const Duration(hours: 2)),
            'status': 'نشط',
            'grade': 85,
          }
        ],
        'totalCourses': 1,
        'completedCourses': 0,
        'totalWatchTime': 45.5,
        'averageGrade': 85,
        'lastLogin': DateTime.now().subtract(const Duration(hours: 2)),
        'joinDate': DateTime.now().subtract(const Duration(days: 30)),
      },
      {
        'id': 'student_2',
        'user': User(
          id: 'user_2',
          name: 'محمد علي',
          email: 'mohammed@example.com',
          avatar:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=50&h=50&fit=crop&crop=face',
          role: UserRole.student,
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
        ),
        'enrolledCourses': [
          {
            'courseId': 'course_1',
            'courseTitle': 'تطوير تطبيقات Flutter',
            'enrollmentDate': DateTime.now().subtract(const Duration(days: 30)),
            'progress': 1.0,
            'completedLessons': 45,
            'totalLessons': 45,
            'lastActivity': DateTime.now().subtract(const Duration(days: 1)),
            'status': 'مكتمل',
            'grade': 92,
          },
          {
            'courseId': 'course_2',
            'courseTitle': 'أساسيات البرمجة',
            'enrollmentDate': DateTime.now().subtract(const Duration(days: 20)),
            'progress': 0.4,
            'completedLessons': 13,
            'totalLessons': 32,
            'lastActivity': DateTime.now().subtract(const Duration(hours: 5)),
            'status': 'نشط',
            'grade': 78,
          }
        ],
        'totalCourses': 2,
        'completedCourses': 1,
        'totalWatchTime': 78.3,
        'averageGrade': 85,
        'lastLogin': DateTime.now().subtract(const Duration(hours: 5)),
        'joinDate': DateTime.now().subtract(const Duration(days: 45)),
      },
      {
        'id': 'student_3',
        'user': User(
          id: 'user_3',
          name: 'فاطمة حسن',
          email: 'fatima@example.com',
          avatar:
              'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=50&h=50&fit=crop&crop=face',
          role: UserRole.student,
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
        'enrolledCourses': [
          {
            'courseId': 'course_2',
            'courseTitle': 'أساسيات البرمجة',
            'enrollmentDate': DateTime.now().subtract(const Duration(days: 10)),
            'progress': 0.15,
            'completedLessons': 5,
            'totalLessons': 32,
            'lastActivity': DateTime.now().subtract(const Duration(days: 3)),
            'status': 'غير نشط',
            'grade': 65,
          }
        ],
        'totalCourses': 1,
        'completedCourses': 0,
        'totalWatchTime': 12.7,
        'averageGrade': 65,
        'lastLogin': DateTime.now().subtract(const Duration(days: 3)),
        'joinDate': DateTime.now().subtract(const Duration(days: 20)),
      },
    ];

    // Mock statistics
    _statistics = {
      'totalStudents': _students.length,
      'activeStudents': _students
          .where((s) =>
              (s['enrolledCourses'] as List).any((c) => c['status'] == 'نشط'))
          .length,
      'completedStudents':
          _students.where((s) => s['completedCourses'] > 0).length,
      'averageProgress': _students.fold<double>(0, (sum, student) {
            final courses = student['enrolledCourses'] as List;
            final totalProgress = courses.fold<double>(
                0, (sum, course) => sum + course['progress']);
            return sum +
                (courses.isNotEmpty ? totalProgress / courses.length : 0);
          }) /
          _students.length,
      'averageGrade': _students.fold<double>(
              0, (sum, student) => sum + student['averageGrade']) /
          _students.length,
      'totalWatchTime': _students.fold<double>(
          0, (sum, student) => sum + student['totalWatchTime']),
    };

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'إدارة الطلاب',
        actions: [
          IconButton(
            onPressed: _exportData,
            icon: const Icon(Icons.download),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'send_message',
                child: Row(
                  children: [
                    Icon(Icons.message),
                    SizedBox(width: 8),
                    Text('إرسال رسالة جماعية'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'send_notification',
                child: Row(
                  children: [
                    Icon(Icons.notifications),
                    SizedBox(width: 8),
                    Text('إرسال إشعار'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'generate_report',
                child: Row(
                  children: [
                    Icon(Icons.assessment),
                    SizedBox(width: 8),
                    Text('تقرير مفصل'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'نظرة عامة'),
            Tab(text: 'قائمة الطلاب'),
            Tab(text: 'التحليلات'),
          ],
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: AppTheme.primaryColor,
        ),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'جاري تحميل بيانات الطلاب...')
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(theme),
                _buildStudentsListTab(theme),
                _buildAnalyticsTab(theme),
              ],
            ),
    );
  }

  Widget _buildOverviewTab(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Cards
            _buildStatisticsCards(theme),

            const SizedBox(height: 24),

            // Recent Activity
            _buildRecentActivity(theme),

            const SizedBox(height: 24),

            // Top Performing Students
            _buildTopStudents(theme),

            const SizedBox(height: 24),

            // Course Performance
            _buildCoursePerformance(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsListTab(ThemeData theme) {
    return Column(
      children: [
        // Search and Filters
        _buildSearchAndFilters(theme),

        // Students List
        Expanded(
          child: _buildStudentsList(theme),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التحليلات التفصيلية',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Progress Chart
          _buildProgressChart(theme),

          const SizedBox(height: 24),

          // Engagement Metrics
          _buildEngagementMetrics(theme),

          const SizedBox(height: 24),

          // Course Completion Rates
          _buildCompletionRates(theme),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(ThemeData theme) {
    final stats = [
      {
        'title': 'إجمالي الطلاب',
        'value': '${_statistics['totalStudents']}',
        'icon': Icons.people,
        'color': AppTheme.primaryColor,
        'change': '+12%',
        'isPositive': true,
      },
      {
        'title': 'الطلاب النشطون',
        'value': '${_statistics['activeStudents']}',
        'icon': Icons.trending_up,
        'color': AppTheme.successColor,
        'change': '+8%',
        'isPositive': true,
      },
      {
        'title': 'معدل الإكمال',
        'value': '${(_statistics['averageProgress'] * 100).toInt()}%',
        'icon': Icons.check_circle,
        'color': AppTheme.warningColor,
        'change': '+5%',
        'isPositive': true,
      },
      {
        'title': 'متوسط الدرجات',
        'value': '${_statistics['averageGrade'].toInt()}',
        'icon': Icons.star,
        'color': AppTheme.accentColor,
        'change': '+3%',
        'isPositive': true,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (stat['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        stat['icon'] as IconData,
                        color: stat['color'] as Color,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (stat['isPositive'] as bool)
                            ? AppTheme.successColor.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        stat['change'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: (stat['isPositive'] as bool)
                              ? AppTheme.successColor
                              : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  stat['value'] as String,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: stat['color'] as Color,
                  ),
                ),
                Text(
                  stat['title'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity(ThemeData theme) {
    final activities = [
      {
        'type': 'enrollment',
        'student': 'سارة أحمد',
        'course': 'تطوير تطبيقات Flutter',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'icon': Icons.person_add,
        'color': AppTheme.primaryColor,
      },
      {
        'type': 'completion',
        'student': 'محمد علي',
        'course': 'أساسيات البرمجة',
        'time': DateTime.now().subtract(const Duration(hours: 5)),
        'icon': Icons.check_circle,
        'color': AppTheme.successColor,
      },
      {
        'type': 'message',
        'student': 'فاطمة حسن',
        'course': 'تطوير تطبيقات Flutter',
        'time': DateTime.now().subtract(const Duration(hours: 8)),
        'icon': Icons.message,
        'color': AppTheme.accentColor,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'النشاط الأخير',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: _viewAllActivity,
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (activity['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    activity['icon'] as IconData,
                    color: activity['color'] as Color,
                    size: 20,
                  ),
                ),
                title: Text(activity['student'] as String),
                subtitle: Text(activity['course'] as String),
                trailing: Text(
                  _formatTime(activity['time'] as DateTime),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopStudents(ThemeData theme) {
    final topStudents = _students
        .where((student) => student['averageGrade'] >= 80)
        .toList()
      ..sort((a, b) => b['averageGrade'].compareTo(a['averageGrade']));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أفضل الطلاب',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topStudents.take(3).length,
            itemBuilder: (context, index) {
              final student = topStudents[index];
              final user = student['user'] as User;
              return ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage: user.avatar != null
                          ? NetworkImage(user.avatar!)
                          : null,
                      backgroundColor: AppTheme.primaryColor,
                      child: user.avatar == null
                          ? Text(
                              user.name[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            )
                          : null,
                    ),
                    if (index < 3)
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: index == 0
                                ? Colors.amber
                                : index == 1
                                    ? Colors.grey[400]
                                    : Colors.brown,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(user.name),
                subtitle: Text('${student['completedCourses']} كورس مكتمل'),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${student['averageGrade']}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () => _viewStudentDetails(student),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCoursePerformance(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أداء الكورسات',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _instructorCourses.length,
            itemBuilder: (context, index) {
              final course = _instructorCourses[index];
              final enrolledStudents = _students
                  .where((student) => (student['enrolledCourses'] as List)
                      .any((c) => c['courseId'] == course.id))
                  .length;
              final completedStudents = _students
                  .where((student) => (student['enrolledCourses'] as List).any(
                      (c) =>
                          c['courseId'] == course.id && c['status'] == 'مكتمل'))
                  .length;
              final completionRate = enrolledStudents > 0
                  ? (completedStudents / enrolledStudents)
                  : 0.0;

              return ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: course.thumbnail != null
                        ? DecorationImage(
                            image: NetworkImage(course.thumbnail!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: course.thumbnail == null
                        ? theme.colorScheme.surfaceContainerHighest
                        : null,
                  ),
                  child: course.thumbnail == null
                      ? Icon(
                          Icons.image,
                          color: theme.colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
                title: Text(
                  course.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$enrolledStudents طالب مسجل'),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: completionRate,
                      backgroundColor:
                          theme.colorScheme.outline.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.successColor),
                    ),
                  ],
                ),
                trailing: Text(
                  '${(completionRate * 100).toInt()}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successColor,
                  ),
                ),
                onTap: () => _viewCourseDetails(course),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'البحث عن طالب...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Filters
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCourse,
                  decoration: const InputDecoration(
                    labelText: 'الكورس',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                        value: 'الكل', child: Text('جميع الكورسات')),
                    ..._instructorCourses.map((course) {
                      return DropdownMenuItem(
                        value: course.id,
                        child: Text(
                          course.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCourse = value ?? 'الكل';
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'الحالة',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'الكل', child: Text('جميع الحالات')),
                    DropdownMenuItem(value: 'نشط', child: Text('نشط')),
                    DropdownMenuItem(value: 'مكتمل', child: Text('مكتمل')),
                    DropdownMenuItem(value: 'غير نشط', child: Text('غير نشط')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value ?? 'الكل';
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList(ThemeData theme) {
    final filteredStudents = _students.where((student) {
      final user = student['user'] as User;
      final matchesSearch = _searchQuery.isEmpty ||
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCourse = _selectedCourse == 'الكل' ||
          (student['enrolledCourses'] as List)
              .any((c) => c['courseId'] == _selectedCourse);

      final matchesStatus = _selectedStatus == 'الكل' ||
          (student['enrolledCourses'] as List)
              .any((c) => c['status'] == _selectedStatus);

      return matchesSearch && matchesCourse && matchesStatus;
    }).toList();

    if (filteredStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لم نجد أي طلاب يطابقون معايير البحث',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        final user = student['user'] as User;
        final enrolledCourses = student['enrolledCourses'] as List;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundImage:
                  user.avatar != null ? NetworkImage(user.avatar!) : null,
              backgroundColor: AppTheme.primaryColor,
              child: user.avatar == null
                  ? Text(
                      user.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
            ),
            title: Text(
              user.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'آخر نشاط: ${_formatTime(student['lastLogin'])}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleStudentAction(value, student),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view_profile',
                  child: Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 8),
                      Text('عرض الملف الشخصي'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'send_message',
                  child: Row(
                    children: [
                      Icon(Icons.message),
                      SizedBox(width: 8),
                      Text('إرسال رسالة'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'view_progress',
                  child: Row(
                    children: [
                      Icon(Icons.analytics),
                      SizedBox(width: 8),
                      Text('عرض التقدم'),
                    ],
                  ),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الكورسات المسجلة:',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...enrolledCourses.map((course) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    course['courseTitle'],
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(course['status'])
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    course['status'],
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: _getStatusColor(course['status']),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'التقدم: ${(course['progress'] * 100).toInt()}%',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                      const SizedBox(height: 4),
                                      LinearProgressIndicator(
                                        value: course['progress'],
                                        backgroundColor: theme
                                            .colorScheme.outline
                                            .withOpacity(0.3),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          _getStatusColor(course['status']),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'الدرجة: ${course['grade']}%',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${course['completedLessons']} من ${course['totalLessons']} دروس',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressChart(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مخطط التقدم الشهري',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('مخطط التقدم الشهري\n(قيد التطوير)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementMetrics(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مقاييس التفاعل',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'متوسط وقت المشاهدة',
                    '${(_statistics['totalWatchTime'] / _statistics['totalStudents']).toStringAsFixed(1)} ساعة',
                    Icons.play_circle,
                    AppTheme.primaryColor,
                    theme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'معدل الحضور',
                    '78%',
                    Icons.event_available,
                    AppTheme.successColor,
                    theme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'معدل التفاعل',
                    '85%',
                    Icons.thumb_up,
                    AppTheme.accentColor,
                    theme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'متوسط الاستبقاء',
                    '92%',
                    Icons.history,
                    AppTheme.warningColor,
                    theme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionRates(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معدلات الإكمال حسب الكورس',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._instructorCourses.map((course) {
              final enrolledStudents = _students
                  .where((student) => (student['enrolledCourses'] as List)
                      .any((c) => c['courseId'] == course.id))
                  .length;
              final completedStudents = _students
                  .where((student) => (student['enrolledCourses'] as List).any(
                      (c) =>
                          c['courseId'] == course.id && c['status'] == 'مكتمل'))
                  .length;
              final completionRate = enrolledStudents > 0
                  ? (completedStudents / enrolledStudents)
                  : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            course.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '${(completionRate * 100).toInt()}%',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: completionRate,
                      backgroundColor:
                          theme.colorScheme.outline.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.successColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedStudents من $enrolledStudents طلاب أكملوا الكورس',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'نشط':
        return AppTheme.primaryColor;
      case 'مكتمل':
        return AppTheme.successColor;
      case 'غير نشط':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'send_message':
        _sendGroupMessage();
        break;
      case 'send_notification':
        _sendNotification();
        break;
      case 'generate_report':
        _generateReport();
        break;
    }
  }

  void _handleStudentAction(String action, Map<String, dynamic> student) {
    switch (action) {
      case 'view_profile':
        _viewStudentProfile(student);
        break;
      case 'send_message':
        _sendMessageToStudent(student);
        break;
      case 'view_progress':
        _viewStudentProgress(student);
        break;
    }
  }

  void _exportData() {
    CustomDialog.show(
      context: context,
      type: DialogType.info,
      title: 'تصدير البيانات',
      message: 'ميزة تصدير البيانات قيد التطوير',
    );
  }

  void _viewAllActivity() {
    CustomDialog.show(
      context: context,
      type: DialogType.info,
      title: 'عرض جميع الأنشطة',
      message: 'ميزة عرض جميع الأنشطة قيد التطوير',
    );
  }

  void _viewStudentDetails(Map<String, dynamic> student) {
    Navigator.pushNamed(
      context,
      '/instructor/student-details',
      arguments: student,
    );
  }

  void _viewCourseDetails(Course course) {
    Navigator.pushNamed(
      context,
      '/instructor/course-analytics',
      arguments: course,
    );
  }

  void _sendGroupMessage() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GroupMessageBottomSheet(
        students: _students,
        onMessageSent: (String message, List<Map<String, dynamic>> recipients) {
          CustomDialog.showSuccess(
            context: context,
            title: 'تم الإرسال',
            message: 'تم إرسال الرسالة إلى ${recipients.length} طالب',
          );
        },
      ),
    );
  }

  void _sendNotification() {
    CustomDialog.show(
      context: context,
      type: DialogType.info,
      title: 'إرسال إشعار',
      message: 'ميزة الإشعارات قيد التطوير',
    );
  }

  void _generateReport() {
    CustomDialog.show(
      context: context,
      type: DialogType.info,
      title: 'تقرير مفصل',
      message: 'ميزة التقارير المفصلة قيد التطوير',
    );
  }

  void _viewStudentProfile(Map<String, dynamic> student) {
    Navigator.pushNamed(
      context,
      '/instructor/student-profile',
      arguments: student,
    );
  }

  void _sendMessageToStudent(Map<String, dynamic> student) {
    // Create User object from student data
    final studentUser = User(
      id: student['id'] ?? 'student_id',
      name: student['name'] ?? 'طالب',
      email: student['email'] ?? 'student@example.com',
      avatar: student['avatar'],
      role: UserRole.student,
      createdAt: DateTime.now(),
    );

    Navigator.pushNamed(
      context,
      '/instructor/chat',
      arguments: studentUser,
    );
  }

  void _viewStudentProgress(Map<String, dynamic> student) {
    Navigator.pushNamed(
      context,
      '/instructor/student-progress',
      arguments: student,
    );
  }
}

// Group Message Bottom Sheet
class _GroupMessageBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> students;
  final Function(String message, List<Map<String, dynamic>> recipients)
      onMessageSent;

  const _GroupMessageBottomSheet({
    required this.students,
    required this.onMessageSent,
  });

  @override
  State<_GroupMessageBottomSheet> createState() =>
      _GroupMessageBottomSheetState();
}

class _GroupMessageBottomSheetState extends State<_GroupMessageBottomSheet> {
  final _messageController = TextEditingController();
  List<Map<String, dynamic>> _selectedStudents = [];
  bool _isSending = false;
  bool _selectAll = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.message, color: AppTheme.primaryColor),
              const SizedBox(width: 12),
              Text(
                'إرسال رسالة جماعية',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Select All Checkbox
          CheckboxListTile(
            title: const Text('تحديد الكل'),
            subtitle: Text('${widget.students.length} طالب'),
            value: _selectAll,
            onChanged: (value) {
              setState(() {
                _selectAll = value ?? false;
                if (_selectAll) {
                  _selectedStudents = List.from(widget.students);
                } else {
                  _selectedStudents.clear();
                }
              });
            },
          ),

          const Divider(),

          // Students List
          Expanded(
            child: ListView.builder(
              itemCount: widget.students.length,
              itemBuilder: (context, index) {
                final student = widget.students[index];
                final isSelected = _selectedStudents.contains(student);

                return CheckboxListTile(
                  title: Text(student['name'] ?? 'طالب'),
                  subtitle: Text(student['email'] ?? ''),
                  secondary: CircleAvatar(
                    backgroundImage: student['avatar'] != null
                        ? NetworkImage(student['avatar'])
                        : null,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: student['avatar'] == null
                        ? const Icon(
                            Icons.person,
                            color: AppTheme.primaryColor,
                          )
                        : null,
                  ),
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedStudents.add(student);
                      } else {
                        _selectedStudents.remove(student);
                      }
                      _selectAll =
                          _selectedStudents.length == widget.students.length;
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Message Input
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'نص الرسالة',
              hintText: 'اكتب رسالتك هنا...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 24),

          // Send Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selectedStudents.isNotEmpty &&
                      _messageController.text.trim().isNotEmpty &&
                      !_isSending)
                  ? _sendMessage
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSending
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('جاري الإرسال...'),
                      ],
                    )
                  : Text('إرسال إلى ${_selectedStudents.length} طالب'),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_selectedStudents.isEmpty || _messageController.text.trim().isEmpty) {
      return;
    }

    setState(() => _isSending = true);

    // Simulate sending message
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSending = false);

    Navigator.pop(context);
    widget.onMessageSent(_messageController.text.trim(), _selectedStudents);
  }
}
