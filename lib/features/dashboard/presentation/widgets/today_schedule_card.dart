import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_card.dart';

class TodayScheduleCard extends StatelessWidget {
  const TodayScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        children: [
          _AppointmentTimelineItem(
            time: '09:00',
            patient: 'John Smith',
            description: 'Follow-up visit',
            isNext: true,
          ),

          SizedBox(height: AppSpacing.md),

          _AppointmentTimelineItem(
            time: '10:30',
            patient: 'Anna Brown',
            description: 'Consultation',
          ),

          SizedBox(height: AppSpacing.md),

          _AppointmentTimelineItem(
            time: '14:00',
            patient: 'Michael Wilson',
            description: 'Treatment session',
          ),
        ],
      ),
    );
  }
}

class _AppointmentTimelineItem extends StatelessWidget {
  const _AppointmentTimelineItem({
    required this.time,
    required this.patient,
    required this.description,
    this.isNext = false,
  });

  final String time;
  final String patient;
  final String description;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        SizedBox(width: 64, child: Text(time, style: AppTextStyles.bodyMedium)),

        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isNext ? AppColors.brand : AppColors.brandSoft,
              ),
            ),

            Container(
              width: 2,
              height: 56,
              color: AppColors.brand.withValues(alpha: 0.18),
            ),
          ],
        ),

        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isNext
                  ? Theme.of(context).brightness == Brightness.light
                        ? AppColors.brandSoft
                        : AppColors.brandSoftDark
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                const AppAvatar(name: 'Patient', size: AppAvatarSize.small),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patient, style: AppTextStyles.bodyLarge),
                      const SizedBox(height: AppSpacing.xs),
                      Text(description, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
