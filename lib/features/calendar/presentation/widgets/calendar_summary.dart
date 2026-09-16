import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_text_styles.dart';

class CalendarSummary extends StatelessWidget {
  const CalendarSummary({
    super.key,
    required this.onAddVisit,
    required this.visitCount,
  });

  final VoidCallback onAddVisit;
  final int visitCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${'calendar.legend.visits'.tr()} ($visitCount)',
            style: AppTextStyles.titleLarge,
          ),
        ),
      ],
    );
  }
}
