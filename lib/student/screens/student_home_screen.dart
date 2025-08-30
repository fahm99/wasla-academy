import 'package:flutter/material.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/course_card.dart';
import '../../common/widgets/loading_widget.dart';
import '../../common/themes/app_theme.dart';
import '../../common/models/course.dart';
import '../../common/services/supabase_service.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  bool _isLoading = false;
  List<Course> _featuredCourses = [];
  List<Course> _myCourses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Fetch data from database
      final featuredCourses =
          await SupabaseService.instance.getFeaturedCourses();
      final myCoursesData = await SupabaseService.instance
          .getStudentCoursesWithProgress(
              'student_id'); // Replace with actual student ID

      _featuredCourses =
          featuredCourses.map((json) => Course.fromJson(json)).toList();
      _myCourses = myCoursesData.map((json) => Course.fromJson(json)).toList();
    } catch (e) {
      // Fallback to mock data if there's an error
      _featuredCourses = [
        Course(
          id: '1',
          title: 'تطوير تطبيقات الموبايل',
          description: 'تعلم تطوير تطبيقات الموبايل باستخدام Flutter من الصفر',
          thumbnail:
              'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400&h=200&fit=crop',
          instructorId: 'inst1',
          instructorName: 'د. محمد أحمد',
          instructorAvatar: null, // Using placeholder instead of broken URL
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
          instructorId: 'inst2',
          instructorName: 'د. فاطمة علي',
          instructorAvatar: null,
          status: CourseStatus.published,
          level: CourseLevel.intermediate,
          price: 499,
          discountPrice: 399,
          duration: 1800,
          lessonsCount: 36,
          rating: 4.9,
          reviewsCount: 89,
          enrolledCount: 567,
          category: 'علوم البيانات',
          tags: ['AI', 'Data Science', 'Python'],
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          publishedAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
      ];

      _myCourses = [
        _featuredCourses[0].copyWith(id: 'my1'),
      ];
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const WaslaAppBar(
        title: 'وصلة',
        userName: 'أحمد محمد',
        userAvatar: null, // Using placeholder instead of broken URL
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const LoadingWidget(message: 'جاري تحميل البيانات...')
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    _buildWelcomeSection(theme),

                    const SizedBox(height: 24),

                    // Quick Actions
                    _buildQuickActions(theme),

                    const SizedBox(height: 24),

                    // My Courses Section
                    if (_myCourses.isNotEmpty) ...[
                      _buildSectionHeader(
                        theme,
                        'كورساتي الحالية',
                        onViewAll: () {
                          // Navigate to my courses
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 280,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _myCourses.length,
                          itemBuilder: (context, index) {
                            final course = _myCourses[index];
                            return SizedBox(
                              width: 300,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: index == 0 ? 0 : 12,
                                ),
                                child: CourseCard(
                                  course: course,
                                  showProgress: true,
                                  progress: 65,
                                  onTap: () => _onCourseCardTap(course),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Featured Courses Section
                    _buildSectionHeader(
                      theme,
                      'الكورسات المميزة',
                      onViewAll: () {
                        // Navigate to all courses
                      },
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _featuredCourses.length,
                      itemBuilder: (context, index) {
                        final course = _featuredCourses[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom:
                                index == _featuredCourses.length - 1 ? 0 : 16,
                          ),
                          child: CourseCard(
                            course: course,
                            onTap: () => _onCourseCardTap(course),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.accentColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرحباً بك في وصلة',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ رحلتك التعليمية اليوم واكتسب مهارات جديدة',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatItem('12', 'كورس مكتمل', theme),
              const SizedBox(width: 24),
              _buildStatItem('3', 'شهادة مكتسبة', theme),
              const SizedBox(width: 24),
              _buildStatItem('85%', 'معدل الإنجاز', theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    final actions = [
      _QuickAction(
        icon: Icons.search,
        label: 'البحث عن كورسات',
        color: AppTheme.primaryColor,
        onTap: () {
          // Navigate to search
        },
      ),
      _QuickAction(
        icon: Icons.video_camera_front,
        label: 'المحاضرات المباشرة',
        color: AppTheme.accentColor,
        onTap: () {
          // Navigate to live lectures
        },
      ),
      _QuickAction(
        icon: Icons.account_balance,
        label: 'التحويل البنكي',
        color: AppTheme.warningColor,
        onTap: () {
          Navigator.pushNamed(context, '/bank-transfer');
        },
      ),
      _QuickAction(
        icon: Icons.emoji_events,
        label: 'الإنجازات',
        color: AppTheme.successColor,
        onTap: () {
          // Navigate to achievements
        },
      ),
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: Container(
                    width: 90,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: action.onTap,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    action.color.withOpacity(0.8),
                                    action.color,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: action.color.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                action.icon,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              action.label,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    ThemeData theme,
    String title, {
    VoidCallback? onViewAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: Text(
              'عرض الكل',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
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

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
