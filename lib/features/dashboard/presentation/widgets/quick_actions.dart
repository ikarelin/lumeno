import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    const spacing = AppSpacing.md;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _getColumns(constraints.maxWidth);
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: itemWidth,
              child: _QuickActionTile(
                icon: Icons.person_add_alt_1_outlined,
                title: 'dashboard.quickActionsItems.newPatient.title'.tr(),
                subtitle: 'dashboard.quickActionsItems.newPatient.subtitle'
                    .tr(),
                onTap: () {},
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _QuickActionTile(
                icon: Icons.calendar_month_outlined,
                title: 'dashboard.quickActionsItems.newVisit.title'.tr(),
                subtitle: 'dashboard.quickActionsItems.newVisit.subtitle'.tr(),
                onTap: () {},
              ),
            ),
          ],
        );
      },
    );
  }

  int _getColumns(double width) {
    if (width >= 1100) {
      return 3;
    }

    if (width >= 700) {
      return 2;
    }

    return 1;
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.brandSoft,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(icon, color: AppColors.brand, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.textSecondaryLight,
          ),
        ],
      ),
    );
  }
}
