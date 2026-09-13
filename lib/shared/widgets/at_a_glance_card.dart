import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_card.dart';

class AtAGlanceCard extends StatelessWidget {
  const AtAGlanceCard({
    super.key,
    required this.title,
    required this.metrics,
  });

  final String title;
  final List<AtAGlanceMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.tr(), style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.md),
          for (final metric in metrics) ...[
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.brand.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(metric.icon, size: 19, color: AppColors.brand),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    metric.label.tr(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  metric.value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (metric != metrics.last)
              const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class AtAGlanceMetric {
  const AtAGlanceMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;
}
