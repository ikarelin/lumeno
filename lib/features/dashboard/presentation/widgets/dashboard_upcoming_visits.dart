import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';

class DashboardUpcomingVisit {
  const DashboardUpcomingVisit({
    required this.timeLabel,
    required this.patientName,
    required this.appointmentType,
    this.onTap,
  });

  final String timeLabel;
  final String patientName;
  final String appointmentType;
  final VoidCallback? onTap;
}

class DashboardUpcomingVisits extends StatelessWidget {
  const DashboardUpcomingVisits({super.key, required this.visits});

  final List<DashboardUpcomingVisit> visits;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Column(
          children: [
            for (var i = 0; i < visits.length; i++) ...[
              _UpcomingVisitRow(visit: visits[i]),
              if (i < visits.length - 1)
                Divider(
                  height: 1,
                  indent: AppSpacing.lg,
                  endIndent: AppSpacing.lg,
                  color: colorScheme.outlineVariant,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UpcomingVisitRow extends StatelessWidget {
  const _UpcomingVisitRow({required this.visit});

  final DashboardUpcomingVisit visit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: visit.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                child: Text(
                  visit.timeLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 19,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit.patientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      visit.appointmentType,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
