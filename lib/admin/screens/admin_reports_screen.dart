import 'package:flutter/material.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/themes/app_theme.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'التقارير والتحليلات',
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.download),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'المالية'),
            Tab(text: 'المستخدمين'),
            Tab(text: 'الكورسات'),
            Tab(text: 'الأداء'),
          ],
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: AppTheme.primaryColor,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFinancialReports(theme),
          _buildUserReports(theme),
          _buildCourseReports(theme),
          _buildPerformanceReports(theme),
        ],
      ),
    );
  }

  Widget _buildFinancialReports(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التقارير المالية',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Revenue cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildMetricCard('الإيرادات الشهرية', '125,450 ر.س',
                  Icons.trending_up, AppTheme.successColor, theme),
              _buildMetricCard('إجمالي المبيعات', '2,340,000 ر.س',
                  Icons.attach_money, AppTheme.primaryColor, theme),
              _buildMetricCard('عمولة المنصة', '234,000 ر.س',
                  Icons.account_balance, AppTheme.accentColor, theme),
              _buildMetricCard('الأرباح الصافية', '1,890,000 ر.س',
                  Icons.savings, AppTheme.warningColor, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserReports(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تقارير المستخدمين',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildMetricCard('إجمالي المستخدمين', '15,420', Icons.people,
                  AppTheme.primaryColor, theme),
              _buildMetricCard('المستخدمين النشطين', '12,340',
                  Icons.person_outline, AppTheme.successColor, theme),
              _buildMetricCard(
                  'المدربين', '234', Icons.school, AppTheme.accentColor, theme),
              _buildMetricCard('الطلاب', '15,186', Icons.person,
                  AppTheme.warningColor, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseReports(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تقارير الكورسات',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildMetricCard('إجمالي الكورسات', '1,234', Icons.library_books,
                  AppTheme.primaryColor, theme),
              _buildMetricCard('الكورسات النشطة', '987', Icons.play_circle,
                  AppTheme.successColor, theme),
              _buildMetricCard('إجمالي التسجيلات', '45,678', Icons.how_to_reg,
                  AppTheme.accentColor, theme),
              _buildMetricCard('معدل الإكمال', '78%', Icons.check_circle,
                  AppTheme.warningColor, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceReports(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تقارير الأداء',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildMetricCard('متوسط التقييم', '4.6', Icons.star,
                  AppTheme.primaryColor, theme),
              _buildMetricCard('وقت المشاهدة', '234,567 ساعة',
                  Icons.access_time, AppTheme.successColor, theme),
              _buildMetricCard('معدل الرضا', '92%', Icons.sentiment_satisfied,
                  AppTheme.accentColor, theme),
              _buildMetricCard('معدل الاستبقاء', '85%', Icons.trending_up,
                  AppTheme.warningColor, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color, ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
