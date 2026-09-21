import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_breakpoints.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../profile/presentation/providers/doctor_profile_provider.dart';
import '../../../scheduling/domain/calendar_civil_time.dart';
import '../dashboard_time_labels.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key, required this.calendarTime});

  final CalendarCivilTime calendarTime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final isDesktop =
        MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;

    final profileAsync = ref.watch(doctorProfileProvider);
    final labels = DashboardTimeLabels(calendarTime);
    final now = DateTime.now();

    final greeting = profileAsync.when(
      data: (profile) {
        if (profile == null) {
          return 'dashboard.title'.tr();
        }

        return labels.greetingKey(now).tr(
          namedArgs: {'name': profile.fullName},
        );
      },
      loading: () => 'dashboard.title'.tr(),
      error: (_, _) => 'dashboard.title'.tr(),
    );

    final formattedDate = labels.headerDate(
      now,
      context.locale.toLanguageTag(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: isDesktop
              ? AppTextStyles.headlineLarge
              : AppTextStyles.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          formattedDate,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
