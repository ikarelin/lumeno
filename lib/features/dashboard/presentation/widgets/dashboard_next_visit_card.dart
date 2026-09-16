import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';

class DashboardNextVisitCard extends StatelessWidget {
  const DashboardNextVisitCard({
    super.key,
    this.time,
    this.patientName,
    this.detail,
    this.message,
    this.actionLabel,
    this.onTap,
    this.onAction,
    this.isLoading = false,
    this.isError = false,
  });

  final String? time;
  final String? patientName;
  final String? detail;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onTap;
  final VoidCallback? onAction;
  final bool isLoading;
  final bool isError;

  bool get _hasVisit =>
      time != null && patientName != null && detail != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: _hasVisit ? onTap : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 184),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.event_outlined,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'dashboard.nextVisit'.tr(),
                    style: AppTextStyles.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (isLoading)
              const SizedBox(
                height: 116,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_hasVisit)
              _VisitContent(
                time: time!,
                patientName: patientName!,
                detail: detail!,
              )
            else
              _StateContent(
                message: message ?? '—',
                actionLabel: actionLabel,
                onAction: onAction,
                isError: isError,
              ),
          ],
        ),
      ),
    );
  }
}

class _VisitContent extends StatelessWidget {
  const _VisitContent({
    required this.time,
    required this.patientName,
    required this.detail,
  });

  final String time;
  final String patientName;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: AppTextStyles.headlineMedium.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          patientName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          detail,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Text(
              'dashboard.openVisit'.tr(),
              style: AppTextStyles.bodyMedium.copyWith(
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
    );
  }
}

class _StateContent extends StatelessWidget {
  const _StateContent({
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.event_busy_outlined,
              color: accent,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyLarge.copyWith(color: accent),
              ),
            ),
          ],
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: AppSpacing.md),
          TextButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: Text(actionLabel!),
          ),
        ],
      ],
    );
  }
}
