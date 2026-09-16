import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';

class DashboardUpcomingVisit {
  const DashboardUpcomingVisit({
    required this.timeLabel,
    required this.patientName,
    required this.detail,
    this.onTap,
  });

  final String timeLabel;
  final String patientName;
  final String detail;
  final VoidCallback? onTap;
}

class DashboardUpcomingVisits extends StatelessWidget {
  const DashboardUpcomingVisits({
    super.key,
    this.visits = const [],
    this.message,
    this.actionLabel,
    this.onAction,
    this.isLoading = false,
    this.isError = false,
  });

  final List<DashboardUpcomingVisit> visits;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: isLoading
            ? const SizedBox(
                height: 116,
                child: Center(child: CircularProgressIndicator()),
              )
            : visits.isEmpty
            ? _EmptyState(
                message: message ?? '—',
                actionLabel: actionLabel,
                onAction: onAction,
                isError: isError,
              )
            : Column(
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.isError,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = isError ? colorScheme.error : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.event_busy_outlined,
            color: accent,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyLarge.copyWith(color: accent),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: AppSpacing.md),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
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
                      visit.detail,
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
