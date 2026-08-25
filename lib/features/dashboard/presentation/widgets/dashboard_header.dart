import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_avatar.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning, Dr. Smith',
              style: AppTextStyles.headlineMedium,
            ),
            SizedBox(height: AppSpacing.sm),
            Text('Wednesday, 25 August', style: AppTextStyles.bodyMedium),
          ],
        ),
        AppAvatar(name: 'Dr. Smith', size: AppAvatarSize.medium),
      ],
    );
  }
}
