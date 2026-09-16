import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';

class DashboardPrimaryCards extends StatelessWidget {
  const DashboardPrimaryCards({
    super.key,
    required this.nextVisitCard,
    required this.availableSlotCard,
  });

  final Widget nextVisitCard;
  final Widget availableSlotCard;

  static const double _desktopBreakpoint = 720;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _desktopBreakpoint;

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
