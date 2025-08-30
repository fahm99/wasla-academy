import 'package:flutter/material.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/custom_dialog.dart';
import '../../common/themes/app_theme.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Platform Settings
  bool _allowRegistration = true;
  bool _requireEmailVerification = true;
  bool _enableNotifications = true;
  bool _enableMaintenance = false;
  
  // Payment Settings
  bool _enablePayments = true;
  double _platformCommission = 15.0;
  String _currency = 'SAR';
  
  // Content Settings
  bool _autoApproveCourses = false;
  bool _allowCourseDownloads = true;
  int _maxVideoSize = 500; // MB

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
        title: 'إعدادات المنصة',
        actions: [
          IconButton(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'عام'),
            Tab(text: 'المدفوعات'),
            Tab(text: 'المحتوى'),
            Tab(text: 'الأمان'),
          ],
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: AppTheme.primaryColor,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralSettings(theme),
          _buildPaymentSettings(theme),
          _buildContentSettings(theme),
          _buildSecuritySettings(theme),
        ],
      ),
    );
  }

  Widget _buildGeneralSettings(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإعدادات العامة',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('السماح بالتسجيل الجديد'),
                  subtitle: const Text('السماح للمستخدمين الجدد بإنشاء حسابات'),
                  value: _allowRegistration,
                  onChanged: (value) {
                    setState(() {
                      _allowRegistration = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('تأكيد البريد الإلكتروني'),
                  subtitle: const Text('طلب تأكيد البريد الإلكتروني عند التسجيل'),
                  value: _requireEmailVerification,
                  onChanged: (value) {
                    setState(() {
                      _requireEmailVerification = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('تفعيل الإشعارات'),
                  subtitle: const Text('إرسال إشعارات للمستخدمين'),
                  value: _enableNotifications,
                  onChanged: (value) {
                    setState(() {
                      _enableNotifications = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('وضع الصيانة'),
                  subtitle: const Text('تفعيل وضع الصيانة للمنصة'),
                  value: _enableMaintenance,
                  onChanged: (value) {
                    setState(() {
                      _enableMaintenance = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'معلومات المنصة',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('اسم المنصة'),
                  subtitle: const Text('وصلة - منصة التعلم الإلكتروني'),
                  trailing: const Icon(Icons.edit),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('اللغة الافتراضية'),
                  subtitle: const Text('العربية'),
                  trailing: const Icon(Icons.edit),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('المنطقة الزمنية'),
                  subtitle: const Text('Asia/Riyadh'),
                  trailing: const Icon(Icons.edit),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSettings(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إعدادات المدفوعات',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('تفعيل المدفوعات'),
                  subtitle: const Text('السماح بالمدفوعات على المنصة'),
                  value: _enablePayments,
                  onChanged: (value) {
                    setState(() {
                      _enablePayments = value;
                    });
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.percent),
                  title: const Text('عمولة المنصة'),
                  subtitle: Text('${_platformCommission.toInt()}%'),
                  trailing: const Icon(Icons.edit),
                  onTap: _editCommission,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.monetization_on),
                  title: const Text('العملة'),
                  subtitle: Text(_currency),
                  trailing: const Icon(Icons.edit),
                  onTap: _selectCurrency,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'طرق الدفع',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                CheckboxListTile(
                  title: const Text('بنك الكريمي'),
                  subtitle: const Text('تحويل بنكي مباشر'),
                  value: true,
                  onChanged: (value) {},
                ),
                const Divider(height: 1),
                CheckboxListTile(
                  title: const Text('فيزا/ماستركارد'),
                  subtitle: const Text('بطاقات ائتمانية'),
                  value: true,
                  onChanged: (value) {},
                ),
                const Divider(height: 1),
                CheckboxListTile(
                  title: const Text('مدى'),
                  subtitle: const Text('بطاقات مدى السعودية'),
                  value: true,
                  onChanged: (value) {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSettings(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إعدادات المحتوى',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('الموافقة التلقائية على الكورسات'),
                  subtitle: const Text('نشر الكورسات تلقائياً دون مراجعة'),
                  value: _autoApproveCourses,
                  onChanged: (value) {
                    setState(() {
                      _autoApproveCourses = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('السماح بتحميل الكورسات'),
                  subtitle: const Text('السماح للطلاب بتحميل محتوى الكورسات'),
                  value: _allowCourseDownloads,
                  onChanged: (value) {
                    setState(() {
                      _allowCourseDownloads = value;
                    });
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.video_file),
                  title: const Text('الحد الأقصى لحجم الفيديو'),
                  subtitle: Text('$_maxVideoSize ميجابايت'),
                  trailing: const Icon(Icons.edit),
                  onTap: _editMaxVideoSize,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'قواعد المحتوى',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.rule),
                  title: const Text('سياسة المحتوى'),
                  subtitle: const Text('إدارة قواعد وسياسات المحتوى'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.report),
                  title: const Text('إدارة البلاغات'),
                  subtitle: const Text('مراجعة البلاغات المرسلة'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إعدادات الأمان',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('المصادقة الثنائية'),
                  subtitle: const Text('تفعيل المصادقة الثنائية للمديرين'),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('سياسة كلمات المرور'),
                  subtitle: const Text('تحديد متطلبات كلمات المرور'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('سجل النشاطات'),
                  subtitle: const Text('عرض سجل نشاطات المديرين'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'النسخ الاحتياطي',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('النسخ الاحتياطي التلقائي'),
                  subtitle: const Text('يومياً في 2:00 صباحاً'),
                  trailing: const Icon(Icons.edit),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cloud_download),
                  title: const Text('استعادة النسخة الاحتياطية'),
                  subtitle: const Text('استعادة البيانات من نسخة احتياطية'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editCommission() async {
    final result = await CustomDialog.showInput(
      context: context,
      title: 'تعديل عمولة المنصة',
      hintText: 'النسبة المئوية',
      initialValue: _platformCommission.toString(),
    );

    if (result != null) {
      final newCommission = double.tryParse(result);
      if (newCommission != null && newCommission >= 0 && newCommission <= 100) {
        setState(() {
          _platformCommission = newCommission;
        });
      }
    }
  }

  void _selectCurrency() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('ريال سعودي (SAR)'),
              trailing: _currency == 'SAR' ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() {
                  _currency = 'SAR';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('دولار أمريكي (USD)'),
              trailing: _currency == 'USD' ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() {
                  _currency = 'USD';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('يورو (EUR)'),
              trailing: _currency == 'EUR' ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() {
                  _currency = 'EUR';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editMaxVideoSize() async {
    final result = await CustomDialog.showInput(
      context: context,
      title: 'الحد الأقصى لحجم الفيديو',
      hintText: 'الحجم بالميجابايت',
      initialValue: _maxVideoSize.toString(),
    );

    if (result != null) {
      final newSize = int.tryParse(result);
      if (newSize != null && newSize > 0) {
        setState(() {
          _maxVideoSize = newSize;
        });
      }
    }
  }

  void _saveSettings() {
    CustomDialog.showSuccess(
      context: context,
      title: 'تم الحفظ',
      message: 'تم حفظ الإعدادات بنجاح',
    );
  }
}

