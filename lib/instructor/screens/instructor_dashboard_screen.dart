import 'package:flutter/material.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/loading_widget.dart';
import '../../common/themes/app_theme.dart';

class InstructorDashboardScreen extends StatefulWidget {
  const InstructorDashboardScreen({super.key});

  @override
  State<InstructorDashboardScreen> createState() => _InstructorDashboardScreenState();
}

class _InstructorDashboardScreenState extends State<InstructorDashboardScreen> {
  bool _isLoading = false;
  Map<String, dynamic> _dashboardData = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock data
    _dashboardData = {
      'totalCourses': 12,
      'totalStudents': 347,
      'totalRevenue': 15420.50,
      'averageRating': 4.7,
      'recentEnrollments': 23,
      'completionRate': 78.5,
      'monthlyRevenue': [
        {'month': 'يناير', 'revenue': 2500},
        {'month': 'فبراير', 'revenue': 3200},
        {'month': 'مارس', 'revenue': 2800},
        {'month': 'أبريل', 'revenue': 3500},
        {'month': 'مايو', 'revenue': 3420},
      ],
      'topCourses': [
        {
          'title': 'تطوير تطبيقات الموبايل',
          'students': 89,
          'revenue': 4500,
          'rating': 4.8,
        },
        {
          'title': 'علوم البيانات والذكاء الاصطناعي',
          'students': 67,
          'revenue': 3800,
          'rating': 4.9,
        },
        {
          'title': 'تطوير المواقع الإلكترونية',
          'students': 124,
          'revenue': 5200,
          'rating': 4.6,
        },
      ],
    };
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const WaslaAppBar(
        title: 'لوحة المعلومات',
        userName: 'د. محمد أحمد',
        userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=40&h=40&fit=crop&crop=face',
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
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
                    
                    // Statistics Cards
                    _buildStatisticsCards(theme),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    _buildQuickActions(theme),
                    
                    const SizedBox(height: 24),
                    
                    // Revenue Chart
                    _buildRevenueChart(theme),
                    
                    const SizedBox(height: 24),
                    
                    // Top Courses
                    _buildTopCourses(theme),
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً د. محمد أحمد',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'إليك ملخص أداء كورساتك اليوم',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildWelcomeStatItem('${_dashboardData['totalCourses']}', 'كورس نشط', theme),
              const SizedBox(width: 24),
              _buildWelcomeStatItem('${_dashboardData['totalStudents']}', 'طالب مسجل', theme),
              const SizedBox(width: 24),
              _buildWelcomeStatItem('${_dashboardData['averageRating']}', 'متوسط التقييم', theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStatItem(String value, String label, ThemeData theme) {
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

  Widget _buildStatisticsCards(ThemeData theme) {
    final stats = [
      {
        'title': 'إجمالي الإيرادات',
        'value': '${_dashboardData['totalRevenue']} ر.س',
        'icon': Icons.attach_money,
        'color': AppTheme.successColor,
        'change': '+12.5%',
      },
      {
        'title': 'التسجيلات الحديثة',
        'value': '${_dashboardData['recentEnrollments']}',
        'icon': Icons.person_add,
        'color': AppTheme.primaryColor,
        'change': '+8.2%',
      },
      {
        'title': 'معدل الإكمال',
        'value': '${_dashboardData['completionRate']}%',
        'icon': Icons.check_circle,
        'color': AppTheme.accentColor,
        'change': '+5.1%',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 4,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (stat['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    stat['icon'] as IconData,
                    color: stat['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        stat['title'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stat['value'] as String,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    stat['change'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    final actions = [
      {
        'title': 'إنشاء كورس جديد',
        'icon': Icons.add_circle,
        'color': AppTheme.primaryColor,
        'onTap': () {
          // Navigate to create course
        },
      },
      {
        'title': 'إدارة الطلاب',
        'icon': Icons.people,
        'color': AppTheme.accentColor,
        'onTap': () {
          // Navigate to students management
        },
      },
      {
        'title': 'التحليلات المفصلة',
        'icon': Icons.analytics,
        'color': AppTheme.warningColor,
        'onTap': () {
          // Navigate to analytics
        },
      },
      {
        'title': 'الرسائل',
        'icon': Icons.message,
        'color': AppTheme.successColor,
        'onTap': () {
          // Navigate to messages
        },
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإجراءات السريعة',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return Card(
              elevation: 2,
              child: InkWell(
                onTap: action['onTap'] as VoidCallback,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: (action['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          action['icon'] as IconData,
                          color: action['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action['title'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRevenueChart(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الإيرادات الشهرية',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to detailed analytics
                  },
                  child: const Text('عرض التفاصيل'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'رسم بياني للإيرادات الشهرية\n(يتطلب مكتبة charts)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCourses(ThemeData theme) {
    final topCourses = _dashboardData['topCourses'] as List;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'أفضل الكورسات أداءً',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all courses
                  },
                  child: const Text('عرض الكل'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topCourses.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final course = topCourses[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.accentColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    course['title'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text('${course['students']} طالب'),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text('${course['rating']}'),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${course['revenue']} ر.س',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successColor,
                        ),
                      ),
                      Text(
                        'الإيرادات',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

