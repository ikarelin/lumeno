import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'EEEE, d MMMM',
      context.locale.toLanguageTag(),
    ).format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'dashboard.greeting'.tr(namedArgs: const {'name': 'Dr. Smith'}),
          style: AppTextStyles.headlineMedium,
        ),

        const SizedBox(height: AppSpacing.sm),

        Text(formattedDate, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}
