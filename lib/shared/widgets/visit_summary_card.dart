import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_card.dart';

class VisitSummaryCard extends StatelessWidget {
  const VisitSummaryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.time,
    required this.detail,
    required this.actionLabel,
    this.primaryText,
    this.note,
    this.noteLabel,
    this.noteMaxLines = 2,
    this.onTap,
    this.minHeight = 184,
  });

  final String title;
  final IconData icon;
  final String time;
  final String detail;
  final String actionLabel;
  final String? primaryText;
  final String? note;
  final String? noteLabel;
  final int noteMaxLines;
  final VoidCallback? onTap;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final normalizedNote = note?.trim();
    final hasNote = normalizedNote != null && normalizedNote.isNotEmpty;
    final actionColor = onTap == null
        ? colorScheme.onSurfaceVariant.withValues(alpha: 0.45)
        : colorScheme.primary;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
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
                  child: Icon(icon, size: 20, color: colorScheme.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(title, style: AppTextStyles.titleLarge)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              time,
              style: AppTextStyles.headlineMedium.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (primaryText != null && primaryText!.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                primaryText!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xs),
            Text(
              detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (hasNote) ...[
              const SizedBox(height: AppSpacing.md),
              if (noteLabel != null && noteLabel!.trim().isNotEmpty) ...[
                Text(
                  noteLabel!,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              Text(
                normalizedNote,
                maxLines: noteMaxLines,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    actionLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: actionColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(Icons.arrow_forward_rounded, size: 18, color: actionColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
