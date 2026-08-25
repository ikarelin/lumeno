import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;

  final String? actionLabel;

  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        Text(title, style: AppTextStyles.titleLarge),

        if (actionLabel != null)
          TextButton(
            onPressed: onActionTap,

            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            ),

            child: Text(actionLabel!),
          ),
      ],
    );
  }
}
