import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_breakpoints.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_section_title.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_primary_cards.dart';
import '../widgets/dashboard_upcoming_visits.dart';
import '../widgets/quick_actions.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const _contentMaxWidth = 1120.0;

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;

    final currentDate = DateFormat(
      'EEEE, d MMMM',
      context.locale.toLanguageTag(),
    ).format(DateTime.now());

    final upcomingVisits = [
      DashboardUpcomingVisit(
        timeLabel: '10:30',
        patientName: 'Anna Brown',
        appointmentType: 'dashboard.appointmentTypes.consultation'.tr(),
      ),
      DashboardUpcomingVisit(
        timeLabel: '14:00',
        patientName: 'Michael Wilson',
        appointmentType: 'dashboard.appointmentTypes.treatment'.tr(),
      ),
      DashboardUpcomingVisit(
        timeLabel: '16:30',
        patientName: 'Emma Davis',
        appointmentType: 'dashboard.appointmentTypes.followUp'.tr(),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DashboardHeader(),

                  const SizedBox(height: AppSpacing.xl),

                  DashboardPrimaryCards(
                    nextVisitTime: '09:00',
                    patientName: 'John Smith',
                    appointmentType: 'dashboard.appointmentTypes.followUp'.tr(),
                    availableDateLabel: currentDate,
                    availableTimeRange: '11:00–11:30',
                  ),

                  if (isDesktop) ...[
                    const SizedBox(height: AppSpacing.xl),

                    AppSectionTitle(
                      title: 'dashboard.upcomingVisits'.tr(),
                      actionLabel: 'dashboard.viewAll'.tr(),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    DashboardUpcomingVisits(visits: upcomingVisits),
                  ],

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
        ),
      ),
    );
  }
}
