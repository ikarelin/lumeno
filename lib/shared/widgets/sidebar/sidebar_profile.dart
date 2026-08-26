import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_avatar.dart';

class SidebarProfile extends StatelessWidget {
  const SidebarProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppAvatar(name: 'Dr. Smith', size: AppAvatarSize.small),

        const SizedBox(width: AppSpacing.sm),

        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dr. Smith', style: AppTextStyles.bodyMedium),

            Text('Dentist', style: AppTextStyles.labelMedium),
          ],
        ),
      ],
    );
  }
}
