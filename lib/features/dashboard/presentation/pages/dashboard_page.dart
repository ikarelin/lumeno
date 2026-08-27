import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_breakpoints.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_section_title.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/quick_actions.dart';
import '../widgets/today_schedule_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardHeader(),

              const SizedBox(height: AppSpacing.xl),

              AppSectionTitle(
                title: 'dashboard.todayAppointments'.tr(),
                actionLabel: 'dashboard.viewAll'.tr(),
              ),

              const SizedBox(height: AppSpacing.md),

              const TodayScheduleCard(),

              if (!isDesktop) ...[
                const SizedBox(height: AppSpacing.xl),

                AppSectionTitle(title: 'dashboard.quickActions'.tr()),

                const SizedBox(height: AppSpacing.md),

                const QuickActions(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
