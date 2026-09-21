import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_breakpoints.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/availability_repository.dart';
import '../../domain/availability_slot.dart';
import '../../domain/calendar_civil_time.dart';

const _pickerSlotLimit = 4096;

Future<AvailabilitySlot?> showAvailabilityDateTimePicker({
  required BuildContext context,
  required AvailabilityRepository availabilityRepository,
  required int durationMinutes,
  required String title,
  required String timesLabel,
  DateTime? initialStartsAt,
  CalendarCivilTime calendarTime = const CalendarCivilTime(),
  int searchHorizonDays = 30,
}) {
  assert(searchHorizonDays > 0);

  final from = DateTime.now();
  final isDesktop =
      MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;

  AvailabilityDateTimePicker buildPicker(BuildContext pickerContext) {
    return AvailabilityDateTimePicker(
      availabilityRepository: availabilityRepository,
      durationMinutes: durationMinutes,
      from: from,
      initialStartsAt: initialStartsAt,
      calendarTime: calendarTime,
      searchHorizonDays: searchHorizonDays,
      title: title,
      timesLabel: timesLabel,
      onSelected: (slot) => Navigator.of(pickerContext).pop(slot),
      onClose: () => Navigator.of(pickerContext).pop(),
    );
  }

  if (isDesktop) {
    return showDialog<AvailabilitySlot>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(AppSpacing.lg),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 760,
              maxHeight: 640,
            ),
            child: buildPicker(dialogContext),
          ),
        );
      },
    );
  }

  return showModalBottomSheet<AvailabilitySlot>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final height = MediaQuery.sizeOf(sheetContext).height * 0.9;

      return SizedBox(height: height, child: buildPicker(sheetContext));
    },
  );
}

/// Availability-first date/time selector used by scheduling flows.
///
/// Unlike a generic time picker, this control exposes only starts returned by
/// [AvailabilityRepository]. A doctor cannot intentionally select a past,
/// off-hours, break, or already occupied start through this UI. Database
/// overlap protection remains the final race-condition guard at save time.
class AvailabilityDateTimePicker extends StatefulWidget {
  const AvailabilityDateTimePicker({
    super.key,
    required this.availabilityRepository,
    required this.durationMinutes,
    required this.from,
    required this.title,
    required this.timesLabel,
    required this.onSelected,
    required this.onClose,
    this.initialStartsAt,
    this.calendarTime = const CalendarCivilTime(),
    this.searchHorizonDays = 30,
  }) : assert(searchHorizonDays > 0);

  final AvailabilityRepository availabilityRepository;
  final int durationMinutes;
  final DateTime from;
  final DateTime? initialStartsAt;
  final CalendarCivilTime calendarTime;
  final int searchHorizonDays;
  final String title;
  final String timesLabel;
  final ValueChanged<AvailabilitySlot> onSelected;
  final VoidCallback onClose;

  @override
  State<AvailabilityDateTimePicker> createState() =>
      _AvailabilityDateTimePickerState();
}

