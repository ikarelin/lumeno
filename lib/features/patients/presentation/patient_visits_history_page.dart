import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_breakpoints.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../calendar/presentation/widgets/calendar_visit_details_surface.dart';
import '../../quick_create/domain/quick_create_context.dart';
import '../../quick_create/domain/quick_create_intent.dart';
import '../../quick_create/domain/quick_create_source.dart';
import '../../quick_create/presentation/quick_create_presenter.dart';
import '../../scheduling/domain/calendar_civil_time.dart';
import '../../scheduling/presentation/providers/doctor_time_mode.dart';
import '../../visits/domain/visit.dart';
import '../../visits/presentation/providers/patient_visits_provider.dart';
import '../domain/patient.dart';
import 'providers/patient_provider.dart';

/// Patient-scoped visit history. Uses the same repository paging and doctor
/// IANA-zone presentation as the existing Next/Last visit summaries.
class PatientVisitsHistoryPage extends ConsumerWidget {
  const PatientVisitsHistoryPage({required this.patientId, super.key});

  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientState = ref.watch(patientByIdProvider(patientId));
    return Scaffold(
      body: SafeArea(
        child: patientState.when(
          skipLoadingOnRefresh: false,
          loading: () => const Center(child: CircularProgressIndicator.adaptive()),
          error: (_, _) => _HistoryMessage(
            message: 'patients.loadFailed'.tr(),
            onBack: () => _back(context, patientId),
            onRetry: () => ref.invalidate(patientByIdProvider(patientId)),
          ),
          data: (patient) => patient == null
              ? _HistoryMessage(
                  message: 'patients.notFound'.tr(),
                  onBack: () => _back(context, patientId),
                )
              : _PatientVisitsHistoryContent(patient: patient),
        ),
      ),
    );
  }
}

void _back(BuildContext context, String patientId) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/patients/${Uri.encodeComponent(patientId)}');
  }
}

class _PatientVisitsHistoryContent extends ConsumerStatefulWidget {
  const _PatientVisitsHistoryContent({required this.patient});

  final Patient patient;

  @override
  ConsumerState<_PatientVisitsHistoryContent> createState() =>
      _PatientVisitsHistoryContentState();
}

