import 'package:flutter/material.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/loading_widget.dart';
import '../../common/widgets/custom_dialog.dart';
import '../../common/widgets/course_card.dart';
import '../../common/themes/app_theme.dart';
import '../../common/models/course.dart';
import '../../common/models/user.dart';

class AdminCoursesScreen extends StatefulWidget {
  const AdminCoursesScreen({super.key});

  @override
  State<AdminCoursesScreen> createState() => _AdminCoursesScreenState();
}

class _AdminCoursesScreenState extends State<AdminCoursesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  String _selectedStatus = 'الكل';
  String _selectedInstructor = 'الكل';
  final String _sortBy = 'created_date';
  bool _isSelectionMode = false;

  List<Course> _courses = [];
  List<User> _instructors = [];
  List<String> _selectedCourseIds = [];
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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

    // Mock instructors
    _instructors = [
      User(
        id: 'instructor_1',
        name: 'أحمد محمد',
        email: 'ahmed@example.com',
        avatar:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=50&h=50&fit=crop&crop=face',
        role: UserRole.instructor,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
      User(
        id: 'instructor_2',
        name: 'فاطمة علي',
        email: 'fatima@example.com',
        avatar:
            'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=50&h=50&fit=crop&crop=face',
        role: UserRole.instructor,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
      User(
        id: 'instructor_3',
        name: 'محمد حسن',
        email: 'mohammed@example.com',
        avatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=50&h=50&fit=crop&crop=face',
        role: UserRole.instructor,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
    ];

    // Mock courses
    _courses = [
      Course(
        id: 'course_1',
        title: 'تطوير تطبيقات Flutter المتقدمة',
        description: 'كورس شامل لتعلم تطوير تطبيقات معقدة باستخدام Flutter',
        thumbnail:
            'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=300&h=200&fit=crop',
        instructorId: 'instructor_1',
        price: 299.0,
        discountPrice: 199.0,
        rating: 4.8,
        reviewsCount: 156,
        enrolledCount: 1240,
        duration: 480,
        lessonsCount: 45,
        level: CourseLevel.advanced,
        category: 'البرمجة',
        tags: ['Flutter', 'Dart', 'Advanced'],
        instructorName: 'أحمد محمد',
        instructorAvatar:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=50&h=50&fit=crop&crop=face',
        status: CourseStatus.published,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Course(
        id: 'course_2',
        title: 'تصميم واجهات المستخدم الحديثة',
        description: 'أساسيات ومتقدمات تصميم UI/UX للتطبيقات والمواقع',
        thumbnail:
            'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=300&h=200&fit=crop',
        instructorId: 'instructor_2',
        price: 199.0,
        rating: 4.6,
        reviewsCount: 89,
        enrolledCount: 567,
        duration: 360,
        lessonsCount: 32,
        level: CourseLevel.intermediate,
        category: 'التصميم',
        tags: ['UI', 'UX', 'Design'],
        instructorName: 'فاطمة علي',
        instructorAvatar:
            'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=50&h=50&fit=crop&crop=face',
        status: CourseStatus.published,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Course(
        id: 'course_3',
        title: 'أساسيات علوم البيانات',
        description: 'مقدمة شاملة في علوم البيانات والتحليل الإحصائي',
        thumbnail:
            'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=300&h=200&fit=crop',
        instructorId: 'instructor_3',
        price: 149.0,
        rating: 4.4,
        reviewsCount: 234,
        enrolledCount: 890,
        duration: 300,
        lessonsCount: 28,
        level: CourseLevel.beginner,
        category: 'علوم البيانات',
        tags: ['Python', 'Data Science', 'Analytics'],
        instructorName: 'محمد حسن',
        instructorAvatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=50&h=50&fit=crop&crop=face',
        status: CourseStatus.published,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Course(
        id: 'course_4',
        title: 'التسويق الرقمي المتقدم',
        description: 'استراتيجيات التسويق الرقمي ووسائل التواصل الاجتماعي',
        thumbnail:
            'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=300&h=200&fit=crop',
        instructorId: 'instructor_1',
        price: 0.0, // Free course
        rating: 4.2,
        reviewsCount: 145,
        enrolledCount: 2340,
        duration: 240,
        lessonsCount: 20,
        level: CourseLevel.intermediate,
        category: 'التسويق',
        tags: ['Marketing', 'Digital', 'Social Media'],
        instructorName: 'أحمد محمد',
        instructorAvatar:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=50&h=50&fit=crop&crop=face',
        status: CourseStatus.published,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    // Mock statistics
    _statistics = {
      'totalCourses': _courses.length,
      'publishedCourses': _courses.where((c) => c.rating > 0).length,
      'pendingReview': 2,
      'totalRevenue': _courses.fold<double>(
          0, (sum, course) => sum + (course.price * course.enrolledCount)),
      'totalEnrollments':
          _courses.fold<int>(0, (sum, course) => sum + course.enrolledCount),
      'averageRating':
          _courses.fold<double>(0, (sum, course) => sum + course.rating) /
              _courses.length,
    };

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'إدارة الكورسات',
        actions: [
          if (_isSelectionMode) ...[
            TextButton(
              onPressed: _cancelSelection,
              child: const Text('إلغاء'),
            ),
          ] else ...[
            IconButton(
              onPressed: _exportData,
              icon: const Icon(Icons.download),
            ),
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'bulk_actions',
                  child: Row(
                    children: [
                      Icon(Icons.checklist),
                      SizedBox(width: 8),
                      Text('إجراءات متعددة'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'import_courses',
                  child: Row(
                    children: [
                      Icon(Icons.upload),
                      SizedBox(width: 8),
                      Text('استيراد كورسات'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'analytics',
                  child: Row(
                    children: [
                      Icon(Icons.analytics),
                      SizedBox(width: 8),
                      Text('تحليلات مفصلة'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'نظرة عامة'),
            Tab(text: 'جميع الكورسات'),
            Tab(text: 'قيد المراجعة'),
            Tab(text: 'التحليلات'),
          ],
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: AppTheme.primaryColor,
          isScrollable: true,
        ),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'جاري تحميل بيانات الكورسات...')
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(theme),
                _buildAllCoursesTab(theme),
                _buildPendingReviewTab(theme),
                _buildAnalyticsTab(theme),
              ],
            ),
      bottomNavigationBar:
          _isSelectionMode ? _buildSelectionBottomBar(theme) : null,
      floatingActionButton: !_isSelectionMode
          ? FloatingActionButton.extended(
              onPressed: _createNewCourse,
              icon: const Icon(Icons.add),
              label: const Text('إنشاء كورس'),
            )
          : null,
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

            // Recent Courses
            _buildRecentCourses(theme),

            const SizedBox(height: 24),

            // Top Performing Courses
            _buildTopPerformingCourses(theme),

            const SizedBox(height: 24),

            // Category Distribution
            _buildCategoryDistribution(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildAllCoursesTab(ThemeData theme) {
    return Column(
      children: [
        // Search and Filters
        _buildSearchAndFilters(theme),

        // Courses List
        Expanded(
          child: _buildCoursesList(theme),
        ),
      ],
    );
  }

  Widget _buildPendingReviewTab(ThemeData theme) {
    final pendingCourses = _courses
        .where((course) => course.createdAt
            .isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .toList();

    if (pendingCourses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: AppTheme.successColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد كورسات قيد المراجعة',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'جميع الكورسات تمت مراجعتها والموافقة عليها',
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
      itemCount: pendingCourses.length,
      itemBuilder: (context, index) {
        final course = pendingCourses[index];
        return _buildPendingCourseCard(course, theme);
      },
    );
  }

  Widget _buildAnalyticsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تحليلات الكورسات',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Revenue Chart
          _buildRevenueChart(theme),

          const SizedBox(height: 24),

          // Enrollment Trends
          _buildEnrollmentTrends(theme),

          const SizedBox(height: 24),

          // Instructor Performance
          _buildInstructorPerformance(theme),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(ThemeData theme) {
    final stats = [
      {
        'title': 'إجمالي الكورسات',
        'value': '${_statistics['totalCourses']}',
        'icon': Icons.school,
        'color': AppTheme.primaryColor,
        'change': '+5',
        'isPositive': true,
      },
      {
        'title': 'الكورسات المنشورة',
        'value': '${_statistics['publishedCourses']}',
        'icon': Icons.publish,
        'color': AppTheme.successColor,
        'change': '+3',
        'isPositive': true,
      },
      {
        'title': 'قيد المراجعة',
        'value': '${_statistics['pendingReview']}',
        'icon': Icons.pending,
        'color': AppTheme.warningColor,
        'change': '-1',
        'isPositive': false,
      },
      {
        'title': 'إجمالي التسجيلات',
        'value':
            '${(_statistics['totalEnrollments'] / 1000).toStringAsFixed(1)}K',
        'icon': Icons.people,
        'color': AppTheme.accentColor,
        'change': '+12%',
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

  Widget _buildRecentCourses(ThemeData theme) {
    final recentCourses = _courses
        .where((course) => course.createdAt
            .isAfter(DateTime.now().subtract(const Duration(days: 30))))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الكورسات الحديثة',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _tabController.animateTo(1),
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recentCourses.take(5).length,
            itemBuilder: (context, index) {
              final course = recentCourses[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.only(right: 16),
                child: CourseCard(
                  course: course,
                  onTap: () => _viewCourseDetails(course),
                  showFavoriteButton: false,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopPerformingCourses(ThemeData theme) {
    final topCourses = _courses.where((course) => course.rating >= 4.5).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أفضل الكورسات أداءً',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topCourses.take(3).length,
            itemBuilder: (context, index) {
              final course = topCourses[index];
              return ListTile(
                leading: Stack(
                  children: [
                    Container(
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
                      ),
                    ),
                    if (index < 3)
                      Positioned(
                        top: -2,
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
                title: Text(
                  course.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                    '${course.enrolledCount} طالب • ${course.instructorName}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${course.rating}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                onTap: () => _viewCourseDetails(course),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDistribution(ThemeData theme) {
    final categories = <String, int>{};
    for (final course in _courses) {
      categories[course.category] = (categories[course.category] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'توزيع الكورسات حسب التصنيف',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: categories.entries.map((entry) {
                final percentage = (entry.value / _courses.length);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor:
                              theme.colorScheme.outline.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${entry.value}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
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
              hintText: 'البحث عن كورس...',
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('التصنيف', _selectedCategory, [
                  'الكل',
                  'البرمجة',
                  'التصميم',
                  'التسويق',
                  'علوم البيانات',
                  'الأعمال',
                ], (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }),
                const SizedBox(width: 12),
                _buildFilterChip('الحالة', _selectedStatus, [
                  'الكل',
                  'منشور',
                  'مسودة',
                  'مؤرشف',
                ], (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }),
                const SizedBox(width: 12),
                _buildFilterChip('المدرب', _selectedInstructor, [
                  'الكل',
                  ..._instructors.map((i) => i.name),
                ], (value) {
                  setState(() {
                    _selectedInstructor = value;
                  });
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String selectedValue,
    List<String> options,
    Function(String) onSelected,
  ) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (context) => options.map((option) {
        return PopupMenuItem(
          value: option,
          child: Row(
            children: [
              if (option == selectedValue) const Icon(Icons.check, size: 16),
              if (option == selectedValue) const SizedBox(width: 8),
              Text(option),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selectedValue != options.first
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selectedValue != options.first
                ? AppTheme.primaryColor
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: $selectedValue',
              style: TextStyle(
                color: selectedValue != options.first
                    ? AppTheme.primaryColor
                    : null,
                fontWeight:
                    selectedValue != options.first ? FontWeight.w600 : null,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color:
                  selectedValue != options.first ? AppTheme.primaryColor : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesList(ThemeData theme) {
    final filteredCourses = _courses.where((course) {
      final matchesSearch = _searchQuery.isEmpty ||
          course.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          course.instructorName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == 'الكل' || course.category == _selectedCategory;

      final matchesInstructor = _selectedInstructor == 'الكل' ||
          course.instructorName == _selectedInstructor;

      return matchesSearch && matchesCategory && matchesInstructor;
    }).toList();

    if (filteredCourses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
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
              'لم نجد أي كورسات تطابق معايير البحث',
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
      itemCount: filteredCourses.length,
      itemBuilder: (context, index) {
        final course = filteredCourses[index];
        final isSelected = _selectedCourseIds.contains(course.id);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Stack(
            children: [
              CourseCard(
                course: course,
                onTap: _isSelectionMode
                    ? () => _toggleCourseSelection(course.id)
                    : () => _viewCourseDetails(course),
                showFavoriteButton: false,
                trailing: !_isSelectionMode
                    ? PopupMenuButton<String>(
                        onSelected: (value) =>
                            _handleCourseAction(value, course),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(Icons.visibility),
                                SizedBox(width: 8),
                                Text('عرض التفاصيل'),
                              ],
                            ),
                          ),
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
                                Text('حذف',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
              if (_isSelectionMode)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor : Colors.white,
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryColor : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingCourseCard(Course course, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: course.thumbnail != null
                        ? DecorationImage(
                            image: NetworkImage(course.thumbnail!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'بواسطة ${course.instructorName}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'قيد المراجعة',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.warningColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              course.description,
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectCourse(course),
                    icon: const Icon(Icons.close),
                    label: const Text('رفض'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveCourse(course),
                    icon: const Icon(Icons.check),
                    label: const Text('موافقة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الإيرادات الشهرية',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildRevenueBar(
                            'ينا', 85000, 100000, AppTheme.primaryColor, theme),
                        _buildRevenueBar(
                            'فبر', 92000, 100000, AppTheme.accentColor, theme),
                        _buildRevenueBar(
                            'مار', 78000, 100000, AppTheme.successColor, theme),
                        _buildRevenueBar(
                            'أبر', 95000, 100000, AppTheme.warningColor, theme),
                        _buildRevenueBar('ماي', 110000, 100000,
                            AppTheme.primaryColor, theme),
                        _buildRevenueBar(
                            'يون', 125000, 100000, AppTheme.accentColor, theme),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'إجمالي: 685,000 ر.س',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successColor,
                        ),
                      ),
                      Text(
                        'نمو: +18.5%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrollmentTrends(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اتجاهات التسجيل',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: CustomPaint(
                      size: const Size(double.infinity, double.infinity),
                      painter: _EnrollmentTrendsPainter(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTrendLegend(
                          'تسجيلات جديدة', AppTheme.primaryColor, theme),
                      _buildTrendLegend(
                          'طلاب نشطين', AppTheme.accentColor, theme),
                      _buildTrendLegend(
                          'إكمالات', AppTheme.successColor, theme),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructorPerformance(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أداء المدربين',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._instructors.map((instructor) {
              final instructorCourses = _courses
                  .where((c) => c.instructorName == instructor.name)
                  .toList();
              final totalEnrollments = instructorCourses.fold<int>(
                  0, (sum, course) => sum + course.enrolledCount);
              final averageRating = instructorCourses.isNotEmpty
                  ? instructorCourses.fold<double>(
                          0, (sum, course) => sum + course.rating) /
                      instructorCourses.length
                  : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: instructor.avatar != null
                          ? NetworkImage(instructor.avatar!)
                          : null,
                      backgroundColor: AppTheme.primaryColor,
                      child: instructor.avatar == null
                          ? Text(
                              instructor.name[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            instructor.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${instructorCourses.length} كورس • $totalEnrollments طالب',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            averageRating.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  Widget _buildSelectionBottomBar(ThemeData theme) {
    final selectedCount = _selectedCourseIds.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'تم تحديد $selectedCount كورس',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: selectedCount > 0 ? _selectAllCourses : null,
            icon: const Icon(Icons.select_all),
            label: const Text('تحديد الكل'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: selectedCount > 0 ? _bulkActions : null,
            icon: const Icon(Icons.more_horiz),
            label: const Text('إجراءات'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'bulk_actions':
        setState(() {
          _isSelectionMode = true;
        });
        break;
      case 'import_courses':
        _importCourses();
        break;
      case 'analytics':
        _tabController.animateTo(3);
        break;
    }
  }

  void _handleCourseAction(String action, Course course) {
    switch (action) {
      case 'view':
        _viewCourseDetails(course);
        break;
      case 'edit':
        _editCourse(course);
        break;
      case 'duplicate':
        _duplicateCourse(course);
        break;
      case 'archive':
        _archiveCourse(course);
        break;
      case 'delete':
        _deleteCourse(course);
        break;
    }
  }

  void _cancelSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedCourseIds.clear();
    });
  }

  void _toggleCourseSelection(String courseId) {
    setState(() {
      if (_selectedCourseIds.contains(courseId)) {
        _selectedCourseIds.remove(courseId);
      } else {
        _selectedCourseIds.add(courseId);
      }
    });
  }

  void _selectAllCourses() {
    setState(() {
      _selectedCourseIds = _courses.map((c) => c.id).toList();
    });
  }

  void _bulkActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.publish),
              title: const Text('نشر الكورسات المحددة'),
              onTap: () {
                Navigator.pop(context);
                _publishSelectedCourses();
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('أرشفة الكورسات المحددة'),
              onTap: () {
                Navigator.pop(context);
                _archiveSelectedCourses();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('حذف الكورسات المحددة',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteSelectedCourses();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportData() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExportDataBottomSheet(
        courses: _courses,
        instructors: _instructors,
        statistics: _statistics,
      ),
    );
  }

  void _importCourses() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ImportCoursesBottomSheet(
        onImportComplete: (List<Course> importedCourses) {
          setState(() {
            _courses.addAll(importedCourses);
          });
          _loadData(); // Refresh statistics
        },
      ),
    );
  }

  void _createNewCourse() {
    Navigator.pushNamed(context, '/admin/create-course');
  }

  void _viewCourseDetails(Course course) {
    Navigator.pushNamed(
      context,
      '/admin/course-details',
      arguments: course,
    );
  }

  void _editCourse(Course course) {
    Navigator.pushNamed(
      context,
      '/admin/edit-course',
      arguments: course,
    );
  }

  void _duplicateCourse(Course course) async {
    final result = await CustomDialog.showInput(
      context: context,
      title: 'نسخ الكورس',
      message: 'أدخل عنوان النسخة الجديدة:',
      hintText: 'عنوان الكورس (نسخة)',
      initialValue: '${course.title} (نسخة)',
    );

    if (result != null && result.isNotEmpty) {
      // Create a duplicate course with new ID and title
      final duplicatedCourse = Course(
        id: 'course_${DateTime.now().millisecondsSinceEpoch}',
        title: result,
        description: course.description,
        thumbnail: course.thumbnail,
        instructorId: course.instructorId,
        instructorName: course.instructorName,
        instructorAvatar: course.instructorAvatar,
        status: CourseStatus.draft, // Start as draft
        level: course.level,
        price: course.price,
        discountPrice: course.discountPrice,
        duration: course.duration,
        lessonsCount: course.lessonsCount,
        rating: 0.0, // Reset rating
        reviewsCount: 0, // Reset reviews
        enrolledCount: 0, // Reset enrollments
        category: course.category,
        tags: List.from(course.tags ?? []),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      setState(() {
        _courses.add(duplicatedCourse);
      });

      CustomDialog.showSuccess(
        context: context,
        title: 'تم النسخ',
        message: 'تم نسخ الكورس بنجاح. يمكنك الآن تعديله.',
      );
    }
  }

  void _archiveCourse(Course course) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'أرشفة الكورس',
      message: 'هل تريد أرشفة "${course.title}"؟',
      confirmText: 'أرشفة',
      cancelText: 'إلغاء',
    );

    if (confirmed == true) {
      CustomDialog.showSuccess(
        context: context,
        title: 'تم الأرشفة',
        message: 'تم أرشفة الكورس بنجاح',
      );
    }
  }

  void _deleteCourse(Course course) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'حذف الكورس',
      message:
          'هل تريد حذف "${course.title}" نهائياً؟ لا يمكن التراجع عن هذا الإجراء.',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
    );

    if (confirmed == true) {
      setState(() {
        _courses.removeWhere((c) => c.id == course.id);
      });

      CustomDialog.showSuccess(
        context: context,
        title: 'تم الحذف',
        message: 'تم حذف الكورس بنجاح',
      );
    }
  }

  void _approveCourse(Course course) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'موافقة على الكورس',
      message: 'هل تريد الموافقة على نشر "${course.title}"؟',
      confirmText: 'موافقة',
      cancelText: 'إلغاء',
    );

    if (confirmed == true) {
      CustomDialog.showSuccess(
        context: context,
        title: 'تم الموافقة',
        message: 'تم الموافقة على الكورس ونشره بنجاح',
      );
    }
  }

  void _rejectCourse(Course course) async {
    final reason = await CustomDialog.showInput(
      context: context,
      title: 'رفض الكورس',
      message: 'يرجى إدخال سبب الرفض:',
      hintText: 'سبب الرفض...',
    );

    if (reason != null && reason.isNotEmpty) {
      CustomDialog.showSuccess(
        context: context,
        title: 'تم الرفض',
        message: 'تم رفض الكورس وإرسال السبب للمدرب',
      );
    }
  }

  void _publishSelectedCourses() async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'نشر الكورسات',
      message: 'هل تريد نشر ${_selectedCourseIds.length} كورس؟',
      confirmText: 'نشر',
      cancelText: 'إلغاء',
    );

    if (confirmed == true) {
      setState(() {
        _isSelectionMode = false;
        _selectedCourseIds.clear();
      });

      CustomDialog.showSuccess(
        context: context,
        title: 'تم النشر',
        message: 'تم نشر الكورسات المحددة بنجاح',
      );
    }
  }

  void _archiveSelectedCourses() async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'أرشفة الكورسات',
      message: 'هل تريد أرشفة ${_selectedCourseIds.length} كورس؟',
      confirmText: 'أرشفة',
      cancelText: 'إلغاء',
    );

    if (confirmed == true) {
      setState(() {
        _isSelectionMode = false;
        _selectedCourseIds.clear();
      });

      CustomDialog.showSuccess(
        context: context,
        title: 'تم الأرشفة',
        message: 'تم أرشفة الكورسات المحددة بنجاح',
      );
    }
  }

  void _deleteSelectedCourses() async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'حذف الكورسات',
      message:
          'هل تريد حذف ${_selectedCourseIds.length} كورس نهائياً؟ لا يمكن التراجع عن هذا الإجراء.',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
    );

    if (confirmed == true) {
      setState(() {
        _courses
            .removeWhere((course) => _selectedCourseIds.contains(course.id));
        _isSelectionMode = false;
        _selectedCourseIds.clear();
      });

      CustomDialog.showSuccess(
        context: context,
        title: 'تم الحذف',
        message: 'تم حذف الكورسات المحددة بنجاح',
      );
    }
  }

  // Helper method for building revenue chart bars
  Widget _buildRevenueBar(
    String month,
    double amount,
    double maxAmount,
    Color color,
    ThemeData theme,
  ) {
    final height = (amount / maxAmount * 120).toDouble();

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${(amount / 1000).toStringAsFixed(0)}K',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.7),
                    color,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              month,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for building trend legend
  Widget _buildTrendLegend(String label, Color color, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// Custom painter for enrollment trends chart
class _EnrollmentTrendsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Sample data points for different trends
    final newEnrollmentsData = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.2, size.height * 0.6),
      Offset(size.width * 0.4, size.height * 0.4),
      Offset(size.width * 0.6, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width, size.height * 0.1),
    ];

    final activeStudentsData = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.4, size.height * 0.6),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.8, size.height * 0.3),
      Offset(size.width, size.height * 0.2),
    ];

    final completionsData = [
      Offset(0, size.height * 0.9),
      Offset(size.width * 0.2, size.height * 0.8),
      Offset(size.width * 0.4, size.height * 0.7),
      Offset(size.width * 0.6, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.4),
      Offset(size.width, size.height * 0.3),
    ];

    // Draw new enrollments line
    paint.color = AppTheme.primaryColor;
    final newEnrollmentsPath = Path();
    newEnrollmentsPath.moveTo(
        newEnrollmentsData[0].dx, newEnrollmentsData[0].dy);
    for (int i = 1; i < newEnrollmentsData.length; i++) {
      newEnrollmentsPath.lineTo(
          newEnrollmentsData[i].dx, newEnrollmentsData[i].dy);
    }
    canvas.drawPath(newEnrollmentsPath, paint);

    // Draw active students line
    paint.color = AppTheme.accentColor;
    final activeStudentsPath = Path();
    activeStudentsPath.moveTo(
        activeStudentsData[0].dx, activeStudentsData[0].dy);
    for (int i = 1; i < activeStudentsData.length; i++) {
      activeStudentsPath.lineTo(
          activeStudentsData[i].dx, activeStudentsData[i].dy);
    }
    canvas.drawPath(activeStudentsPath, paint);

    // Draw completions line
    paint.color = AppTheme.successColor;
    final completionsPath = Path();
    completionsPath.moveTo(completionsData[0].dx, completionsData[0].dy);
    for (int i = 1; i < completionsData.length; i++) {
      completionsPath.lineTo(completionsData[i].dx, completionsData[i].dy);
    }
    canvas.drawPath(completionsPath, paint);

    // Draw data points
    paint.style = PaintingStyle.fill;

    // New enrollments points
    paint.color = AppTheme.primaryColor;
    for (final point in newEnrollmentsData) {
      canvas.drawCircle(point, 3, paint);
    }

    // Active students points
    paint.color = AppTheme.accentColor;
    for (final point in activeStudentsData) {
      canvas.drawCircle(point, 3, paint);
    }

    // Completions points
    paint.color = AppTheme.successColor;
    for (final point in completionsData) {
      canvas.drawCircle(point, 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// Export Data Bottom Sheet
class _ExportDataBottomSheet extends StatefulWidget {
  final List<Course> courses;
  final List<User> instructors;
  final Map<String, dynamic> statistics;

  const _ExportDataBottomSheet({
    required this.courses,
    required this.instructors,
    required this.statistics,
  });

  @override
  State<_ExportDataBottomSheet> createState() => _ExportDataBottomSheetState();
}

class _ExportDataBottomSheetState extends State<_ExportDataBottomSheet> {
  String _selectedFormat = 'csv';
  String _selectedData = 'courses';
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.download, color: AppTheme.primaryColor),
              const SizedBox(width: 12),
              Text(
                'تصدير البيانات',
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

          // Data Type Selection
          Text(
            'نوع البيانات',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              RadioListTile<String>(
                title: const Text('بيانات الكورسات'),
                subtitle: Text('${widget.courses.length} كورس'),
                value: 'courses',
                groupValue: _selectedData,
                onChanged: (value) {
                  setState(() {
                    _selectedData = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('بيانات المدربين'),
                subtitle: Text('${widget.instructors.length} مدرب'),
                value: 'instructors',
                groupValue: _selectedData,
                onChanged: (value) {
                  setState(() {
                    _selectedData = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('الإحصائيات العامة'),
                subtitle: const Text('التقارير والإحصائيات'),
                value: 'statistics',
                groupValue: _selectedData,
                onChanged: (value) {
                  setState(() {
                    _selectedData = value!;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Format Selection
          Text(
            'تنسيق الملف',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('CSV'),
                  value: 'csv',
                  groupValue: _selectedFormat,
                  onChanged: (value) {
                    setState(() {
                      _selectedFormat = value!;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Excel'),
                  value: 'xlsx',
                  groupValue: _selectedFormat,
                  onChanged: (value) {
                    setState(() {
                      _selectedFormat = value!;
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Export Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isExporting ? null : _exportData,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isExporting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('جاري التصدير...'),
                      ],
                    )
                  : const Text('تصدير البيانات'),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _exportData() async {
    setState(() => _isExporting = true);

    // Simulate export process
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isExporting = false);

    Navigator.pop(context);
    CustomDialog.showSuccess(
      context: context,
      title: 'تم التصدير',
      message: 'تم تصدير البيانات بنجاح. تحقق من مجلد التحميلات.',
    );
  }
}

// Import Courses Bottom Sheet
class _ImportCoursesBottomSheet extends StatefulWidget {
  final Function(List<Course>) onImportComplete;

  const _ImportCoursesBottomSheet({
    required this.onImportComplete,
  });

  @override
  State<_ImportCoursesBottomSheet> createState() =>
      _ImportCoursesBottomSheetState();
}

class _ImportCoursesBottomSheetState extends State<_ImportCoursesBottomSheet> {
  bool _isImporting = false;
  String? _selectedFile;
  List<Course> _previewCourses = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.upload, color: AppTheme.primaryColor),
              const SizedBox(width: 12),
              Text(
                'استيراد كورسات',
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

          // File Selection
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedFile ?? 'اختر ملف CSV أو Excel',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'يجب أن يحتوي الملف على: العنوان، الوصف، السعر، الفئة',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _selectFile,
                  child: const Text('اختيار ملف'),
                ),
              ],
            ),
          ),

          if (_previewCourses.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'معاينة البيانات (${_previewCourses.length} كورس)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: ListView.builder(
                itemCount: _previewCourses.length,
                itemBuilder: (context, index) {
                  final course = _previewCourses[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: const Icon(
                        Icons.school,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      course.title,
                      style: theme.textTheme.titleSmall,
                    ),
                    subtitle: Text(
                      '${course.price} ر.س • ${course.category ?? 'غير محدد'}',
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Import Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  (_selectedFile != null && !_isImporting) ? _importData : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isImporting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('جاري الاستيراد...'),
                      ],
                    )
                  : const Text('استيراد الكورسات'),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _selectFile() async {
    // Simulate file picker
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _selectedFile = 'courses_data.csv';
      // Simulate parsing preview data
      _previewCourses = [
        Course(
          id: 'preview_1',
          title: 'تطوير تطبيقات متقدمة',
          description: 'كورس شامل في تطوير التطبيقات',
          instructorId: 'instructor_1',
          instructorName: 'مدرب مستورد',
          status: CourseStatus.draft,
          level: CourseLevel.intermediate,
          price: 399.0,
          rating: 0.0,
          reviewsCount: 0,
          enrolledCount: 0,
          duration: 480,
          lessonsCount: 30,
          category: 'البرمجة',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Course(
          id: 'preview_2',
          title: 'تصميم الجرافيك الحديث',
          description: 'تعلم التصميم الجرافيكي من الصفر',
          instructorId: 'instructor_2',
          instructorName: 'مدرب مستورد 2',
          status: CourseStatus.draft,
          level: CourseLevel.beginner,
          price: 199.0,
          rating: 0.0,
          reviewsCount: 0,
          enrolledCount: 0,
          duration: 360,
          lessonsCount: 25,
          category: 'التصميم',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    });
  }

  void _importData() async {
    setState(() => _isImporting = true);

    // Simulate import process
    await Future.delayed(const Duration(seconds: 3));

    setState(() => _isImporting = false);

    Navigator.pop(context);
    widget.onImportComplete(_previewCourses);

    CustomDialog.showSuccess(
      context: context,
      title: 'تم الاستيراد',
      message: 'تم استيراد ${_previewCourses.length} كورس بنجاح.',
    );
  }
}