class _AvailabilityDateTimePickerState
    extends State<AvailabilityDateTimePicker> {
  Map<DateTime, List<AvailabilitySlot>> _slotsByDay = const {};
  DateTime? _selectedDay;
  DateTime? _visibleMonth;
  Object? _loadError;
  var _isLoading = true;

  DateTime get _firstDay => _localDay(widget.from);

  DateTime get _rangeEnd => DateTime(
    _firstDay.year,
    _firstDay.month,
    _firstDay.day + widget.searchHorizonDays,
  );

  DateTime get _lastDay => DateTime(
    _firstDay.year,
    _firstDay.month,
    _firstDay.day + widget.searchHorizonDays - 1,
  );

  DateTime get _endInstantExclusive => widget.calendarTime.doctorTime == null
      ? _rangeEnd
      : widget.calendarTime.visitQueryRange(
          firstCivilDay: _firstDay,
          endExclusiveCivilDay: _rangeEnd,
        ).endUtc;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  @override
  void didUpdateWidget(covariant AvailabilityDateTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.durationMinutes != widget.durationMinutes ||
        oldWidget.from != widget.from ||
        oldWidget.searchHorizonDays != widget.searchHorizonDays ||
        oldWidget.availabilityRepository != widget.availabilityRepository ||
        oldWidget.calendarTime != widget.calendarTime) {
      _loadAvailability();
    }
  }

  Future<void> _loadAvailability() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final slots = await widget.availabilityRepository.findAvailableSlots(
        from: widget.from,
        durationMinutes: widget.durationMinutes,
        limit: _pickerSlotLimit,
      );

      final inRange = slots
          .where((slot) => !slot.startsAt.isBefore(widget.from))
          .where((slot) => slot.startsAt.isBefore(_endInstantExclusive))
          .toList(growable: false)
        ..sort((left, right) => left.startsAt.compareTo(right.startsAt));

      final grouped = <DateTime, List<AvailabilitySlot>>{};

      for (final slot in inRange) {
        final day = widget.calendarTime.civilDayAt(slot.startsAt);
        grouped.putIfAbsent(day, () => <AvailabilitySlot>[]).add(slot);
      }

      final initialDay = widget.initialStartsAt == null
          ? null
          : widget.calendarTime.civilDayAt(widget.initialStartsAt!);

      final selectedDay = initialDay != null && grouped.containsKey(initialDay)
          ? initialDay
          : grouped.keys.firstOrNull;

      if (!mounted) {
        return;
      }

      final immutableGrouped = <DateTime, List<AvailabilitySlot>>{
        for (final entry in grouped.entries)
          entry.key: List<AvailabilitySlot>.unmodifiable(entry.value),
      };

      setState(() {
        _slotsByDay =
            Map<DateTime, List<AvailabilitySlot>>.unmodifiable(immutableGrouped);
        _selectedDay = selectedDay;
        _visibleMonth = selectedDay == null
            ? null
            : DateTime(selectedDay.year, selectedDay.month);
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint(
        'AvailabilityDateTimePicker failed to load availability: $error',
      );
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      setState(() {
        _slotsByDay = const {};
        _selectedDay = null;
        _visibleMonth = null;
        _loadError = error;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PickerHeader(title: widget.title, onClose: widget.onClose),
          Divider(height: 1, color: colorScheme.outlineVariant),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return _PickerUnavailableState(
        title: widget.timesLabel,
        icon: Icons.error_outline_rounded,
        onRetry: _loadAvailability,
      );
    }

    if (_slotsByDay.isEmpty) {
      return _PickerUnavailableState(
        title: widget.timesLabel,
        icon: Icons.event_busy_outlined,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns = constraints.maxWidth >= 640;

        if (useTwoColumns) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: 380, child: _buildCalendar(context)),
              VerticalDivider(
                width: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              Expanded(child: _buildTimes(context)),
            ],
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCalendar(context),
              Divider(
                height: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              _buildTimes(context, shrinkWrap: true),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: _AvailabilityCalendar(
        visibleMonth: _visibleMonth!,
        selectedDay: _selectedDay!,
        firstDay: _firstDay,
        lastDay: _lastDay,
        today: widget.calendarTime.civilDayAt(DateTime.now()),
        availableDays: _slotsByDay.keys.toSet(),
        onVisibleMonthChanged: (month) {
          setState(() {
            _visibleMonth = month;
          });
        },
        onDaySelected: (day) {
          setState(() {
            _selectedDay = day;
          });
        },
      ),
    );
  }

  Widget _buildTimes(BuildContext context, {bool shrinkWrap = false}) {
    final selectedDay = _selectedDay!;
    final slots = _slotsByDay[selectedDay] ?? const <AvailabilitySlot>[];
    final locale = Localizations.localeOf(context).toLanguageTag();
    final colorScheme = Theme.of(context).colorScheme;
    final selectedDateLabel = DateFormat('EEE, d MMM', locale).format(
      selectedDay,
    );

    final content = Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            selectedDateLabel,
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.timesLabel,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final slot in slots)
                _TimeOption(
                  slot: slot,
                  calendarTime: widget.calendarTime,
                  selected: widget.initialStartsAt != null &&
                      slot.startsAt == widget.initialStartsAt,
                  onPressed: () => widget.onSelected(slot),
                ),
            ],
          ),
        ],
      ),
    );

    if (shrinkWrap) {
      return content;
    }

    return SingleChildScrollView(child: content);
  }

  DateTime _localDay(DateTime value) => widget.calendarTime.civilDayAt(value);
}


class _AvailabilityCalendar extends StatelessWidget {
  const _AvailabilityCalendar({
    required this.visibleMonth,
    required this.selectedDay,
    required this.firstDay,
    required this.lastDay,
    required this.today,
    required this.availableDays,
    required this.onVisibleMonthChanged,
    required this.onDaySelected,
  });

