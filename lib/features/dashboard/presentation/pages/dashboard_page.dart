import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_section_title.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/quick_actions.dart';
import '../widgets/today_schedule_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              DashboardHeader(),

              SizedBox(height: AppSpacing.xl),

              AppSectionTitle(
                title: 'Today appointments',
                actionLabel: 'View all',
              ),

              SizedBox(height: AppSpacing.md),

              TodayScheduleCard(),

              SizedBox(height: AppSpacing.xl),

              AppSectionTitle(title: 'Quick actions'),

              SizedBox(height: AppSpacing.md),

              QuickActions(),
            ],
          ),
        ),
      ),
    );
  }
}
