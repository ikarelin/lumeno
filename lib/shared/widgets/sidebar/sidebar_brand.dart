import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class SidebarBrand extends StatelessWidget {
  const SidebarBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lumeno', style: AppTextStyles.titleLarge),

        SizedBox(height: AppSpacing.xs),

        Text('Clinical workspace', style: AppTextStyles.bodyMedium),
      ],
    );
  }
}
