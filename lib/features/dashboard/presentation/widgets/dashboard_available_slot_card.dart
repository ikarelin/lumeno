import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
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
        ),
      ),
    );
  }
}
