import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/theme_mode_controller.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final isDark = brightness == Brightness.dark;

    final formattedDate = DateFormat(
      'EEEE, d MMMM',
      context.locale.toLanguageTag(),
    ).format(DateTime.now());

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'dashboard.greeting'.tr(namedArgs: const {'name': 'Dr. Smith'}),
                style: AppTextStyles.headlineMedium,
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(formattedDate, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        IconButton(
          onPressed: () {
            ref.read(themeModeProvider.notifier).toggleLightDark(brightness);
          },
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
          color: colorScheme.primary,
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}
