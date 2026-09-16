import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_breakpoints.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../quick_create/domain/quick_create_context.dart';
import '../../quick_create/domain/quick_create_intent.dart';
import '../../quick_create/domain/quick_create_source.dart';
import '../../quick_create/presentation/quick_create_presenter.dart';
import '../../scheduling/domain/availability_interval.dart';
import '../../scheduling/presentation/providers/availability_provider.dart';
import 'controllers/calendar_day_controller.dart';
import 'controllers/calendar_month_controller.dart';
import 'controllers/calendar_week_controller.dart';
import 'views/calendar_day_view.dart';
import 'views/calendar_month_view.dart';
import 'views/calendar_week_view.dart';

enum _CalendarView { day, week, month }

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _selectedDate = DateTime.now();
  _CalendarView _view = _CalendarView.day;

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CalendarHeader(
                    selectedDate: _selectedDate,
                    view: _view,
                    isDesktop: isDesktop,
                    onToday: _goToToday,
                    onPrevious: () => _shiftDate(-1),
                    onNext: () => _shiftDate(1),
                    onViewChanged: (view) => setState(() => _view = view),
                    onAddVisit: _openNewVisit,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (_view == _CalendarView.day)
                    CalendarDayView(
                      selectedDate: _selectedDate,
                      isDesktop: isDesktop,
                      onAddVisit: _openNewVisit,
                      onAddVisitAt: _openNewVisitAt,
                      onOverrideAvailability: _openOverrideVisit,
                    )
                  else if (_view == _CalendarView.week)
                    CalendarWeekView(
                      isDesktop: isDesktop,
                      selectedDate: _selectedDate,
                      onAddVisit: _openNewVisit,
                      onSelectDay: (date) {
                        setState(() {
                          _selectedDate = date;
                          _view = _CalendarView.day;
                        });
                      },
                    )
                  else
                    CalendarMonthView(
                      isDesktop: isDesktop,
                      selectedDate: _selectedDate,
                      onAddVisit: _openNewVisit,
                      onSelectDay: (date) {
                        setState(() {
                          _selectedDate = date;
                          _view = _CalendarView.day;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _goToToday() => setState(() => _selectedDate = DateTime.now());

  void _shiftDate(int direction) {
    setState(() {
      _selectedDate = switch (_view) {
        _CalendarView.day => _selectedDate.add(Duration(days: direction)),
        _CalendarView.week => _selectedDate.add(Duration(days: 7 * direction)),
        _CalendarView.month => _shiftCalendarMonth(_selectedDate, direction),
      };
    });
  }

  Future<void> _openNewVisit() {
    return _openNewVisitAt(_selectedDate);
  }

  Future<void> _openNewVisitAt(DateTime startsAt) async {
    await QuickCreatePresenter.show(
      context,
      QuickCreateContext(
        intent: QuickCreateIntent.newVisit,
        source: QuickCreateSource.calendar,
        startsAt: startsAt,
      ),
    );
    ref.invalidate(calendarDayVisitsProvider(_selectedDate));
    ref.invalidate(calendarDayAvailabilityProvider(_selectedDate));
    ref.invalidate(calendarWeekDataProvider(_selectedDate));
    ref.invalidate(calendarMonthDataProvider(_selectedDate));
  }

  Future<void> _openOverrideVisit(
    AvailabilityInterval allowedInterval,
  ) async {
    final overrideRepository = ref.read(
      visitOnlyAvailabilityRepositoryProvider(allowedInterval),
    );

    await QuickCreatePresenter.show(
      context,
      const QuickCreateContext(
        intent: QuickCreateIntent.newVisit,
        source: QuickCreateSource.calendar,
      ),
      availabilityRepositoryOverride: overrideRepository,
    );
    ref.invalidate(calendarDayVisitsProvider(_selectedDate));
    ref.invalidate(calendarDayAvailabilityProvider(_selectedDate));
    ref.invalidate(calendarWeekDataProvider(_selectedDate));
    ref.invalidate(calendarMonthDataProvider(_selectedDate));
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.selectedDate,
    required this.view,
    required this.isDesktop,
    required this.onToday,
    required this.onPrevious,
    required this.onNext,
    required this.onViewChanged,
    required this.onAddVisit,
  });

  final DateTime selectedDate;
  final _CalendarView view;
  final bool isDesktop;
  final VoidCallback onToday;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<_CalendarView> onViewChanged;
  final VoidCallback onAddVisit;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.toLanguageTag();
    final dateLabel = _calendarHeaderDateLabel(
      selectedDate: selectedDate,
      view: view,
      locale: locale,
      isDesktop: isDesktop,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'calendar.title'.tr(),
                    style: isDesktop
                        ? AppTextStyles.headlineLarge
                        : AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    dateLabel,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'calendar.previous'.tr(),
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            IconButton(
              tooltip: 'calendar.next'.tr(),
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
            if (isDesktop) ...[
              AppButton.secondary(
                label: 'calendar.today'.tr(),
                onPressed: onToday,
              ),
              const SizedBox(width: AppSpacing.sm),
              AppButton.primary(
                label: 'calendar.newVisit'.tr(),
                icon: Icons.add_rounded,
                onPressed: onAddVisit,
              ),
            ] else
              IconButton.filled(
                tooltip: 'calendar.newVisit'.tr(),
                onPressed: onAddVisit,
                icon: const Icon(Icons.add_rounded),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: SegmentedButton<_CalendarView>(
                segments: [
                  ButtonSegment(
                    value: _CalendarView.day,
                    label: Text('calendar.views.day'.tr()),
                    icon: const Icon(Icons.view_agenda_outlined),
                  ),
                  ButtonSegment(
                    value: _CalendarView.week,
                    label: Text('calendar.views.week'.tr()),
                    icon: const Icon(Icons.view_week_outlined),
                  ),
                  ButtonSegment(
                    value: _CalendarView.month,
                    label: Text('calendar.views.month'.tr()),
                    icon: const Icon(Icons.calendar_month_outlined),
                  ),
                ],
                selected: {view},
                onSelectionChanged: (selection) {
                  onViewChanged(selection.first);
                },
              ),
            ),
            if (!isDesktop) ...[
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                tooltip: 'calendar.today'.tr(),
                onPressed: onToday,
                icon: const Icon(Icons.today_outlined),
              ),
            ],
          ],
        ),
      ],
    );
  }
}


