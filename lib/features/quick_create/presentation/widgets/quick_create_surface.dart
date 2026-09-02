import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/availability_slot.dart';
import '../../domain/clinic.dart';
import '../../domain/patient.dart';
import '../../domain/quick_create_intent.dart';
import '../../domain/quick_create_state.dart';
import '../controllers/quick_create_controller.dart';

class QuickCreateSurface extends StatefulWidget {
  const QuickCreateSurface({
    super.key,
    required this.controller,
    required this.onClose,
    required this.onCompleted,
    this.scrollController,
    this.showDragHandle = false,
  });

  final QuickCreateController controller;
  final VoidCallback onClose;
  final ValueChanged<QuickCreateResult> onCompleted;
  final ScrollController? scrollController;
  final bool showDragHandle;

  @override
  State<QuickCreateSurface> createState() => _QuickCreateSurfaceState();
}

class _QuickCreateSurfaceState extends State<QuickCreateSurface> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;

        return Column(
          key: const Key('quick-create-surface'),
          children: [
            if (widget.showDragHandle) const _DragHandle(),
            _Header(state: state, onClose: widget.onClose),
            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            Expanded(
              child: ListView(
                controller: widget.scrollController,
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  _PatientSection(controller: widget.controller, state: state),
                  if (state.isSchedulingPatient) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      key: const Key('quick-create-visit-fields'),
                      child: Column(
                        children: [
                          _ClinicSection(
                            controller: widget.controller,
                            state: state,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _VisitTimeSection(
                            controller: widget.controller,
                            state: state,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _VisitNoteSection(
                            controller: widget.controller,
                            state: state,
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (state.submitError != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    _ErrorBanner(message: 'quickCreate.errors.saveFailed'.tr()),
                  ],
                ],
              ),
            ),
            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            _Footer(
              controller: widget.controller,
              state: state,
              onClose: widget.onClose,
              onCompleted: widget.onCompleted,
            ),
          ],
        );
      },
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state, required this.onClose});

  final QuickCreateState state;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final titleKey = switch (state.intent) {
      QuickCreateIntent.newPatient => 'quickCreate.newPatient.title',
      QuickCreateIntent.newVisit => 'quickCreate.newVisit.title',
      QuickCreateIntent.nextAvailableSlot =>
        'quickCreate.nextAvailableSlot.title',
    };
    final descriptionKey = switch (state.intent) {
      QuickCreateIntent.newPatient => 'quickCreate.newPatient.description',
      QuickCreateIntent.newVisit => 'quickCreate.newVisit.description',
      QuickCreateIntent.nextAvailableSlot =>
        'quickCreate.nextAvailableSlot.description',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titleKey.tr(), style: AppTextStyles.headlineMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  descriptionKey.tr(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: state.isBusy ? null : onClose,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _PatientSection extends StatelessWidget {
  const _PatientSection({required this.controller, required this.state});

  final QuickCreateController controller;
  final QuickCreateState state;

  @override
  Widget build(BuildContext context) {
    final showDraft =
        state.intent == QuickCreateIntent.newPatient &&
            state.selectedPatient == null ||
        state.isCreatingPatient;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeader(
            icon: Icons.person_outline_rounded,
            titleKey: 'quickCreate.sections.patient',
          ),
          const SizedBox(height: AppSpacing.lg),
          if (state.selectedPatient case final patient?)
            _SelectedPatientTile(
              patient: patient,
              onChange: state.isBusy ? null : controller.clearSelectedPatient,
            )
          else if (showDraft)
            _PatientDraftFields(controller: controller, state: state)
          else ...[
            TextField(
              enabled: !state.isBusy,
              decoration: _inputDecoration(
                context,
                label: 'quickCreate.patient.search'.tr(),
                hintText: 'quickCreate.patient.searchHint'.tr(),
                prefixIcon: const Icon(Icons.search_rounded),
              ),
              onChanged: controller.searchPatients,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (state.isSearchingPatients)
              const Center(child: CircularProgressIndicator())
            else if (state.patientResults.isEmpty)
              Text(
                'quickCreate.patient.noResults'.tr(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            else
              for (final patient in state.patientResults.take(3))
                _PatientResultTile(
                  patient: patient,
                  onTap: () => controller.selectPatient(patient),
                ),
            const SizedBox(height: AppSpacing.sm),
            AppButton.secondary(
              label: 'quickCreate.patient.createInline'.tr(),
              icon: Icons.person_add_outlined,
              fullWidth: true,
              onPressed: state.isBusy ? null : controller.showPatientCreation,
            ),
          ],
          if (state.isCreatingPatient &&
              state.intent != QuickCreateIntent.newPatient) ...[
            const SizedBox(height: AppSpacing.md),
            AppButton.primary(
              label: state.isSavingPatient
                  ? 'quickCreate.actions.saving'.tr()
                  : 'quickCreate.actions.savePatient'.tr(),
              fullWidth: true,
              onPressed: state.canSavePatient && !state.isBusy
                  ? () async {
                      await controller.savePatient(continueToSchedule: true);
                    }
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _PatientDraftFields extends StatelessWidget {
  const _PatientDraftFields({required this.controller, required this.state});

  final QuickCreateController controller;
  final QuickCreateState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          key: const Key('quick-create-patient-name'),
          enabled: !state.isBusy,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            context,
            label: 'quickCreate.patient.name'.tr(),
          ),
          onChanged: (value) => controller.updatePatientDraft(name: value),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          key: const Key('quick-create-patient-phone'),
          enabled: !state.isBusy,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            context,
            label: 'quickCreate.patient.phone'.tr(),
          ),
          onChanged: (value) => controller.updatePatientDraft(phone: value),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          enabled: !state.isBusy,
          textCapitalization: TextCapitalization.sentences,
          minLines: 2,
          maxLines: 3,
          decoration: _inputDecoration(
            context,
            label: 'quickCreate.patient.note'.tr(),
            hintText: 'quickCreate.patient.noteHint'.tr(),
          ),
          onChanged: (value) => controller.updatePatientDraft(note: value),
        ),
      ],
    );
  }
}

class _SelectedPatientTile extends StatelessWidget {
  const _SelectedPatientTile({required this.patient, required this.onChange});

  final Patient patient;
  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            child: Text(patient.name.characters.first.toUpperCase()),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient.name, style: AppTextStyles.titleLarge),
                if (patient.phone.isNotEmpty)
                  Text(
                    patient.phone,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: onChange,
            child: Text('quickCreate.patient.change'.tr()),
          ),
        ],
      ),
    );
  }
}

