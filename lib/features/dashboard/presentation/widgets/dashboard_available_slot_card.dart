import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';

class DashboardAvailableSlotCard extends StatelessWidget {
  const DashboardAvailableSlotCard({
    super.key,
    this.dateLabel,
    this.timeRange,
    this.message,
    this.actionLabel,
    this.onTap,
    this.onAction,
    this.isLoading = false,
    this.isError = false,
  });

  final String? dateLabel;
  final String? timeRange;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onTap;
  final VoidCallback? onAction;
  final bool isLoading;
  final bool isError;

  bool get _hasSlot => dateLabel != null && timeRange != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: _hasSlot ? onTap : null,
      child: Container(
        constraints: const BoxConstraints(minHeight: 232),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
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
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.schedule_rounded,
                    size: 20,
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'dashboard.nextAvailableSlot'.tr(),
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
            else if (_hasSlot)
              _SlotContent(
                timeRange: timeRange!,
                dateLabel: dateLabel!,
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

class _SlotContent extends StatelessWidget {
  const _SlotContent({required this.timeRange, required this.dateLabel});

  final String timeRange;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              timeRange,
              style: AppTextStyles.headlineMedium.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              dateLabel,
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.lg),
          child: Row(
            children: [
              Text(
                'dashboard.bookPatient'.tr(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(Icons.add_rounded, size: 20, color: colorScheme.primary),
            ],
          ),
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
