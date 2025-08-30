import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../common/models/certificate.dart';
import '../../common/models/course.dart';
import '../../common/themes/app_theme.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/loading_widget.dart';
import '../../common/widgets/custom_dialog.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  bool _isLoading = true;
  List<Certificate> _certificates = [];
  String _selectedFilter = 'all'; // all, recent, verified

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    setState(() => _isLoading = true);

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Sample certificates data
    _certificates = [
      Certificate(
        id: 'cert_1',
        userId: 'user_1',
        courseId: 'course_1',
        issuedAt: DateTime.now().subtract(const Duration(days: 30)),
        certificateUrl: 'https://certificates.wasla.edu/cert_1.pdf',
        verificationCode: 'WAS-2024-001-ABC',
        course: Course(
          id: 'course_1',
          title: 'تطوير تطبيقات الموبايل',
          description: 'تعلم بناء تطبيقات متقدمة باستخدام Flutter',
          thumbnail:
              'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=400&h=200&fit=crop',
          instructorId: 'inst_1',
          instructorName: 'د. محمد أحمد',
          status: CourseStatus.published,
          level: CourseLevel.intermediate,
          price: 299,
          duration: 1200,
          lessonsCount: 24,
          rating: 4.8,
          reviewsCount: 156,
          enrolledCount: 1234,
          category: 'تطوير التطبيقات',
          tags: ['Flutter', 'Mobile Development'],
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
          updatedAt: DateTime.now().subtract(const Duration(days: 35)),
          publishedAt: DateTime.now().subtract(const Duration(days: 85)),
        ),
      ),
      Certificate(
        id: 'cert_2',
        userId: 'user_1',
        courseId: 'course_2',
        issuedAt: DateTime.now().subtract(const Duration(days: 60)),
        certificateUrl: 'https://certificates.wasla.edu/cert_2.pdf',
        verificationCode: 'WAS-2023-002-XYZ',
        course: Course(
          id: 'course_2',
          title: 'علوم البيانات والذكاء الاصطناعي',
          description: 'اكتشف عالم البيانات وتعلم الذكاء الاصطناعي',
          thumbnail:
              'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=400&h=200&fit=crop',
          instructorId: 'inst_2',
          instructorName: 'د. فاطمة علي',
          status: CourseStatus.published,
          level: CourseLevel.advanced,
          price: 499,
          duration: 1800,
          lessonsCount: 36,
          rating: 4.9,
          reviewsCount: 89,
          enrolledCount: 567,
          category: 'علوم البيانات',
          tags: ['AI', 'Data Science', 'Python'],
          createdAt: DateTime.now().subtract(const Duration(days: 120)),
          updatedAt: DateTime.now().subtract(const Duration(days: 65)),
          publishedAt: DateTime.now().subtract(const Duration(days: 115)),
        ),
      ),
      Certificate(
        id: 'cert_3',
        userId: 'user_1',
        courseId: 'course_3',
        issuedAt: DateTime.now().subtract(const Duration(days: 15)),
        certificateUrl: 'https://certificates.wasla.edu/cert_3.pdf',
        verificationCode: 'WAS-2024-003-DEF',
        course: Course(
          id: 'course_3',
          title: 'التصميم الجرافيكي للمبتدئين',
          description: 'تعلم أساسيات التصميم الجرافيكي',
          thumbnail:
              'https://images.unsplash.com/photo-1541701494587-cb58502866ab?w=400&h=200&fit=crop',
          instructorId: 'inst_3',
          instructorName: 'أ. سارة محمود',
          status: CourseStatus.published,
          level: CourseLevel.beginner,
          price: 199,
          duration: 900,
          lessonsCount: 18,
          rating: 4.6,
          reviewsCount: 234,
          enrolledCount: 890,
          category: 'التصميم',
          tags: ['Design', 'Graphics', 'Adobe'],
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
          updatedAt: DateTime.now().subtract(const Duration(days: 20)),
          publishedAt: DateTime.now().subtract(const Duration(days: 40)),
        ),
      ),
    ];

    setState(() => _isLoading = false);
  }

  List<Certificate> get _filteredCertificates {
    switch (_selectedFilter) {
      case 'recent':
        return _certificates
            .where(
                (cert) => DateTime.now().difference(cert.issuedAt).inDays <= 30)
            .toList();
      case 'verified':
        return _certificates
            .where((cert) => cert.certificateUrl != null)
            .toList();
      default:
        return _certificates;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'شهاداتي',
        showBackButton: false,
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'جاري تحميل الشهادات...')
          : Column(
              children: [
                // Statistics Header
                _buildStatsHeader(theme),

                // Filter Tabs
                _buildFilterTabs(theme),

                // Certificates List
                Expanded(
                  child: _filteredCertificates.isEmpty
                      ? _buildEmptyState(theme)
                      : RefreshIndicator(
                          onRefresh: _loadCertificates,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredCertificates.length,
                            itemBuilder: (context, index) {
                              final certificate = _filteredCertificates[index];
                              return _buildCertificateCard(certificate, theme);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsHeader(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إنجازاتك',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'مجموع الشهادات المكتسبة',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '${_certificates.length}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'شهادة',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterTab('الكل', 'all', _certificates.length, theme),
          const SizedBox(width: 8),
          _buildFilterTab(
              'الحديثة',
              'recent',
              _certificates
                  .where((cert) =>
                      DateTime.now().difference(cert.issuedAt).inDays <= 30)
                  .length,
              theme),
          const SizedBox(width: 8),
          _buildFilterTab(
              'المتاحة',
              'verified',
              _certificates.where((cert) => cert.certificateUrl != null).length,
              theme),
        ],
      ),
    );
  }

  Widget _buildFilterTab(
      String title, String value, int count, ThemeData theme) {
    final isSelected = _selectedFilter == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color:
                isSelected ? AppTheme.primaryColor : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor
                  : theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color:
                      isSelected ? Colors.white : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '$count',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? Colors.white.withOpacity(0.9)
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertificateCard(Certificate certificate, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Course Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: certificate.course?.thumbnail != null
                      ? Image.network(
                          certificate.course!.thumbnail!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              child: const Icon(
                                Icons.workspace_premium,
                                color: AppTheme.primaryColor,
                                size: 30,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.workspace_premium,
                            color: AppTheme.primaryColor,
                            size: 30,
                          ),
                        ),
                ),

                const SizedBox(width: 12),

                // Certificate Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        certificate.course?.title ?? 'شهادة إتمام الكورس',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'تاريخ الإصدار: ${certificate.formattedDate}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'رمز التحقق: ${certificate.verificationCode}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: certificate.certificateUrl != null
                        ? AppTheme.successColor.withOpacity(0.1)
                        : AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    certificate.certificateUrl != null
                        ? 'متاحة'
                        : 'قيد المعالجة',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: certificate.certificateUrl != null
                          ? AppTheme.successColor
                          : AppTheme.warningColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _copyVerificationCode(certificate.verificationCode),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('نسخ رمز التحقق'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: certificate.certificateUrl != null
                        ? () => _downloadCertificate(certificate)
                        : null,
                    icon: Icon(
                      certificate.certificateUrl != null
                          ? Icons.download
                          : Icons.hourglass_empty,
                      size: 16,
                    ),
                    label: Text(certificate.certificateUrl != null
                        ? 'تحميل الشهادة'
                        : 'قيد المعالجة'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد شهادات',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أكمل الكورسات لتحصل على شهاداتك',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to courses
              DefaultTabController.of(context).animateTo(1);
            },
            child: const Text('تصفح الكورسات'),
          ),
        ],
      ),
    );
  }

  void _copyVerificationCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    CustomDialog.showSuccess(
      context: context,
      title: 'تم النسخ',
      message: 'تم نسخ رمز التحقق إلى الحافظة',
    );
  }

  void _downloadCertificate(Certificate certificate) {
    CustomDialog.show(
      context: context,
      type: DialogType.info,
      title: 'تحميل الشهادة',
      message:
          'سيتم تحميل الشهادة قريباً...\nرمز التحقق: ${certificate.verificationCode}',
    );
  }
}
