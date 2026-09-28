import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

/// Shared Lumeno popup-menu surface.
///
/// Contextual and overflow menus should use this widget instead of styling
/// [PopupMenuButton] independently in feature code.
class AppPopupMenu<T> extends StatelessWidget {
  const AppPopupMenu({
    required this.itemBuilder,
    required this.onSelected,
    this.enabled = true,
    this.tooltip,
    this.icon,
    this.child,
    super.key,
  }) : assert(icon == null || child == null);

  final PopupMenuItemBuilder<T> itemBuilder;
  final PopupMenuItemSelected<T> onSelected;
  final bool enabled;
  final String? tooltip;
  final Widget? icon;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<T>(
      enabled: enabled,
      tooltip: tooltip,
      onSelected: onSelected,
      itemBuilder: itemBuilder,
      color: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      position: PopupMenuPosition.under,
      offset: const Offset(0, AppSpacing.xs),
      padding: child == null
          ? const EdgeInsets.all(AppSpacing.sm)
          : EdgeInsets.zero,
      icon: child == null
          ? icon ?? const Icon(Icons.more_vert_rounded)
          : null,
      child: child,
    );
  }
}

/// Standard popup-menu item with one typography, icon size and inset.
class AppPopupMenuItem<T> extends PopupMenuItem<T> {
  AppPopupMenuItem({
    required T value,
    required String label,
    IconData? icon,
    Color? foregroundColor,
    super.enabled = true,
    super.key,
  }) : super(
         value: value,
         height: 48,
         padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
         child: Row(
           mainAxisSize: MainAxisSize.min,
           children: [
             if (icon != null) ...[
               Icon(icon, size: 20, color: foregroundColor),
               const SizedBox(width: AppSpacing.sm),
             ],
             Text(
               label,
               style: AppTextStyles.bodyMedium.copyWith(
                 color: foregroundColor,
               ),
             ),
           ],
         ),
       );
}