class _PatientVisitsHistoryContentState
    extends ConsumerState<_PatientVisitsHistoryContent> {
  static const _pageSize = 30;
  static const _maxContentWidth = 1120.0;

  int _requestedPages = 1;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;
    final calendarTimeState = ref.watch(calendarCivilTimeProvider);

    // Watch each requested page in sequence. The provider owns the repository
    // request and its loading/error state; we never invent local visit data.
    final visits = <Visit>[];
    PatientVisitsPageKey? pendingKey;
    AsyncValue<List<Visit>>? pendingState;
    var canLoadMore = false;
    for (var pageIndex = 0; pageIndex < _requestedPages; pageIndex++) {
      final key = (
        patientId: widget.patient.id,
        offset: pageIndex * _pageSize,
      );
      final page = ref.watch(patientVisitsPageProvider(key));
      if (page.isLoading || page.hasError || !page.hasValue) {
        pendingKey = key;
        pendingState = page;
        break;
      }
      final rows = page.requireValue;
      visits.addAll(rows);
      canLoadMore = rows.length == _pageSize;
      if (!canLoadMore) break;
    }

    final calendarTime = calendarTimeState.asData?.value;
    final isTimeLoading = calendarTimeState.isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context, isDesktop),
              const SizedBox(height: AppSpacing.xl),
              if (isTimeLoading)
                const Center(child: CircularProgressIndicator.adaptive())
              else if (calendarTime == null)
                _statusCard(
                  'patientVisitHistory.timeFailed'.tr(),
                  () => ref.invalidate(calendarCivilTimeProvider),
                )
              else if (pendingState != null && visits.isEmpty)
                pendingState.isLoading
                    ? const Center(child: CircularProgressIndicator.adaptive())
                    : _statusCard(
                        'patientVisitHistory.loadFailed'.tr(),
                        () => ref.invalidate(patientVisitsPageProvider(pendingKey!)),
                      )
              else if (visits.isEmpty)
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'patientVisitHistory.empty'.tr(),
                    style: AppTextStyles.bodyMedium,
                  ),
                )
              else ...[
                for (final visit in visits) ...[
                  _VisitHistoryRow(
                    key: ValueKey(visit.id),
                    visit: visit,
                    calendarTime: calendarTime,
                    canOpen: !_busy,
                    onOpen: () => _openDetails(visit, calendarTime, isDesktop),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (pendingState != null)
                  pendingState.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Center(child: CircularProgressIndicator.adaptive()),
                        )
                      : _statusCard(
                          'patientVisitHistory.loadMoreFailed'.tr(),
                          () => ref.invalidate(patientVisitsPageProvider(pendingKey!)),
                        )
                else if (canLoadMore)
                  Align(
                    alignment: Alignment.center,
                    child: AppButton.secondary(
                      label: 'patientVisitHistory.loadMore'.tr(),
                      onPressed: _busy
                          ? null
                          : () => setState(() => _requestedPages += 1),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, bool isDesktop) {
    final colors = Theme.of(context).colorScheme;
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'patients.workspace'.tr(),
          style: AppTextStyles.bodyMedium.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'patientVisitHistory.title'.tr(),
          style: isDesktop ? AppTextStyles.headlineLarge : AppTextStyles.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          widget.patient.name,
          style: AppTextStyles.bodyMedium.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
    if (isDesktop) {
      return Row(
        children: [
          IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => _back(context, widget.patient.id),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: title),
          AppButton.primary(
            label: 'patients.newVisit'.tr(),
            icon: Icons.add_rounded,
            onPressed: _busy ? null : _createVisit,
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => _back(context, widget.patient.id),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(child: title),
            IconButton.filled(
              tooltip: 'patients.newVisit'.tr(),
              onPressed: _busy ? null : _createVisit,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statusCard(String message, VoidCallback retry) => AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            AppButton.secondary(label: 'patients.retry'.tr(), onPressed: retry),
          ],
        ),
      );

  void _refreshVisits() {
    for (var pageIndex = 0; pageIndex < _requestedPages; pageIndex++) {
      ref.invalidate(patientVisitsPageProvider((
        patientId: widget.patient.id,
        offset: pageIndex * _pageSize,
      )));
    }
    ref
      ..invalidate(patientNextVisitProvider(widget.patient.id))
      ..invalidate(patientLastCompletedVisitProvider(widget.patient.id));
    setState(() => _requestedPages = 1);
  }

  Future<void> _openDetails(
    Visit visit,
    CalendarCivilTime calendarTime,
    bool isDesktop,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await CalendarVisitDetailsSurface.show(
        context: context,
        visit: visit,
        selectedDate: calendarTime.civilDayAt(visit.startsAt),
        isDesktop: isDesktop,
        calendarTime: calendarTime,
      );
    } finally {
      if (mounted) {
        _refreshVisits();
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _createVisit() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await QuickCreatePresenter.show(
        context,
        QuickCreateContext(
          intent: QuickCreateIntent.newVisit,
          source: QuickCreateSource.patients,
          patient: widget.patient,
        ),
      );
    } finally {
      if (mounted) {
        _refreshVisits();
        setState(() => _busy = false);
      }
    }
  }
}

class _VisitHistoryRow extends StatelessWidget {
  const _VisitHistoryRow({
    required this.visit,
    required this.calendarTime,
    required this.canOpen,
    required this.onOpen,
    super.key,
  });

  final Visit visit;
  final CalendarCivilTime calendarTime;
  final bool canOpen;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final status = switch (visit.status) {
      VisitStatus.scheduled => 'patientVisitHistory.scheduled'.tr(),
      VisitStatus.completed => 'patientVisitHistory.completed'.tr(),
      VisitStatus.cancelled => 'patientVisitHistory.cancelled'.tr(),
    };
    final statusColor = switch (visit.status) {
      VisitStatus.scheduled => colors.primary,
      VisitStatus.completed => colors.tertiary,
      VisitStatus.cancelled => colors.onSurfaceVariant,
    };
    final date = DateFormat('d MMMM y', context.locale.toLanguageTag())
        .format(calendarTime.displayInstant(visit.startsAt));
    final time = '${calendarTime.clockLabel(visit.startsAt)}–'
        '${calendarTime.clockLabel(visit.endsAt)}';
    final note = visit.note.trim();

    return AppCard(
      onTap: canOpen ? onOpen : null,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              Text('$date · $time', style: AppTextStyles.titleLarge),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  color: statusColor.withValues(alpha: 0.10),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.labelMedium.copyWith(color: statusColor),
                ),
              ),
            ],
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              note,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(
                'patientVisitHistory.open'.tr(),
                style: AppTextStyles.bodyMedium.copyWith(color: colors.primary),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(Icons.arrow_forward_rounded, size: 18, color: colors.primary),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({
    required this.message,
    required this.onBack,
    this.onRetry,
  });

  final String message;
  final VoidCallback onBack;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(message, style: AppTextStyles.titleLarge),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppButton.secondary(
                label: 'patients.retry'.tr(),
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      );
}
