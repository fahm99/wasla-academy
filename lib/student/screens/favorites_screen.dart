import 'package:flutter/material.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/course_card.dart';
import '../../common/widgets/loading_widget.dart';
import '../../common/widgets/custom_dialog.dart';
import '../../common/themes/app_theme.dart';
import '../../common/models/course.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _isSelectionMode = false;

  List<Course> _favoriteCourses = [];
  List<Map<String, dynamic>> _favoriteInstructors = [];
  List<String> _selectedCourseIds = [];
  List<String> _selectedInstructorIds = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock favorite courses
    _favoriteCourses = [
      Course(
        id: 'fav_course_1',
        title: 'تطوير تطبيقات Flutter المتقدمة',
        description: 'تعلم تطوير تطبيقات معقدة باستخدام Flutter',
        thumbnail:
            'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=300&h=200&fit=crop',
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
        instructorId: 'instructor_1',
        instructorName: 'أحمد محمد',
        instructorAvatar:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=50&h=50&fit=crop&crop=face',
        status: CourseStatus.published,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Course(
        id: 'fav_course_2',
        title: 'تصميم واجهات المستخدم الحديثة',
        description: 'أساسيات ومتقدمات تصميم UI/UX',
        thumbnail:
            'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=300&h=200&fit=crop',
        price: 199.0,
        rating: 4.6,
        reviewsCount: 89,
        enrolledCount: 567,
        duration: 360,
        lessonsCount: 32,
        level: CourseLevel.intermediate,
        category: 'التصميم',
        tags: ['UI', 'UX', 'Design'],
        instructorId: 'instructor_2',
        instructorName: 'فاطمة علي',
        instructorAvatar:
            'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=50&h=50&fit=crop&crop=face',
        status: CourseStatus.published,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Course(
        id: 'fav_course_3',
        title: 'أساسيات علوم البيانات',
        description: 'مقدمة شاملة في علوم البيانات والتحليل',
        thumbnail:
            'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=300&h=200&fit=crop',
        price: 149.0,
        rating: 4.4,
        reviewsCount: 234,
        enrolledCount: 890,
        duration: 300,
        lessonsCount: 28,
        level: CourseLevel.beginner,
        category: 'علوم البيانات',
        tags: ['Python', 'Data Science', 'Analytics'],
        instructorId: 'instructor_3',
        instructorName: 'محمد حسن',
        instructorAvatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=50&h=50&fit=crop&crop=face',
        status: CourseStatus.published,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];

    // Mock favorite instructors
    _favoriteInstructors = [
      {
        'id': 'instructor_1',
        'name': 'أحمد محمد',
        'avatar':
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=50&h=50&fit=crop&crop=face',
        'title': 'مطور تطبيقات موبايل',
        'rating': 4.8,
        'studentsCount': 5420,
        'coursesCount': 12,
        'specialties': ['Flutter', 'React Native', 'iOS'],
        'addedAt': DateTime.now().subtract(const Duration(days: 20)),
      },
      {
        'id': 'instructor_2',
        'name': 'فاطمة علي',
        'avatar':
            'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=50&h=50&fit=crop&crop=face',
        'title': 'مصممة UI/UX',
        'rating': 4.9,
        'studentsCount': 3210,
        'coursesCount': 8,
        'specialties': ['UI Design', 'UX Research', 'Figma'],
        'addedAt': DateTime.now().subtract(const Duration(days: 35)),
      },
      {
        'id': 'instructor_3',
        'name': 'محمد حسن',
        'avatar':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=50&h=50&fit=crop&crop=face',
        'title': 'عالم بيانات',
        'rating': 4.7,
        'studentsCount': 2890,
        'coursesCount': 15,
        'specialties': ['Python', 'Machine Learning', 'Statistics'],
        'addedAt': DateTime.now().subtract(const Duration(days: 50)),
      },
    ];

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'المفضلة',
        actions: [
          if (_isSelectionMode) ...[
            TextButton(
              onPressed: _cancelSelection,
              child: const Text('إلغاء'),
            ),
          ] else ...[
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'select',
                  child: Row(
                    children: [
                      Icon(Icons.checklist),
                      SizedBox(width: 8),
                      Text('تحديد متعدد'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: Colors.red),
                      SizedBox(width: 8),
                      Text('مسح الكل', style: TextStyle(color: Colors.red)),
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
            Tab(text: 'الكورسات'),
            Tab(text: 'المدربين'),
          ],
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: AppTheme.primaryColor,
        ),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'جاري تحميل المفضلة...')
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCoursesTab(theme),
                _buildInstructorsTab(theme),
              ],
            ),
      bottomNavigationBar:
          _isSelectionMode ? _buildSelectionBottomBar(theme) : null,
    );
  }

  Widget _buildCoursesTab(ThemeData theme) {
    if (_favoriteCourses.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_border,
        title: 'لا توجد كورسات مفضلة',
        message: 'ابدأ بإضافة الكورسات التي تعجبك إلى المفضلة',
        actionText: 'تصفح الكورسات',
        onAction: () => Navigator.pushNamed(context, '/student/search'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _favoriteCourses.length,
        itemBuilder: (context, index) {
          final course = _favoriteCourses[index];
          final isSelected = _selectedCourseIds.contains(course.id);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Stack(
              children: [
                CourseCard(
                  course: course,
                  onTap: _isSelectionMode
                      ? () => _toggleCourseSelection(course.id)
                      : () => _navigateToCourse(course),
                  showFavoriteButton: !_isSelectionMode,
                  isFavorite: true,
                  onFavoriteToggle: () => _removeCourseFromFavorites(course),
                ),
                if (_isSelectionMode)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppTheme.primaryColor : Colors.white,
                        border: Border.all(
                          color:
                              isSelected ? AppTheme.primaryColor : Colors.grey,
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
      ),
    );
  }

  Widget _buildInstructorsTab(ThemeData theme) {
    if (_favoriteInstructors.isEmpty) {
      return _buildEmptyState(
        icon: Icons.person_outline,
        title: 'لا توجد مدربين مفضلين',
        message: 'ابدأ بإضافة المدربين المفضلين لديك',
        actionText: 'تصفح المدربين',
        onAction: () => Navigator.pushNamed(context, '/student/instructors'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _favoriteInstructors.length,
        itemBuilder: (context, index) {
          final instructor = _favoriteInstructors[index];
          final isSelected = _selectedInstructorIds.contains(instructor['id']);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Stack(
              children: [
                Card(
                  elevation: 2,
                  child: InkWell(
                    onTap: _isSelectionMode
                        ? () => _toggleInstructorSelection(instructor['id'])
                        : () => _navigateToInstructor(instructor),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(instructor['avatar']),
                          ),

                          const SizedBox(width: 16),

                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  instructor['name'],
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  instructor['title'],
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${instructor['rating']}',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.people,
                                      size: 16,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${instructor['studentsCount']} طالب',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: (instructor['specialties']
                                          as List<String>)
                                      .take(3)
                                      .map((specialty) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        specialty,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: AppTheme.primaryColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),

                          // Actions
                          if (!_isSelectionMode)
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      _removeInstructorFromFavorites(
                                          instructor),
                                  icon: const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                  ),
                                ),
                                Text(
                                  '${instructor['coursesCount']} كورس',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isSelectionMode)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppTheme.primaryColor : Colors.white,
                        border: Border.all(
                          color:
                              isSelected ? AppTheme.primaryColor : Colors.grey,
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
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required String actionText,
    required VoidCallback onAction,
  }) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.explore),
              label: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionBottomBar(ThemeData theme) {
    final selectedCount = _tabController.index == 0
        ? _selectedCourseIds.length
        : _selectedInstructorIds.length;

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
            'تم تحديد $selectedCount عنصر',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: selectedCount > 0 ? _selectAll : null,
            icon: const Icon(Icons.select_all),
            label: const Text('تحديد الكل'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: selectedCount > 0 ? _removeSelected : null,
            icon: const Icon(Icons.delete),
            label: const Text('إزالة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'select':
        setState(() {
          _isSelectionMode = true;
        });
        break;
      case 'clear_all':
        _clearAllFavorites();
        break;
    }
  }

  void _cancelSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedCourseIds.clear();
      _selectedInstructorIds.clear();
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

  void _toggleInstructorSelection(String instructorId) {
    setState(() {
      if (_selectedInstructorIds.contains(instructorId)) {
        _selectedInstructorIds.remove(instructorId);
      } else {
        _selectedInstructorIds.add(instructorId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_tabController.index == 0) {
        _selectedCourseIds = _favoriteCourses.map((c) => c.id).toList();
      } else {
        _selectedInstructorIds =
            _favoriteInstructors.map((i) => i['id'] as String).toList();
      }
    });
  }

  void _removeSelected() async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'إزالة من المفضلة',
      message: 'هل تريد إزالة العناصر المحددة من المفضلة؟',
      confirmText: 'إزالة',
      cancelText: 'إلغاء',
    );

    if (confirmed == true) {
      setState(() {
        if (_tabController.index == 0) {
          _favoriteCourses
              .removeWhere((course) => _selectedCourseIds.contains(course.id));
          _selectedCourseIds.clear();
        } else {
          _favoriteInstructors.removeWhere((instructor) =>
              _selectedInstructorIds.contains(instructor['id']));
          _selectedInstructorIds.clear();
        }
        _isSelectionMode = false;
      });

      CustomDialog.showSuccess(
        context: context,
        title: 'تم الإزالة',
        message: 'تم إزالة العناصر المحددة من المفضلة',
      );
    }
  }

  void _clearAllFavorites() async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'مسح جميع المفضلة',
      message:
          'هل تريد مسح جميع العناصر من المفضلة؟ لا يمكن التراجع عن هذا الإجراء.',
      confirmText: 'مسح الكل',
      cancelText: 'إلغاء',
    );

    if (confirmed == true) {
      setState(() {
        _favoriteCourses.clear();
        _favoriteInstructors.clear();
        _selectedCourseIds.clear();
        _selectedInstructorIds.clear();
        _isSelectionMode = false;
      });

      CustomDialog.showSuccess(
        context: context,
        title: 'تم المسح',
        message: 'تم مسح جميع العناصر من المفضلة',
      );
    }
  }

  void _removeCourseFromFavorites(Course course) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'إزالة من المفضلة',
      message: 'هل تريد إزالة "${course.title}" من المفضلة؟',
      confirmText: 'إزالة',
      cancelText: 'إلغاء',
    );

    if (confirmed == true) {
      setState(() {
        _favoriteCourses.removeWhere((c) => c.id == course.id);
      });

      CustomDialog.showSuccess(
        context: context,
        title: 'تم الإزالة',
        message: 'تم إزالة الكورس من المفضلة',
      );
    }
  }

  void _removeInstructorFromFavorites(Map<String, dynamic> instructor) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'إزالة من المفضلة',
      message: 'هل تريد إزالة "${instructor['name']}" من المفضلة؟',
      confirmText: 'إزالة',
      cancelText: 'إلغاء',
    );

    if (confirmed == true) {
      setState(() {
        _favoriteInstructors.removeWhere((i) => i['id'] == instructor['id']);
      });

      CustomDialog.showSuccess(
        context: context,
        title: 'تم الإزالة',
        message: 'تم إزالة المدرب من المفضلة',
      );
    }
  }

  void _navigateToCourse(Course course) {
    Navigator.pushNamed(
      context,
      '/student/course-details',
      arguments: course,
    );
  }

  void _navigateToInstructor(Map<String, dynamic> instructor) {
    Navigator.pushNamed(
      context,
      '/student/instructor-profile',
      arguments: instructor,
    );
  }
}
