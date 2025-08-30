import 'package:flutter/material.dart';
import '../../common/themes/app_theme.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/loading_widget.dart';

class InstructorAnalyticsScreen extends StatefulWidget {
  const InstructorAnalyticsScreen({super.key});

  @override
  State<InstructorAnalyticsScreen> createState() =>
      _InstructorAnalyticsScreenState();
}

class _InstructorAnalyticsScreenState extends State<InstructorAnalyticsScreen> {
  bool _isLoading = true;
  String _selectedPeriod = 'month'; // week, month, year
  Map<String, dynamic> _analyticsData = {};

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Sample analytics data
    _analyticsData = {
      'totalRevenue': 45250.0,
      'monthlyRevenue': 12800.0,
      'totalStudents': 1847,
      'activeStudents': 1256,
      'totalCourses': 8,
      'publishedCourses': 6,
      'averageRating': 4.7,
      'totalReviews': 892,
      'completionRate': 78.5,
      'engagementRate': 84.2,
      'revenueGrowth': 23.5,
      'studentGrowth': 18.7,
      'monthlyEarnings': [
        {'month': 'يناير', 'amount': 8500},
        {'month': 'فبراير', 'amount': 9200},
        {'month': 'مارس', 'amount': 10100},
        {'month': 'أبريل', 'amount': 11800},
        {'month': 'مايو', 'amount': 12400},
        {'month': 'يونيو', 'amount': 12800},
      ],
      'topCourses': [
        {
          'title': 'تطوير تطبيقات Flutter',
          'students': 567,
          'revenue': 15800.0,
          'rating': 4.8,
          'completion': 82.5,
        },
        {
          'title': 'علوم البيانات والذكاء الاصطناعي',
          'students': 423,
          'revenue': 12300.0,
          'rating': 4.9,
          'completion': 75.2,
        },
        {
          'title': 'تطوير المواقع الإلكترونية',
          'students': 389,
          'revenue': 9800.0,
          'rating': 4.6,
          'completion': 78.8,
        },
      ],
      'studentActivity': [
        {'day': 'الأحد', 'active': 180},
        {'day': 'الاثنين', 'active': 245},
        {'day': 'الثلاثاء', 'active': 267},
        {'day': 'الأربعاء', 'active': 234},
        {'day': 'الخميس', 'active': 198},
        {'day': 'الجمعة', 'active': 156},
        {'day': 'السبت', 'active': 167},
      ],
    };

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'التحليلات والإحصائيات',
        showBackButton: false,
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'جاري تحميل التحليلات...')
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period Selector
                    _buildPeriodSelector(theme),

                    const SizedBox(height: 20),

                    // Key Metrics
                    _buildKeyMetrics(theme),

                    const SizedBox(height: 24),

                    // Revenue Chart
                    _buildRevenueChart(theme),

                    const SizedBox(height: 24),

                    // Performance Metrics
                    _buildPerformanceMetrics(theme),

                    const SizedBox(height: 24),

                    // Top Courses
                    _buildTopCourses(theme),

                    const SizedBox(height: 24),

                    // Student Activity
                    _buildStudentActivity(theme),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPeriodSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          _buildPeriodTab('أسبوع', 'week', theme),
          _buildPeriodTab('شهر', 'month', theme),
          _buildPeriodTab('سنة', 'year', theme),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String title, String value, ThemeData theme) {
    final isSelected = _selectedPeriod == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = value;
          });
          _loadAnalytics();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyMetrics(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المؤشرات الرئيسية',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildMetricCard(
              'إجمالي الإيرادات',
              '${_analyticsData['totalRevenue'].toStringAsFixed(0)} ر.س',
              Icons.account_balance_wallet,
              AppTheme.successColor,
              '+${_analyticsData['revenueGrowth']}%',
              theme,
            ),
            _buildMetricCard(
              'إجمالي الطلاب',
              '${_analyticsData['totalStudents']}',
              Icons.people,
              AppTheme.primaryColor,
              '+${_analyticsData['studentGrowth']}%',
              theme,
            ),
            _buildMetricCard(
              'معدل الإكمال',
              '${_analyticsData['completionRate']}%',
              Icons.check_circle,
              AppTheme.accentColor,
              'ممتاز',
              theme,
            ),
            _buildMetricCard(
              'التقييم العام',
              '${_analyticsData['averageRating']}',
              Icons.star,
              AppTheme.warningColor,
              '${_analyticsData['totalReviews']} تقييم',
              theme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String? change,
    ThemeData theme,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                if (change != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      change,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
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
      ),
    );
  }

  Widget _buildRevenueChart(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الإيرادات الشهرية',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_analyticsData['monthlyRevenue'].toStringAsFixed(0)} ر.س',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Simple bar chart representation
            SizedBox(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children:
                    (_analyticsData['monthlyEarnings'] as List).map((data) {
                  final maxAmount = (_analyticsData['monthlyEarnings'] as List)
                      .map((e) => e['amount'] as int)
                      .reduce((a, b) => a > b ? a : b);
                  final height = (data['amount'] / maxAmount * 120).toDouble();

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: height,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor.withOpacity(0.7),
                                  AppTheme.primaryColor,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data['month'].toString().substring(0, 3),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مؤشرات الأداء',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildProgressMetric(
              'معدل المشاركة',
              _analyticsData['engagementRate'],
              AppTheme.accentColor,
              theme,
            ),
            const SizedBox(height: 16),
            _buildProgressMetric(
              'معدل الإكمال',
              _analyticsData['completionRate'],
              AppTheme.successColor,
              theme,
            ),
            const SizedBox(height: 16),
            _buildProgressMetric(
              'رضا الطلاب',
              (_analyticsData['averageRating'] / 5 * 100),
              AppTheme.warningColor,
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressMetric(
    String title,
    double value,
    Color color,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: theme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildTopCourses(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أفضل الكورسات أداءً',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...(_analyticsData['topCourses'] as List).map((course) {
              return _buildCourseRow(course, theme);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseRow(Map<String, dynamic> course, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['title'],
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${course['students']} طالب • ${course['revenue'].toStringAsFixed(0)} ر.س',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '⭐ ${course['rating']}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.successColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentActivity(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'نشاط الطلاب الأسبوعي',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children:
                    (_analyticsData['studentActivity'] as List).map((data) {
                  final maxActive = (_analyticsData['studentActivity'] as List)
                      .map((e) => e['active'] as int)
                      .reduce((a, b) => a > b ? a : b);
                  final height = (data['active'] / maxActive * 80).toDouble();

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${data['active']}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: height,
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data['day'].toString().substring(0, 3),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
