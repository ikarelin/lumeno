import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../app/navigation/app_navigation_items.dart';
import 'sidebar_brand.dart';
import 'sidebar_item.dart';
import 'sidebar_profile.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(AppSpacing.lg),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SidebarBrand(),

          const SizedBox(height: AppSpacing.xl),

          Expanded(
            child: Column(
              children: [
                for (var i = 0; i < AppNavigationItems.items.length; i++)
                  SidebarItem(
                    item: AppNavigationItems.items[i],
                    selected: i == selectedIndex,
                    onTap: () => onDestinationSelected(i),
                  ),
              ],
            ),
          ),

          const SidebarProfile(),
        ],
      ),
    );
  }
}
