import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import 'dashboard_available_slot_card.dart';
import 'dashboard_next_visit_card.dart';

class DashboardPrimaryCards extends StatelessWidget {
  const DashboardPrimaryCards({
    super.key,
    required this.nextVisitTime,
    required this.patientName,
    required this.appointmentType,
    required this.availableDateLabel,
    required this.availableTimeRange,
    this.onNextVisitTap,
    this.onAvailableSlotTap,
  });

  final String nextVisitTime;
  final String patientName;
  final String appointmentType;

  final String availableDateLabel;
  final String availableTimeRange;

  final VoidCallback? onNextVisitTap;
  final VoidCallback? onAvailableSlotTap;

  static const double _desktopBreakpoint = 720;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _desktopBreakpoint;

        final nextVisitCard = DashboardNextVisitCard(
          time: nextVisitTime,
          patientName: patientName,
          appointmentType: appointmentType,
          onTap: onNextVisitTap,
        );

        final availableSlotCard = DashboardAvailableSlotCard(
          dateLabel: availableDateLabel,
          timeRange: availableTimeRange,
          onTap: onAvailableSlotTap,
        );

        if (!isWide) {
          return Column(
            children: [
              nextVisitCard,

              const SizedBox(height: AppSpacing.md),

              availableSlotCard,
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: nextVisitCard),

              const SizedBox(width: AppSpacing.md),

              Expanded(child: availableSlotCard),
            ],
          ),
        );
      },
    );
  }
}
