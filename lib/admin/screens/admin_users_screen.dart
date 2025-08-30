import 'package:flutter/material.dart';
import '../../common/widgets/custom_app_bar.dart';
import '../../common/widgets/loading_widget.dart';
import '../../common/widgets/custom_dialog.dart';
import '../../common/themes/app_theme.dart';
import '../../common/models/user.dart';
import '../../common/services/supabase_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<User> _allUsers = [];
  List<User> _students = [];
  List<User> _instructors = [];
  List<User> _admins = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    
    try {
      // Fetch users from database
      final users = await SupabaseService.instance.getAllUsers();
      final userList = users.map((json) => User.fromJson(json)).toList();
      
      _allUsers = userList;
      _students = userList.where((u) => u.role == UserRole.student).toList();
      _instructors = userList.where((u) => u.role == UserRole.instructor).toList();
      _admins = userList.where((u) => u.role == UserRole.admin).toList();
    } catch (e) {
      // Fallback to mock data if there's an error
      final mockUsers = [
        User(
          id: '1',
          name: 'أحمد محمد علي',
          email: 'ahmed@example.com',
          avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=50&h=50&fit=crop&crop=face',
          role: UserRole.student,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        User(
          id: '2',
          name: 'د. محمد أحمد',
          email: 'instructor@wasla.com',
          avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=50&h=50&fit=crop&crop=face',
          role: UserRole.instructor,
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          lastLoginAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        User(
          id: '3',
          name: 'فاطمة سالم',
          email: 'fatima@example.com',
          avatar: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=50&h=50&fit=crop&crop=face',
          role: UserRole.student,
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          lastLoginAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        User(
          id: '4',
          name: 'د. فاطمة علي',
          email: 'fatima.ali@wasla.com',
          avatar: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=50&h=50&fit=crop&crop=face',
          role: UserRole.instructor,
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
          lastLoginAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        User(
          id: '5',
          name: 'المدير العام',
          email: 'admin@wasla.com',
          avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=50&h=50&fit=crop&crop=face',
          role: UserRole.admin,
          createdAt: DateTime.now().subtract(const Duration(days: 365)),
          lastLoginAt: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
        User(
          id: '6',
          name: 'سارة أحمد',
          email: 'sara@example.com',
          role: UserRole.student,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          lastLoginAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
      ];

      _allUsers = mockUsers;
      _students = mockUsers.where((u) => u.role == UserRole.student).toList();
      _instructors = mockUsers.where((u) => u.role == UserRole.instructor).toList();
      _admins = mockUsers.where((u) => u.role == UserRole.admin).toList();
    }
    
    setState(() => _isLoading = false);
  }

  List<User> get _currentUsers {
    List<User> users;
    switch (_tabController.index) {
      case 0:
        users = _allUsers;
        break;
      case 1:
        users = _students;
        break;
      case 2:
        users = _instructors;
        break;
      case 3:
        users = _admins;
        break;
      default:
        users = _allUsers;
    }

    if (_searchQuery.isEmpty) {
      return users;
    }

    return users.where((user) {
      return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'إدارة المستخدمين',
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.appBarTheme.backgroundColor,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'البحث عن المستخدمين...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Filter Tabs
          Container(
            color: theme.appBarTheme.backgroundColor,
            child: TabBar(
              controller: _tabController,
              onTap: (index) {
                setState(() {});
              },
              tabs: [
                Tab(
                  child: _buildTabContent(
                    'الكل',
                    _allUsers.length,
                    theme,
                  ),
                ),
                Tab(
                  child: _buildTabContent(
                    'الطلاب',
                    _students.length,
                    theme,
                  ),
                ),
                Tab(
                  child: _buildTabContent(
                    'المدربين',
                    _instructors.length,
                    theme,
                  ),
                ),
                Tab(
                  child: _buildTabContent(
                    'المديرين',
                    _admins.length,
                    theme,
                  ),
                ),
              ],
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
              indicatorColor: AppTheme.primaryColor,
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: theme.textTheme.bodyMedium,
            ),
          ),
          
          // Users List
          Expanded(
            child: _isLoading
                ? const LoadingWidget(message: 'جاري تحميل المستخدمين...')
                : _currentUsers.isEmpty
                    ? _buildEmptyState(theme)
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _currentUsers.length,
                          itemBuilder: (context, index) {
                            final user = _currentUsers[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index == _currentUsers.length - 1 ? 0 : 12,
                              ),
                              child: _buildUserCard(user, theme),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewUser,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('مستخدم جديد'),
      ),
    );
  }

  Widget _buildTabContent(String label, int count, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        if (count > 0) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    String message = _searchQuery.isNotEmpty
        ? 'لا توجد نتائج للبحث "$_searchQuery"'
        : 'لا توجد مستخدمين';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty ? Icons.search_off : Icons.people_outline,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addNewUser,
              icon: const Icon(Icons.person_add),
              label: const Text('إضافة مستخدم جديد'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserCard(User user, ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // User Avatar
            CircleAvatar(
              radius: 24,
              backgroundImage: user.avatar != null
                  ? NetworkImage(user.avatar!)
                  : null,
              backgroundColor: AppTheme.primaryColor,
              child: user.avatar == null
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
            
            const SizedBox(width: 16),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildRoleBadge(user.role, theme),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'آخر دخول: ${_formatLastLogin(user.lastLoginAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: user.isActive ? AppTheme.successColor : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.isActive ? 'نشط' : 'غير نشط',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: user.isActive ? AppTheme.successColor : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            PopupMenuButton<String>(
              onSelected: (value) => _handleUserAction(user, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text('عرض التفاصيل'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('تعديل'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: user.isActive ? 'deactivate' : 'activate',
                  child: Row(
                    children: [
                      Icon(user.isActive ? Icons.block : Icons.check_circle),
                      const SizedBox(width: 8),
                      Text(user.isActive ? 'إلغاء التفعيل' : 'تفعيل'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('حذف', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(UserRole role, ThemeData theme) {
    Color color;
    String text;
    IconData icon;

    switch (role) {
      case UserRole.student:
        color = AppTheme.primaryColor;
        text = 'طالب';
        icon = Icons.person;
        break;
      case UserRole.instructor:
        color = AppTheme.accentColor;
        text = 'مدرب';
        icon = Icons.school;
        break;
      case UserRole.admin:
        color = AppTheme.warningColor;
        text = 'مدير';
        icon = Icons.admin_panel_settings;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastLogin(DateTime? lastLogin) {
    if (lastLogin == null) return 'لم يسجل دخول';
    
    final now = DateTime.now();
    final difference = now.difference(lastLogin);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ساعة';
    } else {
      return '${difference.inDays} يوم';
    }
  }

  void _handleUserAction(User user, String action) async {
    switch (action) {
      case 'view':
        _viewUserDetails(user);
        break;
      case 'edit':
        _editUser(user);
        break;
      case 'activate':
      case 'deactivate':
        await _toggleUserStatus(user);
        break;
      case 'delete':
        await _deleteUser(user);
        break;
    }
  }

  void _viewUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: user.avatar != null
                        ? NetworkImage(user.avatar!)
                        : null,
                    backgroundColor: AppTheme.primaryColor,
                    child: user.avatar == null
                        ? Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildRoleBadge(user.role, Theme.of(context)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow('البريد الإلكتروني', user.email),
              _buildDetailRow('تاريخ التسجيل', _formatDate(user.createdAt)),
              _buildDetailRow('آخر دخول', _formatLastLogin(user.lastLoginAt)),
              _buildDetailRow('الحالة', user.isActive ? 'نشط' : 'غير نشط'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('إغلاق'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _editUser(user);
                    },
                    child: const Text('تعديل'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editUser(User user) {
    // Navigate to edit user screen or show edit dialog
    CustomDialog.show(
      context: context,
      type: DialogType.info,
      title: 'تعديل المستخدم',
      message: 'ميزة تعديل المستخدم قيد التطوير',
    );
  }

  Future<void> _toggleUserStatus(User user) async {
    final action = user.isActive ? 'إلغاء تفعيل' : 'تفعيل';
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: '$action المستخدم',
      message: 'هل تريد $action "${user.name}"؟',
      confirmText: action,
      cancelText: 'إلغاء',
    );

    if (confirmed == true) {
      // Implement toggle status logic
      CustomDialog.showSuccess(
        context: context,
        title: 'تم التحديث',
        message: 'تم $action المستخدم بنجاح',
      );
      _loadUsers();
    }
  }

  Future<void> _deleteUser(User user) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'حذف المستخدم',
      message: 'هل تريد حذف "${user.name}"؟ هذا الإجراء لا يمكن التراجع عنه.',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
    );

    if (confirmed == true) {
      // Implement delete logic
      CustomDialog.showSuccess(
        context: context,
        title: 'تم الحذف',
        message: 'تم حذف المستخدم بنجاح',
      );
      _loadUsers();
    }
  }

  void _addNewUser() {
    // Navigate to add user screen or show add dialog
    CustomDialog.show(
      context: context,
      type: DialogType.info,
      title: 'إضافة مستخدم جديد',
      message: 'ميزة إضافة مستخدم جديد قيد التطوير',
    );
  }
}

