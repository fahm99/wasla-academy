import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasla_app/admin/screens/admin_settings_screen.dart';
import 'common/bloc/auth/auth_bloc.dart';
import 'common/bloc/payment/payment_bloc.dart';
import 'common/services/supabase_service.dart';
import 'common/services/local_storage_service.dart';
import 'common/services/payment_service_manager.dart';
import 'common/services/payment_management_service.dart'; // Add this import
import 'common/services/session_service.dart'; // إضافة خدمة الجلسات
import 'config/env_config.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'common/themes/app_theme.dart';
import 'common/screens/auth/login_screen.dart';
import 'common/screens/auth/register_screen.dart';
import 'common/screens/auth/verification_code_screen.dart';
import 'common/screens/auth/document_upload_screen.dart'; // إضافة شاشة تحميل المستندات
import 'common/screens/payment/course_payment_screen.dart'; // Add this import
import 'student/screens/student_home_screen.dart';
import 'student/screens/student_courses_screen.dart';
import 'student/screens/profile_screen.dart';
import 'instructor/screens/instructor_dashboard_screen.dart';
import 'instructor/screens/instructor_courses_screen.dart';
import 'admin/screens/admin_dashboard_screen.dart';
import 'admin/screens/admin_users_screen.dart';
import 'admin/screens/admin_courses_screen.dart';
import 'admin/screens/admin_reports_screen.dart';
import 'student/screens/certificates_screen.dart';
import 'instructor/screens/students_management_screen.dart';
import 'instructor/screens/instructor_analytics_screen.dart';
import 'common/models/user.dart'; // Import UserRole enum
import 'common/models/course.dart'; // Import Course model and enums

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة الخدمات
  await SupabaseService.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  // تهيئة خدمة الجلسات
  await SessionService().init();

  runApp(const WaslaApp());
}

class WaslaApp extends StatelessWidget {
  const WaslaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            supabaseService: SupabaseService.instance,
            localStorageService: LocalStorageService(),
          ),
        ),
        BlocProvider(
          create: (context) => PaymentBloc(
            paymentService: PaymentManagementService(),
            paymentManager: PaymentServiceManager(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'وصلة - Wasla',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,

        // Localization
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', 'SA'), // Arabic
          Locale('en', 'US'), // English
        ],
        locale: const Locale('ar', 'SA'),

        // Routes
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const RegisterScreen(),
          '/verification': (context) => const VerificationCodeScreen(email: ''),
          '/document-upload': (context) => const DocumentUploadScreen(
                email: '',
                password: '',
                name: '',
                phone: '',
                role: UserRole.student,
              ),
          '/student/home': (context) => const StudentMainScreen(),
          '/student/courses': (context) => const StudentCoursesScreen(),
          '/student/payment': (context) => CoursePaymentScreen(
              userId: '',
              course: Course(
                id: '',
                title: '',
                description: '',
                instructorId: '',
                instructorName: '',
                status: CourseStatus.draft,
                level: CourseLevel.beginner,
                price: 0,
                duration: 0,
                lessonsCount: 0,
                category: '',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              )), // Fixed route
          '/instructor/dashboard': (context) => const InstructorMainScreen(),
          '/instructor/courses': (context) => const InstructorCoursesScreen(),
          '/admin/dashboard': (context) => const AdminMainScreen(),
          '/admin/users': (context) => const AdminUsersScreen(),
        },

        // Home
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    // التحقق من حالة الجلسة عند بدء التطبيق
    _checkSessionStatus();
  }

  /// التحقق من حالة الجلسة وإعادة التوجيه حسب الحاجة
  void _checkSessionStatus() async {
    final sessionService = SessionService();
    final isValid = await sessionService.isSessionValid();

    if (!isValid) {
      // إذا لم تكن الجلسة صالحة، إعادة التوجيه لشاشة تسجيل الدخول
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      });
      return;
    }

    // التحقق من حالة المستخدم وإعادة التوجيه حسب الدور
    final userRole = sessionService.getCurrentUserRole();
    final userStatus = sessionService.getCurrentUserStatus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userRole == 'student') {
        if (userStatus == 'active') {
          Navigator.pushNamedAndRemoveUntil(
              context, '/student/home', (route) => false);
        } else {
          // إعادة التوجيه لشاشة انتظار التفعيل
          Navigator.pushNamedAndRemoveUntil(
              context, '/verification', (route) => false);
        }
      } else if (userRole == 'instructor') {
        if (userStatus == 'verified') {
          Navigator.pushNamedAndRemoveUntil(
              context, '/instructor/dashboard', (route) => false);
        } else {
          // إعادة التوجيه لشاشة انتظار المراجعة
          Navigator.pushNamedAndRemoveUntil(
              context, '/verification', (route) => false);
        }
      } else if (userRole == 'admin') {
        Navigator.pushNamedAndRemoveUntil(
            context, '/admin/dashboard', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const LoginScreen(); // الشاشة الافتراضية
  }
}

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const StudentHomeScreen(),
    const StudentCoursesScreen(),
    const CertificatesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'الكورسات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: 'الشهادات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'الملف الشخصي',
          ),
        ],
      ),
    );
  }
}

class InstructorMainScreen extends StatefulWidget {
  const InstructorMainScreen({super.key});

  @override
  State<InstructorMainScreen> createState() => _InstructorMainScreenState();
}

class _InstructorMainScreenState extends State<InstructorMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const InstructorDashboardScreen(),
    const InstructorCoursesScreen(),
    const StudentsManagementScreen(),
    const InstructorAnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'لوحة المعلومات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'كورساتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'الطلاب',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'التحليلات',
          ),
        ],
      ),
    );
  }
}

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const AdminUsersScreen(),
    const AdminCoursesScreen(),
    const AdminReportsScreen(),
    const AdminSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'لوحة المعلومات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'المستخدمين',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'الكورسات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'التقارير',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}
