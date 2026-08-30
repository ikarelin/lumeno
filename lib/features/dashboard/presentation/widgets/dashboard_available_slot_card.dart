import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';

class DashboardAvailableSlotCard extends StatelessWidget {
  const DashboardAvailableSlotCard({
    super.key,
    required this.dateLabel,
    required this.timeRange,
    this.onTap,
  });

  final String dateLabel;
  final String timeRange;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.primaryContainer.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.18)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.schedule_rounded,
                      size: 20,
                      color: colorScheme.onPrimary,
                    ),
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  Expanded(
                    child: Text(
                      'dashboard.nextAvailableSlot'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              Text(
                timeRange,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                dateLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: AppSpacing.xs),

                  Text(
                    'dashboard.available'.tr(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              Row(
                children: [
                  Text(
                    'dashboard.bookPatient'.tr(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(width: AppSpacing.xs),

                  Icon(Icons.add_rounded, size: 20, color: colorScheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
