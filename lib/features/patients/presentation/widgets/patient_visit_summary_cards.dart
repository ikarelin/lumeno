import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_breakpoints.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/visit_summary_card.dart';
import '../../../calendar/presentation/widgets/calendar_visit_details_surface.dart';
import '../../../scheduling/domain/calendar_civil_time.dart';
import '../../../scheduling/presentation/providers/doctor_time_mode.dart';
import '../../../visits/domain/visit.dart';
import '../../../visits/presentation/providers/patient_visits_provider.dart';

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
      canOpenDetails: canOpenDetails,
      onRetry: () =>
          ref.invalidate(patientLastCompletedVisitProvider(patientId)),
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

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: nextCard),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: lastCard),
        ],
      ),
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
  final bool canOpenDetails;
  final VoidCallback onRetry;
  final VoidCallback onTimeRetry;
  final void Function(Visit, CalendarCivilTime) onOpen;

  @override
  Widget build(BuildContext context) {
    return state.when(
      skipLoadingOnRefresh: false,
      loading: () => _VisitSummaryStateCard.loading(label: label, icon: icon),
      error: (_, _) => _VisitSummaryStateCard.error(
        label: label,
        icon: icon,
        onRetry: onRetry,
      ),
      data: (visit) {
        if (visit == null) {
          return _VisitSummaryStateCard.empty(
            label: label,
            icon: icon,
            message: emptyLabel,
          );
        }

        if (calendarTimeState.isLoading) {
          return _VisitSummaryStateCard.loading(label: label, icon: icon);
        }

        final calendarTime = calendarTimeState.asData?.value;
        if (calendarTime == null) {
          return _VisitSummaryStateCard.error(
            label: label,
            icon: icon,
            onRetry: onTimeRetry,
          );
        }

        final locale = context.locale.toLanguageTag();
        final dateLabel = DateFormat(
          'EEE, d MMM',
          locale,
        ).format(calendarTime.displayInstant(visit.startsAt));
        final note = visit.note.trim();

        return VisitSummaryCard(
          title: label,
          icon: icon,
          time: calendarTime.clockLabel(visit.startsAt),
          detail: dateLabel,
          note: note.isEmpty ? null : note,
          noteLabel: note.isEmpty ? null : 'quickCreate.visit.note'.tr(),
          noteMaxLines: 3,
          actionLabel: 'patientVisitSummary.open'.tr(),
          onTap: canOpenDetails ? () => onOpen(visit, calendarTime) : null,
        );
      },
    );
  }
}

class _VisitSummaryStateCard extends StatelessWidget {
  const _VisitSummaryStateCard._({
    required this.label,
    required this.icon,
    this.message,
    this.onRetry,
    this.isLoading = false,
    this.isError = false,
  });

  const _VisitSummaryStateCard.loading({
    required String label,
    required IconData icon,
  }) : this._(label: label, icon: icon, isLoading: true);

  const _VisitSummaryStateCard.empty({
    required String label,
    required IconData icon,
    required String message,
  }) : this._(label: label, icon: icon, message: message);

  const _VisitSummaryStateCard.error({
    required String label,
    required IconData icon,
    required VoidCallback onRetry,
  }) : this._(label: label, icon: icon, onRetry: onRetry, isError: true);

  final String label;
  final IconData icon;
  final String? message;
  final VoidCallback? onRetry;
  final bool isLoading;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final messageColor = isError
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 184),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(icon, size: 20, color: colorScheme.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(label, style: AppTextStyles.titleLarge)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (isLoading)
              const SizedBox(
                height: 96,
                child: Center(child: CircularProgressIndicator.adaptive()),
              )
            else ...[
              Text(
                isError
                    ? 'patientVisitSummary.loadFailed'.tr()
                    : message ?? '—',
                style: AppTextStyles.bodyMedium.copyWith(color: messageColor),
              ),
              if (isError && onRetry != null) ...[
                const SizedBox(height: AppSpacing.md),
                AppButton.secondary(
                  label: 'patients.retry'.tr(),
                  onPressed: onRetry,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
