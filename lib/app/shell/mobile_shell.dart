import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../navigation/app_navigation_items.dart';

class MobileShell extends StatelessWidget {
  const MobileShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,

      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateIndex(context),

        onDestinationSelected: (index) {
          context.go(AppNavigationItems.items[index].path);
        },

        destinations: AppNavigationItems.items
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),

                selectedIcon: Icon(item.selectedIcon),

                label: item.translationKey.tr(),
              ),
            )
            .toList(),
      ),
    );
  }

  int _calculateIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    for (var i = 0; i < AppNavigationItems.items.length; i++) {
      if (location.startsWith(AppNavigationItems.items[i].path)) {
        return i;
      }
    }

    return 0;
  }
}