class _PatientResultTile extends StatelessWidget {
  const _PatientResultTile({required this.patient, required this.onTap});

  final Patient patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.person_outline_rounded),
      title: Text(patient.name),
      subtitle: patient.phone.isEmpty ? null : Text(patient.phone),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _ClinicSection extends StatelessWidget {
  const _ClinicSection({required this.controller, required this.state});

  final QuickCreateController controller;
  final QuickCreateState state;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeader(
            icon: Icons.local_hospital_outlined,
            titleKey: 'quickCreate.sections.clinic',
          ),
          const SizedBox(height: AppSpacing.lg),
          if (state.isLoadingClinics)
            const Center(child: CircularProgressIndicator())
          else if (state.clinics.isNotEmpty)
            DropdownButtonFormField<Clinic>(
              key: ValueKey(state.selectedClinic?.id),
              initialValue: state.selectedClinic,
              decoration: _inputDecoration(
                context,
                label: 'quickCreate.clinic.select'.tr(),
              ),
              items: state.clinics
                  .map(
                    (clinic) => DropdownMenuItem(
                      value: clinic,
                      child: Text(clinic.name),
                    ),
                  )
                  .toList(),
              onChanged: state.isBusy
                  ? null
                  : (clinic) {
                      if (clinic != null) {
                        controller.selectClinic(clinic);
                      }
                    },
            )
          else
            Text(
              'quickCreate.clinic.noClinics'.tr(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          if (state.isCreatingClinic) ...[
            TextFormField(
              enabled: !state.isBusy,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration(
                context,
                label: 'quickCreate.clinic.name'.tr(),
              ),
              onChanged: controller.updateClinicDraft,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton.primary(
              label: state.isSavingClinic
                  ? 'quickCreate.actions.saving'.tr()
                  : 'quickCreate.actions.addClinic'.tr(),
              fullWidth: true,
              onPressed: state.canSaveClinic && !state.isBusy
                  ? controller.saveClinic
                  : null,
            ),
          ] else
            AppButton.secondary(
              label: 'quickCreate.clinic.createInline'.tr(),
              icon: Icons.add_business_outlined,
              fullWidth: true,
              onPressed: state.isBusy ? null : controller.showClinicCreation,
            ),
        ],
      ),
    );
  }
}

class _VisitTimeSection extends StatelessWidget {
  const _VisitTimeSection({required this.controller, required this.state});

  final QuickCreateController controller;
  final QuickCreateState state;

  @override
  Widget build(BuildContext context) {
    final isFixedSlot = state.intent == QuickCreateIntent.nextAvailableSlot;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeader(
            icon: Icons.schedule_rounded,
            titleKey: 'quickCreate.sections.visitTime',
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'quickCreate.visit.duration'.tr(),
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final duration in const [30, 45, 60])
                ChoiceChip(
                  label: Text(
                    'quickCreate.visit.minutes'.tr(
                      namedArgs: {'count': '$duration'},
                    ),
                  ),
                  selected: state.durationMinutes == duration,
                  onSelected: state.isBusy
                      ? null
                      : (_) => controller.setDurationMinutes(duration),
                ),
            ],
          ),
          if (state.selectedStartsAt case final startsAt?) ...[
            const SizedBox(height: AppSpacing.lg),
            _SelectedTimeTile(
              startsAt: startsAt,
              durationMinutes: state.durationMinutes,
            ),
          ],
          if (!isFixedSlot) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'quickCreate.visit.suggestedSlots'.tr(),
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (state.isLoadingSlots)
              const LinearProgressIndicator()
            else
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final slot in state.suggestedSlots)
                    _SlotChip(
                      slot: slot,
                      selected: state.selectedStartsAt == slot.startsAt,
                      onSelected: () => controller.selectSlot(slot),
                    ),
                ],
              ),
            const SizedBox(height: AppSpacing.md),
            AppButton.secondary(
              label: 'quickCreate.visit.manualTime'.tr(),
              icon: Icons.edit_calendar_outlined,
              fullWidth: true,
              onPressed: state.isBusy
                  ? null
                  : () => _pickManualDateTime(context),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickManualDateTime(BuildContext context) async {
    final now = DateTime.now();
    final current = state.selectedStartsAt ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: current.isBefore(now) ? now : current,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date == null || !context.mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );

    if (time == null) {
      return;
    }

    controller.selectStartsAt(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }
}

