import '../models/user.dart';

/// Authentication guard class to handle user navigation based on roles
class AuthGuard {
  /// Get the default route for a user based on their role
  static String getDefaultRoute(UserRole role) {
    switch (role) {
      case UserRole.student:
        return '/student/home';
      case UserRole.instructor:
        return '/instructor/dashboard';
      case UserRole.admin:
        return '/admin/dashboard';
    }
  }

  /// Check if user has permission to access a specific route
  static bool canAccess(UserRole userRole, String route) {
    // Define route permissions
    final Map<String, List<UserRole>> routePermissions = {
      '/student/home': [UserRole.student],
      '/student/courses': [UserRole.student],
      '/student/course-details': [UserRole.student],
      '/student/lesson': [UserRole.student],
      '/student/payment': [UserRole.student],
      '/instructor/dashboard': [UserRole.instructor],
      '/instructor/courses': [UserRole.instructor],
      '/admin/dashboard': [UserRole.admin],
      '/admin/users': [UserRole.admin],
      '/admin/courses': [UserRole.admin],
      '/admin/reports': [UserRole.admin],
    };

    // Allow access to common routes
    final commonRoutes = ['/', '/login', '/signup', '/verification'];
    if (commonRoutes.contains(route)) {
      return true;
    }

    // Check specific route permissions
    final allowedRoles = routePermissions[route];
    return allowedRoles?.contains(userRole) ?? false;
  }

  /// Get user-specific routes
  static List<String> getUserRoutes(UserRole role) {
    switch (role) {
      case UserRole.student:
        return [
          '/student/home',
          '/student/courses',
          '/student/course-details',
          '/student/lesson',
          '/student/payment',
        ];
      case UserRole.instructor:
        return [
          '/instructor/dashboard',
          '/instructor/courses',
        ];
      case UserRole.admin:
        return [
          '/admin/dashboard',
          '/admin/users',
          '/admin/courses',
          '/admin/reports',
        ];
    }
  }
}