  final DateTime visibleMonth;
  final DateTime selectedDay;
  final DateTime firstDay;
  final DateTime lastDay;
  final DateTime today;
  final Set<DateTime> availableDays;
  final ValueChanged<DateTime> onVisibleMonthChanged;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final material = MaterialLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final previousMonth = DateTime(visibleMonth.year, visibleMonth.month - 1);
    final nextMonth = DateTime(visibleMonth.year, visibleMonth.month + 1);
    final firstVisibleMonth = DateTime(firstDay.year, firstDay.month);
    final lastVisibleMonth = DateTime(lastDay.year, lastDay.month);
    final canGoPrevious = !previousMonth.isBefore(firstVisibleMonth);
    final canGoNext = !nextMonth.isAfter(lastVisibleMonth);
    final firstOfMonth = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final daysInMonth = DateTime(
      visibleMonth.year,
      visibleMonth.month + 1,
      0,
    ).day;
    final firstWeekdayIndex = firstOfMonth.weekday % 7;
    final leadingEmptyDays =
        (firstWeekdayIndex - material.firstDayOfWeekIndex + 7) % 7;
    final cellCount = ((leadingEmptyDays + daysInMonth + 6) ~/ 7) * 7;
    final weekdayLabels = <String>[];

    for (var offset = 0; offset < 7; offset++) {
      final index = (material.firstDayOfWeekIndex + offset) % 7;
      weekdayLabels.add(material.narrowWeekdays[index]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                DateFormat.yMMMM(locale).format(visibleMonth),
                style: AppTextStyles.titleLarge,
              ),
            ),
            IconButton(
              tooltip: material.previousMonthTooltip,
              onPressed: canGoPrevious
                  ? () => onVisibleMonthChanged(previousMonth)
                  : null,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            IconButton(
              tooltip: material.nextMonthTooltip,
              onPressed: canGoNext
                  ? () => onVisibleMonthChanged(nextMonth)
                  : null,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (final label in weekdayLabels)
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cellCount,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final dayNumber = index - leadingEmptyDays + 1;

            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox.shrink();
            }

            final day = DateTime(
              visibleMonth.year,
              visibleMonth.month,
              dayNumber,
            );
            final isAvailable = availableDays.contains(day);
            final isSelected = DateUtils.isSameDay(day, selectedDay);
            final isToday = DateUtils.isSameDay(day, today);

            return _CalendarDayButton(
              day: day,
              isAvailable: isAvailable,
              isSelected: isSelected,
              isToday: isToday,
              onPressed: isAvailable ? () => onDaySelected(day) : null,
            );
          },
        ),
      ],
    );
  }
}

class _CalendarDayButton extends StatelessWidget {
  const _CalendarDayButton({
    required this.day,
    required this.isAvailable,
    required this.isSelected,
    required this.isToday,
    required this.onPressed,
  });

  final DateTime day;
  final bool isAvailable;
  final bool isSelected;
  final bool isToday;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isSelected
        ? colorScheme.primary
        : isAvailable
        ? colorScheme.primaryContainer.withValues(alpha: 0.45)
        : Colors.transparent;
    final foregroundColor = isSelected
        ? colorScheme.onPrimary
        : isAvailable
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.38);

    return Semantics(
      button: true,
      enabled: isAvailable,
      selected: isSelected,
      label: DateFormat.yMMMMEEEEd(locale).format(day),
      child: Center(
        child: SizedBox(
          width: 38,
          height: 38,
          child: Material(
            color: backgroundColor,
            shape: CircleBorder(
              side: isToday && !isSelected
                  ? BorderSide(color: colorScheme.primary)
                  : BorderSide.none,
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: foregroundColor,
                    fontWeight: isSelected || isToday
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerHeader extends StatelessWidget {
  const _PickerHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.titleLarge,
            ),
          ),
          IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _PickerUnavailableState extends StatelessWidget {
  const _PickerUnavailableState({
    required this.title,
    required this.icon,
    this.onRetry,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              IconButton(
                tooltip: MaterialLocalizations.of(
                  context,
                ).refreshIndicatorSemanticLabel,
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimeOption extends StatelessWidget {
  const _TimeOption({
    required this.slot,
    required this.calendarTime,
    required this.selected,
    required this.onPressed,
  });

  final AvailabilitySlot slot;
  final CalendarCivilTime calendarTime;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final startLabel = calendarTime.clockLabel(slot.startsAt);
    final endLabel = calendarTime.clockLabel(slot.endsAt);
    final slotKey = ValueKey<String>(
      'availability-time-${slot.startsAt.toIso8601String()}',
    );

    return Semantics(
      button: true,
      selected: selected,
      label: '$startLabel–$endLabel',
      child: SizedBox(
        width: startLabel.contains(' UTC') ? 164 : 96,
        height: 44,
        child: OutlinedButton(
          key: slotKey,
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: selected ? colorScheme.primaryContainer : null,
            foregroundColor: selected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface,
            side: BorderSide(
              color: selected ? colorScheme.primary : colorScheme.outlineVariant,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          child: Text(startLabel),
        ),
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}
