import 'package:flutter/material.dart';

import '../../../app/navigation/app_navigation_items.dart';
import '../../../app/theme/app_spacing.dart';
import 'sidebar_brand.dart';
import 'sidebar_item.dart';
import 'sidebar_profile.dart';
import 'sidebar_quick_actions.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onNewPatient,
    required this.onNewVisit,
  });

  static const width = 280.0;

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onNewPatient;
  final VoidCallback onNewVisit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      color: colorScheme.surface,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SidebarBrand(),

          const SizedBox(height: AppSpacing.md),

          Divider(height: 1, color: colorScheme.outlineVariant),

          const SizedBox(height: AppSpacing.md),

          for (var i = 0; i < AppNavigationItems.items.length; i++)
            SidebarItem(
              item: AppNavigationItems.items[i],
              selected: i == selectedIndex,
              onTap: () => onDestinationSelected(i),
            ),

          const SizedBox(height: AppSpacing.md),

          Divider(height: 1, color: colorScheme.outlineVariant),

          const SizedBox(height: AppSpacing.md),

          SidebarQuickActions(
            onNewPatient: onNewPatient,
            onNewVisit: onNewVisit,
          ),

          const Spacer(),

          const SidebarProfile(),
        ],
      ),
    );
  }
}
