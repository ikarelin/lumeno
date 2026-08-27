import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';

class SidebarQuickActions extends StatelessWidget {
  const SidebarQuickActions({
    super.key,
    required this.onNewPatient,
    required this.onNewVisit,
  });

  final VoidCallback onNewPatient;
  final VoidCallback onNewVisit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            'sidebar.quickActions'.tr(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        _QuickActionItem(
          icon: Icons.person_add_outlined,
          label: 'dashboard.quickActionsItems.newPatient.title'.tr(),
          onTap: onNewPatient,
        ),

        const SizedBox(height: AppSpacing.xs),

        _QuickActionItem(
          icon: Icons.calendar_month_outlined,
          label: 'dashboard.quickActionsItems.newVisit.title'.tr(),
          onTap: onNewVisit,
        ),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.primary),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
