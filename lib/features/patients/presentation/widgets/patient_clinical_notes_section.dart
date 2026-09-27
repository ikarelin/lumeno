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
import '../../../clinical_notes/domain/create_patient_clinical_note_input.dart';
import '../../../clinical_notes/domain/patient_clinical_note.dart';
import '../../../clinical_notes/presentation/providers/patient_clinical_note_provider.dart';
import '../../../scheduling/domain/calendar_civil_time.dart';
import '../../../scheduling/presentation/providers/doctor_time_mode.dart';
import '../../../visits/domain/visit.dart';
import '../../../visits/presentation/providers/patient_visits_provider.dart';
import '../../../visits/presentation/providers/visit_provider.dart';

class PatientClinicalNotesSection extends ConsumerStatefulWidget {
  const PatientClinicalNotesSection({
    required this.patientId,
    required this.enabled,
    super.key,
  });

  final String patientId;
  final bool enabled;

  @override
  ConsumerState<PatientClinicalNotesSection> createState() =>
      _PatientClinicalNotesSectionState();
}

class _PatientClinicalNotesSectionState
    extends ConsumerState<PatientClinicalNotesSection> {
  static const _pageSize = 30;

  int _requestedPages = 1;
  bool _busy = false;
  final Map<String, Visit> _linkedVisits = <String, Visit>{};
  final Set<String> _resolvingVisitIds = <String>{};
  final Set<String> _missingVisitIds = <String>{};
  final Set<String> _failedVisitIds = <String>{};

  @override
  void didUpdateWidget(covariant PatientClinicalNotesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patientId == widget.patientId) return;
    _requestedPages = 1;
    _linkedVisits.clear();
    _resolvingVisitIds.clear();
    _missingVisitIds.clear();
    _failedVisitIds.clear();
  }

  @override
  Widget build(BuildContext context) {
    final calendarTimeState = ref.watch(calendarCivilTimeProvider);
    final calendarTime = calendarTimeState.asData?.value;
    final notes = <PatientClinicalNote>[];
    PatientClinicalNotesPageKey? pendingKey;
    AsyncValue<List<PatientClinicalNote>>? pendingState;
    var canLoadMore = false;

    for (var pageIndex = 0; pageIndex < _requestedPages; pageIndex++) {
      final key = (
        patientId: widget.patientId,
        offset: pageIndex * _pageSize,
      );
      final page = ref.watch(patientClinicalNotesPageProvider(key));
      if (page.isLoading || page.hasError || !page.hasValue) {
        pendingKey = key;
        pendingState = page;
        break;
      }
      final rows = page.requireValue;
      notes.addAll(rows);
      canLoadMore = rows.length == _pageSize;
      if (!canLoadMore) {
        break;
      }
    }

    final linkedIds = notes
        .map((note) => note.visitId)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveLinkedVisits(linkedIds);
    });

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            onCreate: widget.enabled && !_busy ? _openCreateNote : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (pendingState != null && notes.isEmpty)
            pendingState.isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : _ErrorState(
                    label: 'clinicalNotes.loadFailed'.tr(),
                    onRetry: () {
                      ref.invalidate(
                        patientClinicalNotesPageProvider(pendingKey!),
                      );
                    },
                  )
          else if (notes.isEmpty)
            _EmptyState(enabled: widget.enabled, onCreate: _openCreateNote)
          else ...[
            for (var index = 0; index < notes.length; index++) ...[
              _NoteRow(
                note: notes[index],
                linkedVisit: notes[index].visitId == null
                    ? null
                    : _linkedVisits[notes[index].visitId],
                calendarTime: calendarTime,
                visitLoadFailed: notes[index].visitId != null &&
                    _failedVisitIds.contains(notes[index].visitId),
                visitUnavailable: notes[index].visitId != null &&
                    _missingVisitIds.contains(notes[index].visitId),
                enabled: widget.enabled && !_busy,
                onOpenNote: () => _openNote(notes[index], calendarTime),
                onOpenVisit: notes[index].visitId == null ||
                        calendarTime == null ||
                        _linkedVisits[notes[index].visitId] == null
                    ? null
                    : () {
                        _openLinkedVisit(notes[index], calendarTime);
                      },
                onRetryVisit: notes[index].visitId != null &&
                        _failedVisitIds.contains(notes[index].visitId)
                    ? () => _retryLinkedVisit(notes[index].visitId!)
                    : null,
              ),
              if (index != notes.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Divider(
                    height: 1,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
            ],
            if (pendingState != null) ...[
              const SizedBox(height: AppSpacing.lg),
              pendingState.isLoading
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : _ErrorState(
                      label: 'clinicalNotes.loadMoreFailed'.tr(),
                      onRetry: () {
                        ref.invalidate(
                          patientClinicalNotesPageProvider(pendingKey!),
                        );
                      },
                    ),
            ] else if (canLoadMore) ...[
              const SizedBox(height: AppSpacing.lg),
              Align(
                alignment: Alignment.center,
                child: AppButton.secondary(
                  label: 'clinicalNotes.loadMore'.tr(),
                  onPressed: widget.enabled && !_busy
                      ? () => setState(() => _requestedPages += 1)
                      : null,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _openCreateNote() async {
    if (_busy || !widget.enabled) return;
    setState(() => _busy = true);
    try {
      final isDesktop =
          MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;
      final created = isDesktop
          ? await showDialog<bool>(
              context: context,
              builder: (context) => Dialog(
                insetPadding: const EdgeInsets.all(AppSpacing.xl),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: _CreateClinicalNoteSurface(
                    patientId: widget.patientId,
                  ),
                ),
              ),
            )
          : await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (context) => Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: _CreateClinicalNoteSurface(
                  patientId: widget.patientId,
                ),
              ),
            );
      if (created == true && mounted) {
        _refreshNotes();
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _openNote(
    PatientClinicalNote note,
    CalendarCivilTime? calendarTime,
  ) async {
    if (_busy || !widget.enabled) return;
    setState(() => _busy = true);
    try {
      final visit = note.visitId == null ? null : _linkedVisits[note.visitId];
      final isDesktop =
          MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;
      final content = _ClinicalNoteDetails(
        note: note,
        linkedVisit: visit,
        calendarTime: calendarTime,
        onOpenVisit: visit == null || calendarTime == null
            ? null
            : () => _showVisitDetails(visit, calendarTime),
      );
      if (isDesktop) {
        await showDialog<void>(
          context: context,
          builder: (context) => Dialog(
            insetPadding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: content,
            ),
          ),
        );
      } else {
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (context) => content,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _retryLinkedVisit(String visitId) async {
    if (_busy || !widget.enabled) return;
    setState(() {
      _busy = true;
      _failedVisitIds.remove(visitId);
      _missingVisitIds.remove(visitId);
    });
    try {
      await _resolveLinkedVisits(<String>{visitId});
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openLinkedVisit(
    PatientClinicalNote note,
    CalendarCivilTime? calendarTime,
  ) async {
    if (_busy || !widget.enabled || calendarTime == null) return;
    final visitId = note.visitId;
    if (visitId == null) return;
    final visit = _linkedVisits[visitId];
    if (visit == null) return;
    setState(() => _busy = true);
    try {
      await _showVisitDetails(visit, calendarTime);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showVisitDetails(
    Visit visit,
    CalendarCivilTime calendarTime,
  ) async {
    final isDesktop =
        MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;
    await CalendarVisitDetailsSurface.show(
      context: context,
      visit: visit,
      selectedDate: calendarTime.civilDayAt(visit.startsAt),
      isDesktop: isDesktop,
      calendarTime: calendarTime,
    );
    if (mounted) _refreshNotes();
  }

  Future<void> _resolveLinkedVisits(Set<String> requestedIds) async {
    final patientId = widget.patientId;
    final ownedIds = requestedIds
        .where(
          (id) =>
              !_linkedVisits.containsKey(id) &&
              !_resolvingVisitIds.contains(id) &&
              !_missingVisitIds.contains(id) &&
              !_failedVisitIds.contains(id),
        )
        .toSet();
    if (ownedIds.isEmpty || !mounted) return;

    final unresolved = ownedIds.toSet();
    _resolvingVisitIds.addAll(ownedIds);
    try {
      final repository = ref.read(patientVisitQueryRepositoryProvider);
      var offset = 0;
      const pageSize = 100;
      while (unresolved.isNotEmpty) {
        final page = await repository.fetchPatientVisitsPage(
          patientId: patientId,
          offset: offset,
          pageSize: pageSize,
        );
        if (!mounted || widget.patientId != patientId) return;

        for (final visit in page) {
          if (unresolved.remove(visit.id)) {
            _linkedVisits[visit.id] = visit;
            _failedVisitIds.remove(visit.id);
            _missingVisitIds.remove(visit.id);
          }
        }
        if (page.length < pageSize) {
          break;
        }
        offset += pageSize;
      }
      _missingVisitIds.addAll(unresolved);
    } catch (_) {
      if (mounted && widget.patientId == patientId) {
        _failedVisitIds.addAll(unresolved);
      }
    } finally {
      _resolvingVisitIds.removeAll(ownedIds);
      if (mounted && widget.patientId == patientId) {
        setState(() {});
      }
    }
  }

  void _refreshNotes() {
    for (var pageIndex = 0; pageIndex < _requestedPages; pageIndex++) {
      ref.invalidate(
        patientClinicalNotesPageProvider((
          patientId: widget.patientId,
          offset: pageIndex * _pageSize,
        )),
      );
    }
    ref.invalidate(patientClinicalNotesProvider(widget.patientId));
    setState(() {
      _requestedPages = 1;
      _linkedVisits.clear();
      _resolvingVisitIds.clear();
      _missingVisitIds.clear();
      _failedVisitIds.clear();
    });
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.onCreate});

  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            Icons.medical_information_outlined,
            size: 20,
            color: colors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            'clinicalNotes.title'.tr(),
            style: AppTextStyles.titleLarge,
          ),
        ),
        AppButton.secondary(
          label: 'clinicalNotes.newNote'.tr(),
          icon: Icons.add_rounded,
          onPressed: onCreate,
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.enabled, required this.onCreate});

  final bool enabled;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'clinicalNotes.empty'.tr(),
          style: AppTextStyles.bodyMedium.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton.secondary(
          label: 'clinicalNotes.newNote'.tr(),
          icon: Icons.add_rounded,
          onPressed: enabled ? onCreate : null,
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.label, required this.onRetry});

  final String label;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          AppButton.secondary(
            label: 'patients.retry'.tr(),
            onPressed: onRetry,
          ),
        ],
      );
}

class _NoteRow extends StatelessWidget {
  const _NoteRow({
    required this.note,
    required this.linkedVisit,
    required this.calendarTime,
    required this.visitLoadFailed,
    required this.visitUnavailable,
    required this.enabled,
    required this.onOpenNote,
    required this.onOpenVisit,
    required this.onRetryVisit,
  });

  final PatientClinicalNote note;
  final Visit? linkedVisit;
  final CalendarCivilTime? calendarTime;
  final bool visitLoadFailed;
  final bool visitUnavailable;
  final bool enabled;
  final VoidCallback onOpenNote;
  final VoidCallback? onOpenVisit;
  final VoidCallback? onRetryVisit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final createdLabel = calendarTime == null
        ? 'clinicalNotes.dateUnavailable'.tr()
        : DateFormat(
            'd MMM y, HH:mm',
            context.locale.toLanguageTag(),
          ).format(calendarTime!.displayInstant(note.createdAt));
    final visitLabel = note.visitId == null
        ? 'clinicalNotes.general'.tr()
        : visitLoadFailed
            ? 'clinicalNotes.visitsLoadFailed'.tr()
            : visitUnavailable
                ? 'clinicalNotes.linkedVisitUnavailable'.tr()
                : linkedVisit == null || calendarTime == null
                    ? 'clinicalNotes.linkedVisit'.tr()
                    : '${'clinicalNotes.linkedVisit'.tr()} · '
                        '${DateFormat('d MMM y', context.locale.toLanguageTag()).format(calendarTime!.displayInstant(linkedVisit!.startsAt))}';
    final visitAction = visitLoadFailed ? onRetryVisit : onOpenVisit;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: enabled ? onOpenNote : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  createdLabel,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const Text('·', style: AppTextStyles.labelMedium),
                InkWell(
                  onTap: enabled && visitAction != null ? visitAction : null,
                  child: Text(
                    visitLabel,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: note.visitId != null && visitAction != null
                          ? colors.primary
                          : colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              note.body,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateClinicalNoteSurface extends ConsumerStatefulWidget {
  const _CreateClinicalNoteSurface({
    required this.patientId,
  });

  final String patientId;

  @override
  ConsumerState<_CreateClinicalNoteSurface> createState() =>
      _CreateClinicalNoteSurfaceState();
}

class _CreateClinicalNoteSurfaceState
    extends ConsumerState<_CreateClinicalNoteSurface> {
  static const _pageSize = 30;
  static const _generalValue = '__general__';

  final _bodyController = TextEditingController();
  int _requestedVisitPages = 1;
  String _selectedVisitValue = _generalValue;
  bool _saving = false;

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calendarTimeState = ref.watch(calendarCivilTimeProvider);
    final calendarTime = calendarTimeState.asData?.value;
    final visits = <Visit>[];
    PatientVisitsPageKey? pendingKey;
    AsyncValue<List<Visit>>? pendingState;
    var canLoadMore = false;

    if (calendarTime != null) {
      for (var pageIndex = 0; pageIndex < _requestedVisitPages; pageIndex++) {
        final key = (
          patientId: widget.patientId,
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
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'clinicalNotes.createTitle'.tr(),
                  style: AppTextStyles.titleLarge,
                ),
              ),
              IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: _saving ? null : () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'clinicalNotes.createDescription'.tr(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
            initialValue: _selectedVisitValue,
            decoration: InputDecoration(
              labelText: 'clinicalNotes.visitContext'.tr(),
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem<String>(
                value: _generalValue,
                child: Text('clinicalNotes.general'.tr()),
              ),
              for (final visit in visits)
                DropdownMenuItem<String>(
                  value: visit.id,
                  child: Text(_visitLabel(context, visit, calendarTime!)),
                ),
            ],
            onChanged: _saving || calendarTime == null
                ? null
                : (value) {
                    if (value != null) {
                      setState(() => _selectedVisitValue = value);
                    }
                  },
          ),
          if (calendarTimeState.isLoading) ...[
            const SizedBox(height: AppSpacing.sm),
            const LinearProgressIndicator(),
          ] else if (calendarTimeState.hasError) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _saving
                    ? null
                    : () => ref.invalidate(calendarCivilTimeProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: Text('patientVisitHistory.timeFailed'.tr()),
              ),
            ),
          ],
          if (pendingState != null) ...[
            const SizedBox(height: AppSpacing.sm),
            if (pendingState.isLoading)
              const LinearProgressIndicator()
            else
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _saving
                      ? null
                      : () => ref.invalidate(
                            patientVisitsPageProvider(pendingKey!),
                          ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text('clinicalNotes.visitsLoadFailed'.tr()),
                ),
              ),
          ] else if (canLoadMore) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _saving
                    ? null
                    : () => setState(() => _requestedVisitPages += 1),
                child: Text('clinicalNotes.loadMoreVisits'.tr()),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _bodyController,
            enabled: !_saving,
            minLines: 6,
            maxLines: 12,
            maxLength: CreatePatientClinicalNoteInput.maxBodyCodePoints,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'clinicalNotes.body'.tr(),
              hintText: 'clinicalNotes.bodyHint'.tr(),
              alignLabelWithHint: true,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton.secondary(
                label: 'patients.cancel'.tr(),
                onPressed:
                    _saving ? null : () => Navigator.of(context).pop(false),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppButton.primary(
                label: _saving
                    ? 'clinicalNotes.saving'.tr()
                    : 'clinicalNotes.save'.tr(),
                onPressed: _canSave(calendarTime) ? _save : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _canSave(CalendarCivilTime? calendarTime) =>
      !_saving &&
      _bodyController.text.trim().isNotEmpty &&
      (_selectedVisitValue == _generalValue || calendarTime != null);

  String _visitLabel(
    BuildContext context,
    Visit visit,
    CalendarCivilTime calendarTime,
  ) {
    final instant = calendarTime.displayInstant(visit.startsAt);
    final date = DateFormat(
      'd MMM y',
      context.locale.toLanguageTag(),
    ).format(instant);
    final time = calendarTime.clockLabel(visit.startsAt);
    return '$date · $time';
  }

  Future<void> _save() async {
    final calendarTime = ref.read(calendarCivilTimeProvider).asData?.value;
    if (!_canSave(calendarTime)) return;
    setState(() => _saving = true);
    try {
      final repository = ref.read(patientClinicalNoteRepositoryProvider);
      await repository.create(
        CreatePatientClinicalNoteInput(
          patientId: widget.patientId,
          visitId: _selectedVisitValue == _generalValue
              ? null
              : _selectedVisitValue,
          body: _bodyController.text,
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('clinicalNotes.saveFailed'.tr())),
        );
      setState(() => _saving = false);
    }
  }
}

class _ClinicalNoteDetails extends StatelessWidget {
  const _ClinicalNoteDetails({
    required this.note,
    required this.linkedVisit,
    required this.calendarTime,
    required this.onOpenVisit,
  });

  final PatientClinicalNote note;
  final Visit? linkedVisit;
  final CalendarCivilTime? calendarTime;
  final Future<void> Function()? onOpenVisit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final created = calendarTime == null
        ? 'clinicalNotes.dateUnavailable'.tr()
        : DateFormat(
            'd MMMM y, HH:mm',
            context.locale.toLanguageTag(),
          ).format(calendarTime!.displayInstant(note.createdAt));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'clinicalNotes.detailsTitle'.tr(),
                  style: AppTextStyles.titleLarge,
                ),
              ),
              IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            created,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SelectableText(note.body, style: AppTextStyles.bodyMedium),
          if (note.visitId != null) ...[
            const SizedBox(height: AppSpacing.xl),
            AppButton.secondary(
              label: linkedVisit == null
                  ? 'clinicalNotes.linkedVisitUnavailable'.tr()
                  : 'clinicalNotes.openVisit'.tr(),
              icon: Icons.event_note_outlined,
              onPressed: linkedVisit == null || onOpenVisit == null
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        onOpenVisit!();
                      });
                    },
            ),
          ],
        ],
      ),
    );
  }
}