String _calendarHeaderDateLabel({
  required DateTime selectedDate,
  required _CalendarView view,
  required String locale,
  required bool isDesktop,
}) {
  return switch (view) {
    _CalendarView.day => DateFormat(
        isDesktop ? 'EEEE, d MMMM' : 'd MMMM',
        locale,
      ).format(selectedDate),
    _CalendarView.week => _calendarWeekRangeLabel(
        selectedDate: selectedDate,
        locale: locale,
      ),
    _CalendarView.month => DateFormat(
        'LLLL yyyy',
        locale,
      ).format(selectedDate),
  };
}

String _calendarWeekRangeLabel({
  required DateTime selectedDate,
  required String locale,
}) {
  final day = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );
  final monday = day.subtract(
    Duration(days: day.weekday - DateTime.monday),
  );
  final sunday = monday.add(const Duration(days: 6));

  if (monday.year != sunday.year) {
    return '${DateFormat('d MMMM yyyy', locale).format(monday)} – '
        '${DateFormat('d MMMM yyyy', locale).format(sunday)}';
  }

  if (monday.month != sunday.month) {
    return '${DateFormat('d MMMM', locale).format(monday)} – '
        '${DateFormat('d MMMM', locale).format(sunday)}';
  }

  return '${DateFormat('d', locale).format(monday)}–'
      '${DateFormat('d MMMM', locale).format(sunday)}';
}

DateTime _shiftCalendarMonth(DateTime date, int direction) {
  final targetMonth = DateTime(date.year, date.month + direction, 1);
  final lastDay = DateTime(targetMonth.year, targetMonth.month + 1, 0).day;
  final targetDay = date.day > lastDay ? lastDay : date.day;

  return DateTime(targetMonth.year, targetMonth.month, targetDay);
}
