import 'package:flutter/material.dart';
import '../../common/services/supabase_service.dart';
import '../../common/themes/app_theme.dart';
import '../../common/widgets/custom_dialog.dart';
import '../../common/widgets/loading_widget.dart';

class PendingRegistrationsScreen extends StatefulWidget {
  const PendingRegistrationsScreen({super.key});

  @override
  State<PendingRegistrationsScreen> createState() =>
      _PendingRegistrationsScreenState();
}

class _PendingRegistrationsScreenState
    extends State<PendingRegistrationsScreen> {
  late SupabaseService _supabaseService;
  List<Map<String, dynamic>> _pendingRegistrations = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService.instance;
    _loadPendingRegistrations();
  }

  /// تحميل طلبات التسجيل المعلقة
  Future<void> _loadPendingRegistrations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _supabaseService.client
          .from('pending_registrations')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      setState(() {
        _pendingRegistrations = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      CustomDialog.showError(
        context: context,
        title: 'خطأ',
        message: 'فشل في تحميل طلبات التسجيل: ${e.toString()}',
      );
    }
  }

  /// الموافقة على طلب التسجيل
  Future<void> _approveRegistration(String registrationId) async {
    try {
      // تحديث حالة التسجيل إلى "مقبول"
      await _supabaseService.client.from('pending_registrations').update({
        'status': 'approved',
        'reviewed_by': _supabaseService.client.auth.currentUser?.id,
        'reviewed_at': DateTime.now().toIso8601String(),
      }).eq('id', registrationId);

      // تحديث حالة المستخدم إلى "مفعل"
      final registration = _pendingRegistrations
          .firstWhere((reg) => reg['id'] == registrationId);

      await _supabaseService.client.from('users').update({
        'is_active': true,
        'verification_status': 'verified',
        'approved_by': _supabaseService.client.auth.currentUser?.id,
        'approved_at': DateTime.now().toIso8601String(),
      }).eq('email', registration['email']);

      // إرسال إشعار إلى المستخدم
      await _sendNotification(
        userId: registration['user_id'],
        title: 'تمت الموافقة على حسابك',
        message:
            'مرحباً، تمت الموافقة على حسابك في منصة وصلة. يمكنك الآن تسجيل الدخول والبدء في استخدام المنصة.',
      );

      // تحديث القائمة
      _loadPendingRegistrations();

      CustomDialog.showSuccess(
        context: context,
        title: 'نجاح',
        message: 'تمت الموافقة على طلب التسجيل بنجاح',
      );
    } catch (e) {
      CustomDialog.showError(
        context: context,
        title: 'خطأ',
        message: 'فشل في الموافقة على طلب التسجيل: ${e.toString()}',
      );
    }
  }

  /// رفض طلب التسجيل
  Future<void> _rejectRegistration(String registrationId, String reason) async {
    try {
      // تحديث حالة التسجيل إلى "مرفوض"
      await _supabaseService.client.from('pending_registrations').update({
        'status': 'rejected',
        'rejection_reason': reason,
        'reviewed_by': _supabaseService.client.auth.currentUser?.id,
        'reviewed_at': DateTime.now().toIso8601String(),
      }).eq('id', registrationId);

      // تحديث حالة المستخدم إلى "مرفوض"
      final registration = _pendingRegistrations
          .firstWhere((reg) => reg['id'] == registrationId);

      await _supabaseService.client.from('users').update({
        'is_active': false,
        'verification_status': 'rejected',
        'rejection_reason': reason,
      }).eq('email', registration['email']);

      // إرسال إشعار إلى المستخدم
      await _sendNotification(
        userId: registration['user_id'],
        title: 'تم رفض طلب التسجيل',
        message: 'معذرة، تم رفض طلب التسجيل في منصة وصلة للسبب التالي: $reason',
      );

      // تحديث القائمة
      _loadPendingRegistrations();

      CustomDialog.showSuccess(
        context: context,
        title: 'نجاح',
        message: 'تم رفض طلب التسجيل بنجاح',
      );
    } catch (e) {
      CustomDialog.showError(
        context: context,
        title: 'خطأ',
        message: 'فشل في رفض طلب التسجيل: ${e.toString()}',
      );
    }
  }

  /// إرسال إشعار إلى المستخدم
  Future<void> _sendNotification({
    required String userId,
    required String title,
    required String message,
  }) async {
    try {
      await _supabaseService.client.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'message': message,
        'type': 'approval',
        'priority': 'normal',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  /// عرض مربع حوار الرفض
  void _showRejectDialog(String registrationId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('رفض طلب التسجيل'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('يرجى إدخال سبب الرفض:'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'أدخل سبب الرفض...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (reasonController.text.trim().isEmpty) {
                  CustomDialog.showError(
                    context: context,
                    title: 'خطأ',
                    message: 'يرجى إدخال سبب الرفض',
                  );
                  return;
                }
                Navigator.pop(context);
                _rejectRegistration(
                    registrationId, reasonController.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('رفض'),
            ),
          ],
        );
      },
    );
  }

  /// فلترة الطلبات حسب البحث
  List<Map<String, dynamic>> _getFilteredRegistrations() {
    if (_searchQuery.isEmpty) {
      return _pendingRegistrations;
    }

    return _pendingRegistrations.where((registration) {
      final name = registration['name'] as String? ?? '';
      final email = registration['email'] as String? ?? '';
      final institutionName = registration['institution_name'] as String? ?? '';

      return name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          institutionName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRegistrations = _getFilteredRegistrations();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('طلبات التسجيل المعلقة'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'بحث عن طلبات...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // قائمة الطلبات
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingWidget())
                : filteredRegistrations.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد طلبات تسجيل معلقة',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredRegistrations.length,
                        itemBuilder: (context, index) {
                          final registration = filteredRegistrations[index];
                          return _buildRegistrationCard(registration);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  /// بطاقة طلب التسجيل
  Widget _buildRegistrationCard(Map<String, dynamic> registration) {
    final name = registration['name'] as String? ?? 'غير محدد';
    final email = registration['email'] as String? ?? 'غير محدد';
    final phone = registration['phone'] as String? ?? 'غير محدد';
    final institutionName =
        registration['institution_name'] as String? ?? 'غير محدد';
    final licenseNumber =
        registration['institution_license'] as String? ?? 'غير محدد';
    final specialization =
        (registration['specialization'] as List?)?.join(', ') ?? 'غير محدد';
    final experienceYears = registration['experience_years'] as int? ?? 0;
    final createdAt = DateTime.parse(registration['created_at'] as String);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات أساسية
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // معلومات إضافية
            _buildInfoRow('الهاتف', phone),
            _buildInfoRow('اسم المؤسسة', institutionName),
            _buildInfoRow('رقم الترخيص', licenseNumber),
            _buildInfoRow('التخصص', specialization),
            _buildInfoRow('سنوات الخبرة',
                experienceYears > 0 ? '$experienceYears سنة' : 'غير محدد'),
            _buildInfoRow('تاريخ الطلب',
                '${createdAt.year}/${createdAt.month}/${createdAt.day}'),

            const SizedBox(height: 16),

            // أزرار الإجراءات
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _approveRegistration(registration['id'] as String),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('موافقة'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _showRejectDialog(registration['id'] as String),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('رفض'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// صف معلومات
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
