import 'package:flutter/material.dart';

import '../theme/app_breakpoints.dart';
import 'desktop_shell.dart';
import 'mobile_shell.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppBreakpoints.desktop) {
          return DesktopShell(child: child);
        }

        return MobileShell(child: child);
      },
    );
  }
}