class _SelectedTimeTile extends StatelessWidget {
  const _SelectedTimeTile({
    required this.startsAt,
    required this.durationMinutes,
  });

  final DateTime startsAt;
  final int durationMinutes;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = context.locale.toLanguageTag();
    final endsAt = startsAt.add(Duration(minutes: durationMinutes));
    final date = DateFormat('EEE, d MMM', locale).format(startsAt);
    final time =
        '${DateFormat.Hm(locale).format(startsAt)} - ${DateFormat.Hm(locale).format(endsAt)}';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Icon(Icons.event_available_rounded, color: colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: AppTextStyles.bodyMedium),
                Text(
                  time,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.selected,
    required this.onSelected,
  });

  final AvailabilitySlot slot;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.toLanguageTag();
    final label = DateFormat('EEE HH:mm', locale).format(slot.startsAt);

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _VisitNoteSection extends StatelessWidget {
  const _VisitNoteSection({required this.controller, required this.state});

  final QuickCreateController controller;
  final QuickCreateState state;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeader(
            icon: Icons.notes_rounded,
            titleKey: 'quickCreate.sections.visitNote',
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            enabled: !state.isBusy,
            textCapitalization: TextCapitalization.sentences,
            minLines: 3,
            maxLines: 5,
            decoration: _inputDecoration(
              context,
              label: 'quickCreate.visit.note'.tr(),
              hintText: 'quickCreate.visit.noteHint'.tr(),
            ),
            onChanged: controller.updateVisitNote,
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.controller,
    required this.state,
    required this.onClose,
    required this.onCompleted,
  });

  final QuickCreateController controller;
  final QuickCreateState state;
  final VoidCallback onClose;
  final ValueChanged<QuickCreateResult> onCompleted;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child:
            state.intent == QuickCreateIntent.newPatient &&
                !state.isSchedulingPatient
            ? Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: state.isSavingPatient
                          ? 'quickCreate.actions.saving'.tr()
                          : 'quickCreate.actions.savePatient'.tr(),
                      fullWidth: true,
                      onPressed: state.canSavePatient && !state.isBusy
                          ? () => _savePatient(continueToSchedule: false)
                          : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton.primary(
                      label: state.isSavingPatient
                          ? 'quickCreate.actions.saving'.tr()
                          : 'quickCreate.actions.saveAndSchedule'.tr(),
                      fullWidth: true,
                      onPressed: state.canSavePatient && !state.isBusy
                          ? () => _savePatient(continueToSchedule: true)
                          : null,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  AppButton.text(
                    label: 'quickCreate.actions.cancel'.tr(),
                    onPressed: state.isBusy ? null : onClose,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton.primary(
                      label: state.isSavingVisit
                          ? 'quickCreate.actions.saving'.tr()
                          : 'quickCreate.actions.createVisit'.tr(),
                      fullWidth: true,
                      onPressed: state.canCreateVisit && !state.isBusy
                          ? _saveVisit
                          : null,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _savePatient({required bool continueToSchedule}) async {
    final result = await controller.savePatient(
      continueToSchedule: continueToSchedule,
    );

    if (result != null && !continueToSchedule) {
      onCompleted(result);
    }
  }

  Future<void> _saveVisit() async {
    final result = await controller.saveVisit();
    if (result != null) {
      onCompleted(result);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.titleKey});

  final IconData icon;
  final String titleKey;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, size: 20, color: colorScheme.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(titleKey.tr(), style: AppTextStyles.titleLarge)),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colorScheme.error),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration(
  BuildContext context, {
  required String label,
  String? hintText,
  Widget? prefixIcon,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.lg),
    borderSide: BorderSide(color: colorScheme.outlineVariant),
  );

  return InputDecoration(
    labelText: label,
    hintText: hintText,
    prefixIcon: prefixIcon,
    filled: true,
    fillColor: colorScheme.surfaceContainerHighest.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.30 : 0.45,
    ),
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: BorderSide(color: colorScheme.primary, width: 2),
    ),
    errorBorder: border.copyWith(
      borderSide: BorderSide(color: colorScheme.error),
    ),
    focusedErrorBorder: border.copyWith(
      borderSide: BorderSide(color: colorScheme.error, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
  );
}
