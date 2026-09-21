import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_breakpoints.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../calendar/presentation/widgets/calendar_visit_details_surface.dart';
import '../../../scheduling/domain/calendar_civil_time.dart';
import '../../../scheduling/presentation/providers/doctor_time_mode.dart';
import '../../../visits/domain/visit.dart';
import '../../../visits/presentation/providers/patient_visits_provider.dart';

/// Only the approved Next / Last visit overview. History and clinical notes
/// are deliberately outside the scope of PATIENT-WORKSPACE-01A.
class PatientVisitSummaryCards extends ConsumerWidget {
  const PatientVisitSummaryCards({
    required this.patientId,
    required this.canOpenDetails,
    super.key,
  });

  final String patientId;
  final bool canOpenDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = ref.watch(patientNextVisitProvider(patientId));
    final last = ref.watch(patientLastCompletedVisitProvider(patientId));
    final calendarTimeState = ref.watch(calendarCivilTimeProvider);
    final isDesktop =
        MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;

    final nextCard = _VisitSummaryCard(
      label: 'patientVisitSummary.next'.tr(),
      icon: Icons.event_available_outlined,
      state: next,
      calendarTimeState: calendarTimeState,
      emptyLabel: 'patientVisitSummary.noUpcoming'.tr(),
      statusLabel: 'patientVisitSummary.scheduled'.tr(),
      canOpenDetails: canOpenDetails,
      onRetry: () => ref.invalidate(patientNextVisitProvider(patientId)),
      onTimeRetry: () => ref.invalidate(calendarCivilTimeProvider),
      onOpen: (visit, calendarTime) =>
          _openDetails(context, ref, visit, isDesktop, calendarTime),
    );
    final lastCard = _VisitSummaryCard(
      label: 'patientVisitSummary.last'.tr(),
      icon: Icons.history_rounded,
      state: last,
      calendarTimeState: calendarTimeState,
      emptyLabel: 'patientVisitSummary.noCompleted'.tr(),
      statusLabel: 'patientVisitSummary.completed'.tr(),
      canOpenDetails: canOpenDetails,
      onRetry: () => ref.invalidate(patientLastCompletedVisitProvider(patientId)),
      onTimeRetry: () => ref.invalidate(calendarCivilTimeProvider),
      onOpen: (visit, calendarTime) =>
          _openDetails(context, ref, visit, isDesktop, calendarTime),
    );

    if (!isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          nextCard,
          const SizedBox(height: AppSpacing.md),
          lastCard,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: nextCard),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: lastCard),
      ],
    );
  }

  Future<void> _openDetails(
    BuildContext context,
    WidgetRef ref,
    Visit visit,
    bool isDesktop,
    CalendarCivilTime calendarTime,
  ) async {
    await CalendarVisitDetailsSurface.show(
      context: context,
      visit: visit,
      selectedDate: calendarTime.civilDayAt(visit.startsAt),
      isDesktop: isDesktop,
      calendarTime: calendarTime,
    );
    if (!context.mounted) return;
    // Notes and status can change in the existing visit-details surface.
    ref
      ..invalidate(patientNextVisitProvider(patientId))
      ..invalidate(patientLastCompletedVisitProvider(patientId));
  }
}

class _VisitSummaryCard extends StatelessWidget {
  const _VisitSummaryCard({
    required this.label,
    required this.icon,
    required this.state,
    required this.calendarTimeState,
    required this.emptyLabel,
    required this.statusLabel,
    required this.canOpenDetails,
    required this.onRetry,
    required this.onTimeRetry,
    required this.onOpen,
  });

  final String label;
  final IconData icon;
  final AsyncValue<Visit?> state;
  final AsyncValue<CalendarCivilTime> calendarTimeState;
  final String emptyLabel;
  final String statusLabel;
  final bool canOpenDetails;
  final VoidCallback onRetry;
  final VoidCallback onTimeRetry;
  final void Function(Visit, CalendarCivilTime) onOpen;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(label, style: AppTextStyles.titleLarge)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          state.when(
            skipLoadingOnRefresh: false,
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Center(child: CircularProgressIndicator.adaptive()),
            ),
            error: (_, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('patientVisitSummary.loadFailed'.tr(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.error,
                    )),
                const SizedBox(height: AppSpacing.sm),
                AppButton.secondary(
                  label: 'patients.retry'.tr(),
                  onPressed: onRetry,
                ),
              ],
            ),
            data: (visit) {
              if (visit == null) {
                return Text(
                  emptyLabel,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                );
              }
              // Visit.startsAt is an absolute instant. Display it in the
              // doctor's configured IANA zone, never in the device zone.
              if (calendarTimeState.isLoading) {
                return const Center(child: CircularProgressIndicator.adaptive());
              }
              final calendarTime = calendarTimeState.asData?.value;
              if (calendarTime == null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'patientVisitSummary.loadFailed'.tr(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton.secondary(
                      label: 'patients.retry'.tr(),
                      onPressed: onTimeRetry,
                    ),
                  ],
                );
              }
              final dateLabel = '${DateFormat(
                'd MMMM y',
                context.locale.toLanguageTag(),
              ).format(calendarTime.displayInstant(visit.startsAt))} '
                  '· ${calendarTime.clockLabel(visit.startsAt)}';
              final note = visit.note.trim();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateLabel, style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    statusLabel,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (note.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.40),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('quickCreate.visit.note'.tr(),
                              style: AppTextStyles.labelMedium.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              )),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            note,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  AppButton.secondary(
                    label: 'patientVisitSummary.open'.tr(),
                    onPressed: canOpenDetails ? () => onOpen(visit, calendarTime) : null,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
