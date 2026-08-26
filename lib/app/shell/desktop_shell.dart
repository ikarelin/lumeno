import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/sidebar/app_sidebar.dart';
import '../navigation/app_navigation_items.dart';

class DesktopShell extends StatelessWidget {
  const DesktopShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            selectedIndex: _calculateIndex(context),

            onDestinationSelected: (index) {
              context.go(AppNavigationItems.items[index].path);
            },
          ),

          Expanded(child: child),
        ],
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
