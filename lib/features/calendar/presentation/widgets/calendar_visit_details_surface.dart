import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../visits/domain/visit.dart';
import '../controllers/calendar_day_actions_controller.dart';
import '../controllers/calendar_day_controller.dart';

class CalendarVisitDetailsSurface extends ConsumerStatefulWidget {
  const CalendarVisitDetailsSurface({
    super.key,
    required this.visit,
    required this.selectedDate,
    required this.isDesktop,
  });

  final Visit visit;
  final DateTime selectedDate;
  final bool isDesktop;

  static Future<void> show({
    required BuildContext context,
    required Visit visit,
    required DateTime selectedDate,
    required bool isDesktop,
  }) {
    if (isDesktop) {
      return showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: CalendarVisitDetailsSurface(
              visit: visit,
              selectedDate: selectedDate,
              isDesktop: true,
            ),
          ),
        ),
      );
    }

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: CalendarVisitDetailsSurface(
          visit: visit,
          selectedDate: selectedDate,
          isDesktop: false,
        ),
      ),
    );
  }

  @override
  ConsumerState<CalendarVisitDetailsSurface> createState() =>
      _CalendarVisitDetailsSurfaceState();
}

class _CalendarVisitDetailsSurfaceState
    extends ConsumerState<CalendarVisitDetailsSurface> {
  late Visit _visit;
  late final TextEditingController _noteController;

  bool _isEditing = false;
  bool _isBusy = false;
  _DestructiveAction? _pendingAction;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _visit = widget.visit;
    _noteController = TextEditingController(text: _visit.note);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      final updated = await ref
          .read(calendarDayActionsControllerProvider)
          .updateVisitNote(visit: _visit, note: _noteController.text);

      ref.invalidate(calendarDayVisitsProvider(widget.selectedDate));

      if (!mounted) {
        return;
      }

      setState(() {
        _visit = updated;
        _noteController.text = updated.note;
        _isEditing = false;
        _isBusy = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isBusy = false;
        _errorMessage = 'quickCreate.errors.saveFailed'.tr();
      });
    }
  }

  Future<void> _runDestructiveAction() async {
    final action = _pendingAction;
    if (action == null) {
      return;
    }

    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      final controller = ref.read(calendarDayActionsControllerProvider);

      switch (action) {
        case _DestructiveAction.cancel:
          await controller.cancelVisit(_visit);
          break;
        case _DestructiveAction.delete:
          await controller.deleteVisit(_visit);
          break;
      }

      ref.invalidate(calendarDayVisitsProvider(widget.selectedDate));
      ref.invalidate(calendarDayAvailabilityProvider(widget.selectedDate));

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isBusy = false;
        _errorMessage = 'quickCreate.errors.saveFailed'.tr();
      });
    }
  }

  void _startEditing() {
    setState(() {
      _noteController.text = _visit.note;
      _isEditing = true;
      _pendingAction = null;
      _errorMessage = null;
    });
  }

  void _cancelEditing() {
    FocusScope.of(context).unfocus();
    setState(() {
      _noteController.text = _visit.note;
      _isEditing = false;
      _errorMessage = null;
    });
  }

  void _requestDestructiveAction(_DestructiveAction action) {
    setState(() {
      _pendingAction = action;
      _isEditing = false;
      _noteController.text = _visit.note;
      _errorMessage = null;
    });
  }

  void _dismissPendingAction() {
    setState(() {
      _pendingAction = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = context.locale.toLanguageTag();
    final dateLabel = DateFormat('EEEE, d MMMM', locale).format(_visit.startsAt);
    final timeLabel =
        '${DateFormat.Hm(locale).format(_visit.startsAt)} - '
        '${DateFormat.Hm(locale).format(_visit.endsAt)}';

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.person_outline_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _visit.patientName ?? _visit.patientId,
                      style: AppTextStyles.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      dateLabel,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _isBusy ? null : () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _VisitMetaTile(
            icon: Icons.schedule_rounded,
            value: timeLabel,
          ),
          const SizedBox(height: AppSpacing.sm),
          _VisitMetaTile(
            icon: Icons.timelapse_rounded,
            value: 'quickCreate.visit.minutes'.tr(
              namedArgs: {'count': '${_visit.durationMinutes}'},
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_pendingAction != null)
            _buildDestructiveConfirmation(colorScheme)
          else if (_isEditing)
            _buildEditForm(colorScheme)
          else
            _buildReadOnlyContent(colorScheme),
          if (_errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _errorMessage!,
              style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.error),
            ),
          ],
        ],
      ),
    );

    if (widget.isDesktop) {
      return content;
    }

    return SingleChildScrollView(child: content);
  }

  Widget _buildReadOnlyContent(ColorScheme colorScheme) {
    final note = _visit.note.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (note.isNotEmpty) ...[
          Text(
            'quickCreate.visit.note'.tr(),
            style: AppTextStyles.labelMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(note, style: AppTextStyles.bodyLarge),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (widget.isDesktop)
          Row(
            children: [
              AppButton.secondary(
                label: 'patients.edit'.tr(),
                icon: Icons.edit_outlined,
                onPressed: _isBusy ? null : _startEditing,
              ),
              const Spacer(),
              _DestructiveTextButton(
                label: 'patients.cancel'.tr(),
                icon: Icons.event_busy_outlined,
                onPressed: _isBusy
                    ? null
                    : () => _requestDestructiveAction(
                        _DestructiveAction.cancel,
                      ),
              ),
              const SizedBox(width: AppSpacing.xs),
              _DestructiveTextButton(
                label: 'clinicManagement.delete'.tr(),
                icon: Icons.delete_outline_rounded,
                onPressed: _isBusy
                    ? null
                    : () => _requestDestructiveAction(
                        _DestructiveAction.delete,
                      ),
              ),
            ],
          )
        else ...[
          AppButton.secondary(
            label: 'patients.edit'.tr(),
            icon: Icons.edit_outlined,
            fullWidth: true,
            onPressed: _isBusy ? null : _startEditing,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _DestructiveTextButton(
                  label: 'patients.cancel'.tr(),
                  icon: Icons.event_busy_outlined,
                  onPressed: _isBusy
                      ? null
                      : () => _requestDestructiveAction(
                          _DestructiveAction.cancel,
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _DestructiveTextButton(
                  label: 'clinicManagement.delete'.tr(),
                  icon: Icons.delete_outline_rounded,
                  onPressed: _isBusy
                      ? null
                      : () => _requestDestructiveAction(
                          _DestructiveAction.delete,
                        ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildEditForm(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _noteController,
          enabled: !_isBusy,
          minLines: 3,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: 'quickCreate.visit.note'.tr(),
            hintText: 'quickCreate.visit.noteHint'.tr(),
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (widget.isDesktop)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton.secondary(
                label: 'patients.cancel'.tr(),
                onPressed: _isBusy ? null : _cancelEditing,
              ),
              const SizedBox(width: AppSpacing.sm),
              AppButton.primary(
                label: _isBusy
                    ? 'patients.saving'.tr()
                    : 'patients.saveChanges'.tr(),
                onPressed: _isBusy ? null : _saveNote,
              ),
            ],
          )
        else ...[
          AppButton.primary(
            label: _isBusy
                ? 'patients.saving'.tr()
                : 'patients.saveChanges'.tr(),
            fullWidth: true,
            onPressed: _isBusy ? null : _saveNote,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton.secondary(
            label: 'patients.cancel'.tr(),
            fullWidth: true,
            onPressed: _isBusy ? null : _cancelEditing,
          ),
        ],
      ],
    );
  }

  Widget _buildDestructiveConfirmation(ColorScheme colorScheme) {
    final action = _pendingAction!;
    final isDelete = action == _DestructiveAction.delete;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                isDelete
                    ? Icons.delete_outline_rounded
                    : Icons.event_busy_outlined,
                color: colorScheme.error,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '${_visit.patientName ?? _visit.patientId} • '
                  '${DateFormat.Hm(context.locale.toLanguageTag()).format(_visit.startsAt)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: _isBusy ? null : _dismissPendingAction,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            onPressed: _isBusy ? null : _runDestructiveAction,
            icon: Icon(
              isDelete
                  ? Icons.delete_outline_rounded
                  : Icons.event_busy_outlined,
            ),
            label: Text(
              isDelete
                  ? 'clinicManagement.delete'.tr()
                  : 'patients.cancel'.tr(),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitMetaTile extends StatelessWidget {
  const _VisitMetaTile({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}

class _DestructiveTextButton extends StatelessWidget {
  const _DestructiveTextButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(foregroundColor: colorScheme.error),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

enum _DestructiveAction { cancel, delete }
