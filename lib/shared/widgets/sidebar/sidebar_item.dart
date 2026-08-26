import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../app/navigation/app_navigation_item.dart';

class SidebarItem extends StatelessWidget {
  const SidebarItem({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppNavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(AppRadius.lg),

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),

          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),

          decoration: BoxDecoration(
            color: selected
                ? (Theme.of(context).brightness == Brightness.light
                      ? AppColors.brandSoft
                      : AppColors.brandSoftDark)
                : Colors.transparent,

            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),

          child: Row(
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,

                size: 22,

                color: selected
                    ? AppColors.brand
                    : colorScheme.onSurfaceVariant,
              ),

              const SizedBox(width: AppSpacing.md),

              Text(
                item.translationKey.tr(),

                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
