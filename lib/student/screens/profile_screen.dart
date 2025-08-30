import 'package:flutter/material.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/loading_widget.dart';
import '../../common/widgets/custom_dialog.dart';
import '../../common/themes/app_theme.dart';
import '../../common/models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  bool _isEditing = false;
  User? _currentUser;
  Map<String, dynamic> _profileStats = {};

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock data
    _currentUser = User(
      id: '1',
      name: 'أحمد محمد علي',
      email: 'ahmed@example.com',
      avatar:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
      role: UserRole.student,
      phone: '+966501234567',
      bio: 'طالب مهتم بتطوير التطبيقات والتقنيات الحديثة',
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      lastLoginAt: DateTime.now().subtract(const Duration(minutes: 5)),
    );

    _profileStats = {
      'enrolledCourses': 8,
      'completedCourses': 3,
      'certificatesEarned': 2,
      'totalWatchTime': 45.5, // hours
      'currentStreak': 7, // days
      'totalPoints': 1250,
      'achievements': [
        {
          'title': 'المبتدئ المتحمس',
          'description': 'أكمل أول كورس',
          'icon': Icons.star,
          'color': Colors.amber,
          'earnedAt': DateTime.now().subtract(const Duration(days: 90)),
        },
        {
          'title': 'المتعلم المثابر',
          'description': 'تعلم لمدة 7 أيام متتالية',
          'icon': Icons.local_fire_department,
          'color': Colors.orange,
          'earnedAt': DateTime.now().subtract(const Duration(days: 1)),
        },
      ],
      'recentActivity': [
        {
          'type': 'course_completed',
          'title': 'أكمل كورس تطوير تطبيقات الموبايل',
          'date': DateTime.now().subtract(const Duration(days: 2)),
        },
        {
          'type': 'certificate_earned',
          'title': 'حصل على شهادة في Flutter',
          'date': DateTime.now().subtract(const Duration(days: 5)),
        },
        {
          'type': 'course_enrolled',
          'title': 'انضم إلى كورس علوم البيانات',
          'date': DateTime.now().subtract(const Duration(days: 10)),
        },
      ],
    };

    // Fill form controllers
    _nameController.text = _currentUser!.name;
    _emailController.text = _currentUser!.email;
    _phoneController.text = _currentUser!.phone ?? '';
    _bioController.text = _currentUser!.bio ?? '';

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'جاري تحميل الملف الشخصي...'),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'الملف الشخصي',
        actions: [
          IconButton(
            onPressed: _toggleEdit,
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(theme),

              const SizedBox(height: 24),

              if (_isEditing) ...[
                // Edit Form
                _buildEditForm(theme),
              ] else ...[
                // Stats Cards
                _buildStatsCards(theme),

                const SizedBox(height: 24),

                // Achievements
                _buildAchievements(theme),

                const SizedBox(height: 24),

                // Recent Activity
                _buildRecentActivity(theme),

                const SizedBox(height: 24),

                // Settings Options
                _buildSettingsOptions(theme),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _isEditing ? _buildEditBottomBar(theme) : null,
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: _currentUser!.avatar != null
                    ? NetworkImage(_currentUser!.avatar!)
                    : null,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: _currentUser!.avatar == null
                    ? Text(
                        _currentUser!.name.isNotEmpty
                            ? _currentUser!.name[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppTheme.primaryColor, width: 2),
                    ),
                    child: IconButton(
                      onPressed: _changeAvatar,
                      icon: const Icon(
                        Icons.camera_alt,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Name and Email
          Text(
            _currentUser!.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _currentUser!.email,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Member Since
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'عضو منذ ${_formatDate(_currentUser!.createdAt)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تعديل المعلومات الشخصية',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Name Field
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'الاسم الكامل',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال الاسم';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email Field
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'البريد الإلكتروني',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال البريد الإلكتروني';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'يرجى إدخال بريد إلكتروني صحيح';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Phone Field
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          // Bio Field
          TextFormField(
            controller: _bioController,
            decoration: const InputDecoration(
              labelText: 'نبذة شخصية',
              prefixIcon: Icon(Icons.info),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            maxLength: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(ThemeData theme) {
    final stats = [
      {
        'title': 'الكورسات المسجلة',
        'value': '${_profileStats['enrolledCourses']}',
        'icon': Icons.book,
        'color': AppTheme.primaryColor,
      },
      {
        'title': 'الكورسات المكتملة',
        'value': '${_profileStats['completedCourses']}',
        'icon': Icons.check_circle,
        'color': AppTheme.successColor,
      },
      {
        'title': 'الشهادات المكتسبة',
        'value': '${_profileStats['certificatesEarned']}',
        'icon': Icons.workspace_premium,
        'color': AppTheme.warningColor,
      },
      {
        'title': 'ساعات المشاهدة',
        'value': '${_profileStats['totalWatchTime']}',
        'icon': Icons.access_time,
        'color': AppTheme.accentColor,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إحصائياتي',
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
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    const SizedBox(height: 8),
                    Text(
                      stat['value'] as String,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: stat['color'] as Color,
                      ),
                    ),
                    Text(
                      stat['title'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAchievements(ThemeData theme) {
    final achievements = _profileStats['achievements'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الإنجازات',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: _viewAllAchievements,
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return Container(
                width: 200,
                margin: EdgeInsets.only(
                  left: index == achievements.length - 1 ? 0 : 12,
                ),
                child: Card(
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
                                color: (achievement['color'] as Color)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                achievement['icon'] as IconData,
                                color: achievement['color'] as Color,
                                size: 20,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatDate(achievement['earnedAt']),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          achievement['title'],
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          achievement['description'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
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
        ),
      ],
    );
  }

  Widget _buildRecentActivity(ThemeData theme) {
    final activities = _profileStats['recentActivity'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'النشاط الأخير',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getActivityColor(activity['type']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getActivityIcon(activity['type']),
                    color: _getActivityColor(activity['type']),
                    size: 20,
                  ),
                ),
                title: Text(
                  activity['title'],
                  style: theme.textTheme.bodyMedium,
                ),
                subtitle: Text(
                  _formatDate(activity['date']),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingsOptions(ThemeData theme) {
    final options = [
      {
        'title': 'تغيير كلمة المرور',
        'icon': Icons.lock,
        'onTap': _changePassword,
      },
      {
        'title': 'إعدادات الإشعارات',
        'icon': Icons.notifications,
        'onTap': _notificationSettings,
      },
      {
        'title': 'الخصوصية والأمان',
        'icon': Icons.security,
        'onTap': _privacySettings,
      },
      {
        'title': 'مساعدة ودعم',
        'icon': Icons.help,
        'onTap': _helpSupport,
      },
      {
        'title': 'تسجيل الخروج',
        'icon': Icons.logout,
        'onTap': _logout,
        'isDestructive': true,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإعدادات',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: options.map((option) {
              final isLast = option == options.last;
              final isDestructive = option['isDestructive'] == true;

              return ListTile(
                leading: Icon(
                  option['icon'] as IconData,
                  color: isDestructive ? Colors.red : null,
                ),
                title: Text(
                  option['title'] as String,
                  style: TextStyle(
                    color: isDestructive ? Colors.red : null,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: option['onTap'] as VoidCallback,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEditBottomBar(ThemeData theme) {
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
          Expanded(
            child: OutlinedButton(
              onPressed: _cancelEdit,
              child: const Text('إلغاء'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('حفظ'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'اليوم';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else if (difference.inDays < 30) {
      return 'منذ ${(difference.inDays / 7).floor()} أسابيع';
    } else if (difference.inDays < 365) {
      return 'منذ ${(difference.inDays / 30).floor()} أشهر';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'course_completed':
        return Icons.check_circle;
      case 'certificate_earned':
        return Icons.workspace_premium;
      case 'course_enrolled':
        return Icons.book;
      default:
        return Icons.info;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'course_completed':
        return AppTheme.successColor;
      case 'certificate_earned':
        return AppTheme.warningColor;
      case 'course_enrolled':
        return AppTheme.primaryColor;
      default:
        return Colors.grey;
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _changeAvatar() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'تغيير الصورة الشخصية',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAvatarOption(
                  Icons.camera_alt,
                  'الكاميرا',
                  AppTheme.primaryColor,
                  () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
                _buildAvatarOption(
                  Icons.photo_library,
                  'المعرض',
                  AppTheme.accentColor,
                  () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                ),
                _buildAvatarOption(
                  Icons.person,
                  'افتراضي',
                  Colors.grey,
                  () {
                    Navigator.pop(context);
                    _useDefaultAvatar();
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Current avatar preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: _currentUser?.avatar != null
                        ? NetworkImage(_currentUser!.avatar!)
                        : null,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: _currentUser?.avatar == null
                        ? const Icon(
                            Icons.person,
                            color: AppTheme.primaryColor,
                            size: 30,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الصورة الحالية',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          _currentUser?.avatar != null
                              ? 'صورة مخصصة'
                              : 'صورة افتراضية',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  if (_currentUser?.avatar != null)
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _removeAvatar();
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarOption(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _pickImageFromCamera() {
    CustomDialog.show(
      context: context,
      type: DialogType.info,
      title: 'فتح الكاميرا',
      message: 'سيتم فتح الكاميرا لالتقاط صورة جديدة...',
    );
    // TODO: Implement camera image picker
    // Example: Use image_picker package
    // final ImagePicker picker = ImagePicker();
    // final XFile? image = await picker.pickImage(source: ImageSource.camera);
  }

  void _pickImageFromGallery() {
    CustomDialog.show(
      context: context,
      type: DialogType.info,
      title: 'فتح المعرض',
      message: 'سيتم فتح معرض الصور لاختيار صورة...',
    );
    // TODO: Implement gallery image picker
    // Example: Use image_picker package
    // final ImagePicker picker = ImagePicker();
    // final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  }

  void _useDefaultAvatar() {
    setState(() {
      _currentUser = _currentUser!.copyWith(
        avatar: null, // Remove custom avatar to use default
      );
    });

    CustomDialog.showSuccess(
      context: context,
      title: 'تم التغيير',
      message: 'تم تعيين الصورة الافتراضية',
    );
  }

  void _removeAvatar() async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'حذف الصورة',
      message: 'هل تريد حذف الصورة الشخصية؟',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
    );

    if (confirmed == true) {
      setState(() {
        _currentUser = _currentUser!.copyWith(
          avatar: null,
        );
      });

      CustomDialog.showSuccess(
        context: context,
        title: 'تم الحذف',
        message: 'تم حذف الصورة الشخصية',
      );
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      // Reset form
      _nameController.text = _currentUser!.name;
      _emailController.text = _currentUser!.email;
      _phoneController.text = _currentUser!.phone ?? '';
      _bioController.text = _currentUser!.bio ?? '';
    });
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Update user data
      setState(() {
        _currentUser = _currentUser!.copyWith(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text.isEmpty ? null : _phoneController.text,
          bio: _bioController.text.isEmpty ? null : _bioController.text,
        );
        _isEditing = false;
        _isLoading = false;
      });

      CustomDialog.showSuccess(
        context: context,
        title: 'تم الحفظ',
        message: 'تم تحديث الملف الشخصي بنجاح',
      );
    }
  }

  void _viewAllAchievements() {
    Navigator.pushNamed(context, '/student/achievements');
  }

  void _changePassword() {
    Navigator.pushNamed(context, '/student/change-password');
  }

  void _notificationSettings() {
    Navigator.pushNamed(context, '/student/notification-settings');
  }

  void _privacySettings() {
    Navigator.pushNamed(context, '/student/privacy-settings');
  }

  void _helpSupport() {
    Navigator.pushNamed(context, '/student/help-support');
  }

  void _logout() async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'تسجيل الخروج',
      message: 'هل تريد تسجيل الخروج من حسابك؟',
      confirmText: 'تسجيل الخروج',
      cancelText: 'إلغاء',
    );

    if (confirmed == true) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }
}
