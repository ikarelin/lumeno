import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding, this.onTap});

  final Widget child;

  final EdgeInsetsGeometry? padding;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final card = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),

      decoration: BoxDecoration(
        color: theme.colorScheme.surface,

        borderRadius: BorderRadius.circular(AppRadius.xl),

        boxShadow: const [AppShadows.card],
      ),

      child: child,
    );

    if (onTap == null) {
      return card;
    }

    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(AppRadius.xl),

      child: card,
    );
  }
}
