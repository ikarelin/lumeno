import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/quick_create/domain/quick_create_context.dart';
import '../../features/quick_create/domain/quick_create_intent.dart';
import '../../features/quick_create/domain/quick_create_source.dart';
import '../../features/quick_create/presentation/quick_create_presenter.dart';
import '../../shared/widgets/sidebar/app_sidebar.dart';
import '../navigation/app_navigation_items.dart';

class DesktopShell extends StatefulWidget {
  const DesktopShell({super.key, required this.child});

  final Widget child;

  @override
  State<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<DesktopShell> {
  int _lastMainIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentMainIndex = _findCurrentMainIndex(context);

    if (currentMainIndex != null) {
      _lastMainIndex = currentMainIndex;
    }

    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            selectedIndex: currentMainIndex ?? _lastMainIndex,
            onDestinationSelected: (index) {
              context.go(AppNavigationItems.items[index].path);
            },
            onNewPatient: () {
              QuickCreatePresenter.show(
                context,
                const QuickCreateContext(
                  intent: QuickCreateIntent.newPatient,
                  source: QuickCreateSource.sidebarQuickAction,
                ),
              );
            },
            onNewVisit: () {
              QuickCreatePresenter.show(
                context,
                const QuickCreateContext(
                  intent: QuickCreateIntent.newVisit,
                  source: QuickCreateSource.sidebarQuickAction,
                ),
              );
            },
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  int? _findCurrentMainIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    for (var i = 0; i < AppNavigationItems.items.length; i++) {
      if (location.startsWith(AppNavigationItems.items[i].path)) {
        return i;
      }
    }

    return null;
  }
}
