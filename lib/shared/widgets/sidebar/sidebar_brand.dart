import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class SidebarBrand extends StatelessWidget {
  const SidebarBrand({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: Image.asset(
            'assets/branding/lumeno_logo_mark_concept_v1.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        Text(
          'Lumeno',
          style: AppTextStyles.brand.copyWith(
            fontSize: 24,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
