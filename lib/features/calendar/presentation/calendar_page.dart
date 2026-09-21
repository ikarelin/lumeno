import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
import '../../scheduling/presentation/providers/doctor_time_mode.dart';
import '../../scheduling/presentation/widgets/doctor_time_zone_required_view.dart';
import 'calendar_date_navigation.dart';
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
  DateTime? _selectedDate;
  _CalendarView _view = _CalendarView.day;

  @override
  Widget build(BuildContext context) {
    final calendarTimeState = ref.watch(calendarCivilTimeProvider);
    final calendarTime = calendarTimeState.asData?.value;
    if (calendarTime == null) {
      return Scaffold(
        body: Center(
          child: calendarTimeState.asError?.error is DoctorTimeZoneNotConfigured
              ? DoctorTimeZoneRequiredView(
                  onOpenProfile: () => context.go('/profile'),
                )
              : calendarTimeState.hasError
                  ? Text('calendar.loadError'.tr())
                  : const CircularProgressIndicator(),
        ),
      );
    }

    final navigation = CalendarDateNavigation(calendarTime);
    // Initialize only after the presentation zone has been resolved. Never
    // initialize a doctor-local date from the device clock's date fields.
    final selectedDate = _selectedDate ??= navigation.today(DateTime.now());
    final today = navigation.today(DateTime.now());
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
                    selectedDate: selectedDate,
                    view: _view,
                    isDesktop: isDesktop,
                    onToday: () => _goToToday(navigation),
                    onPrevious: () => _shiftDate(-1, navigation),
                    onNext: () => _shiftDate(1, navigation),
                    onViewChanged: (view) => setState(() => _view = view),
                    onAddVisit: _openNewVisit,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (_view == _CalendarView.day)
                    CalendarDayView(
                      selectedDate: selectedDate,
                      isDesktop: isDesktop,
                      onAddVisit: _openNewVisit,
                      onAddVisitAt: _openNewVisitAt,
                      onOverrideAvailability: _openOverrideVisit,
                    )
                  else if (_view == _CalendarView.week)
                    CalendarWeekView(
                      isDesktop: isDesktop,
                      selectedDate: selectedDate,
                      today: today,
                      onAddVisit: _openNewVisit,
                      onSelectDay: (date) {
                        setState(() {
                          _selectedDate = navigation.selectDay(date);
                          _view = _CalendarView.day;
                        });
                      },
                    )
                  else
                    CalendarMonthView(
                      isDesktop: isDesktop,
                      selectedDate: selectedDate,
                      today: today,
                      onAddVisit: _openNewVisit,
                      onSelectDay: (date) {
                        setState(() {
                          _selectedDate = navigation.selectDay(date);
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

  void _goToToday(CalendarDateNavigation navigation) {
    setState(() => _selectedDate = navigation.today(DateTime.now()));
  }

  void _shiftDate(int direction, CalendarDateNavigation navigation) {
    final selectedDate = _selectedDate!;
    final unit = switch (_view) {
      _CalendarView.day => CalendarNavigationUnit.day,
      _CalendarView.week => CalendarNavigationUnit.week,
      _CalendarView.month => CalendarNavigationUnit.month,
    };
    setState(() {
      _selectedDate = navigation.shift(
        selectedDate,
        unit: unit,
        direction: direction,
      );
    });
  }

  // A selected calendar day is not an appointment instant. Let Quick Create
  // request an available slot instead of seeding a synthetic midnight.
  Future<void> _openNewVisit() => _openNewVisitAt(null);

  Future<void> _openNewVisitAt(DateTime? startsAt) async {
    await QuickCreatePresenter.show(
      context,
      QuickCreateContext(
        intent: QuickCreateIntent.newVisit,
        source: QuickCreateSource.calendar,
        startsAt: startsAt,
      ),
    );
    if (!mounted) return;
    _refreshCalendar();
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
    if (!mounted) return;
    _refreshCalendar();
  }

  void _refreshCalendar() {
    final date = _selectedDate;
    if (date == null) return;
    ref.invalidate(calendarDayVisitsProvider(date));
    ref.invalidate(calendarDayAvailabilityProvider(date));
    ref.invalidate(calendarWeekDataProvider(date));
    ref.invalidate(calendarMonthDataProvider(date));
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
