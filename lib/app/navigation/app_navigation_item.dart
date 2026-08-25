import 'package:flutter/material.dart';

enum AppNavigationItem {
  dashboard(
    path: '/dashboard',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    translationKey: 'dashboard.title',
  ),

  patients(
    path: '/patients',
    icon: Icons.people_outline,
    selectedIcon: Icons.people,
    translationKey: 'patients.title',
  ),

  calendar(
    path: '/calendar',
    icon: Icons.calendar_today_outlined,
    selectedIcon: Icons.calendar_today,
    translationKey: 'calendar.title',
  ),

  files(
    path: '/files',
    icon: Icons.folder_outlined,
    selectedIcon: Icons.folder,
    translationKey: 'files.title',
  );

  const AppNavigationItem({
    required this.path,
    required this.icon,
    required this.selectedIcon,
    required this.translationKey,
  });

  final String path;

  final IconData icon;

  final IconData selectedIcon;

  final String translationKey;
}
