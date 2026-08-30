import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';

class DashboardNextVisitCard extends StatelessWidget {
  const DashboardNextVisitCard({
    super.key,
    required this.time,
    required this.patientName,
    required this.appointmentType,
    this.onTap,
  });

  final String time;
  final String patientName;
  final String appointmentType;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: colorScheme.outlineVariant),
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
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.event_outlined,
                      size: 20,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  Expanded(
                    child: Text(
                      'dashboard.nextVisit'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              Text(
                time,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                patientName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              Text(
                appointmentType,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Row(
                children: [
                  Text(
                    'dashboard.openVisit'.tr(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(width: AppSpacing.xs),

                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
