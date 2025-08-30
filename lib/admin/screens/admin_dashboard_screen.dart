import 'package:flutter/material.dart';
import '../../common/services/supabase_service.dart';
import '../../common/themes/app_theme.dart';
import '../../common/widgets/custom_app_bar.dart';
import 'pending_registrations_screen.dart'; // إضافة شاشة طلبات التسجيل المعلقة

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late SupabaseService _supabaseService;
  int _totalUsers = 0;
  int _totalCourses = 0;
  int _totalEnrollments = 0;
  int _pendingRegistrations = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService.instance;
    _loadDashboardData();
  }

  /// تحميل بيانات لوحة التحكم
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // عدد المستخدمين
      final usersResponse =
          await _supabaseService.client.from('users').select('count()');
      _totalUsers = (usersResponse as List).length;

      // عدد الكورسات
      final coursesResponse =
          await _supabaseService.client.from('courses').select('count()');
      _totalCourses = (coursesResponse as List).length;

      // عدد التسجيلات
      final enrollmentsResponse =
          await _supabaseService.client.from('enrollments').select('count()');
      _totalEnrollments = (enrollmentsResponse as List).length;

      // عدد طلبات التسجيل المعلقة
      final pendingResponse = await _supabaseService.client
          .from('pending_registrations')
          .select('count()')
          .eq('status', 'pending');
      _pendingRegistrations = (pendingResponse as List).length;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading dashboard data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomAppBar(title: 'لوحة تحكم الإدارة'),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // إحصائيات سريعة
              _buildStatsSection(),

              const SizedBox(height: 24),

              // بطاقات الإجراءات السريعة
              _buildQuickActionsSection(),

              const SizedBox(height: 24),

              // أحدث الأنشطة
              _buildRecentActivitiesSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// قسم الإحصائيات
  Widget _buildStatsSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'الإحصائيات العامة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                          'المستخدمون', _totalUsers.toString(), Icons.people),
                      _buildStatCard(
                          'الكورسات', _totalCourses.toString(), Icons.book),
                      _buildStatCard('التسجيلات', _totalEnrollments.toString(),
                          Icons.school),
                      _buildStatCard(
                          'طلبات معلقة',
                          _pendingRegistrations.toString(),
                          Icons.pending_actions,
                          highlight: _pendingRegistrations > 0),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  /// بطاقة إحصائية
  Widget _buildStatCard(String label, String value, IconData icon,
      {bool highlight = false}) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: highlight
                ? Colors.orange.shade100
                : AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: highlight ? Colors.orange : AppTheme.primaryColor,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: highlight ? Colors.orange : AppTheme.textPrimaryColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// قسم الإجراءات السريعة
  Widget _buildQuickActionsSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الإجراءات السريعة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildActionCard('إدارة المستخدمين', Icons.people, () {
                  Navigator.pushNamed(context, '/admin/users');
                }),
                _buildActionCard('إدارة الكورسات', Icons.book, () {
                  Navigator.pushNamed(context, '/admin/courses');
                }),
                _buildActionCard('تقارير النظام', Icons.analytics, () {
                  Navigator.pushNamed(context, '/admin/reports');
                }),
                _buildActionCard('طلبات معلقة', Icons.pending_actions, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PendingRegistrationsScreen(),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// بطاقة إجراء
  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// قسم الأنشطة الأخيرة
  Widget _buildRecentActivitiesSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أحدث الأنشطة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'سيتم عرض أحدث الأنشطة هنا',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
