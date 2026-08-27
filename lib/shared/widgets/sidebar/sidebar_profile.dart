import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_avatar.dart';

class SidebarProfile extends StatelessWidget {
  const SidebarProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        AppAvatar(name: 'Dr. Smith', size: AppAvatarSize.small),

        SizedBox(width: AppSpacing.sm),

        Column(
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
