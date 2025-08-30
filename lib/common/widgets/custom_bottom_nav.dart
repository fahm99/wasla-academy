import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class CustomBottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String route;

  const CustomBottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.route,
  });
}

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<CustomBottomNavItem> items;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color:
            backgroundColor ?? theme.bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            offset: const Offset(0, -1),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return GestureDetector(
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (selectedItemColor ?? AppTheme.primaryColor)
                            .withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isSelected
                              ? (item.activeIcon ?? item.icon)
                              : item.icon,
                          key: ValueKey(isSelected),
                          color: isSelected
                              ? (selectedItemColor ?? AppTheme.primaryColor)
                              : (unselectedItemColor ?? theme.iconTheme.color),
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: isSelected
                              ? (selectedItemColor ?? AppTheme.primaryColor)
                              : (unselectedItemColor ??
                                  theme.textTheme.bodySmall!.color),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        child: Text(item.label),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class StudentBottomNavItems {
  static const List<CustomBottomNavItem> items = [
    CustomBottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'الرئيسية',
      route: '/student/home',
    ),
    CustomBottomNavItem(
      icon: Icons.book_outlined,
      activeIcon: Icons.book,
      label: 'الكورسات',
      route: '/student/courses',
    ),
    CustomBottomNavItem(
      icon: Icons.verified_outlined,
      activeIcon: Icons.verified,
      label: 'الشهادات',
      route: '/student/certificates',
    ),
    CustomBottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'الملف الشخصي',
      route: '/student/profile',
    ),
  ];
}

class InstructorBottomNavItems {
  static const List<CustomBottomNavItem> items = [
    CustomBottomNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'لوحة المعلومات',
      route: '/instructor/dashboard',
    ),
    CustomBottomNavItem(
      icon: Icons.book_outlined,
      activeIcon: Icons.book,
      label: 'كورساتي',
      route: '/instructor/courses',
    ),
    CustomBottomNavItem(
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: 'الطلاب',
      route: '/instructor/students',
    ),
    CustomBottomNavItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'التحليلات',
      route: '/instructor/analytics',
    ),
  ];
}

class AdminBottomNavItems {
  static const List<CustomBottomNavItem> items = [
    CustomBottomNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'لوحة المعلومات',
      route: '/admin/dashboard',
    ),
    CustomBottomNavItem(
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: 'المستخدمين',
      route: '/admin/users',
    ),
    CustomBottomNavItem(
      icon: Icons.school_outlined,
      activeIcon: Icons.school,
      label: 'الكورسات',
      route: '/admin/courses',
    ),
    CustomBottomNavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'الإعدادات',
      route: '/admin/settings',
    ),
  ];
}
