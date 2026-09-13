import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_breakpoints.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../quick_create/domain/quick_create_context.dart';
import '../../quick_create/domain/quick_create_intent.dart';
import '../../quick_create/domain/quick_create_source.dart';
import '../../quick_create/presentation/quick_create_presenter.dart';

enum _CalendarView { day, week, month }

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
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
                    _DayView(isDesktop: isDesktop, onAddVisit: _openNewVisit)
                  else if (_view == _CalendarView.week)
                    _WeekView(
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
                    _MonthView(
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
    final amount = switch (_view) {
      _CalendarView.day => 1,
      _CalendarView.week => 7,
      _CalendarView.month => 30,
    };
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: amount * direction));
    });
  }

  Future<void> _openNewVisit() async {
    await QuickCreatePresenter.show(
      context,
      QuickCreateContext(
        intent: QuickCreateIntent.newVisit,
        source: QuickCreateSource.calendar,
        startsAt: _selectedDate,
        durationMinutes: 30,
      ),
    );
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
    final dateLabel = DateFormat(
      isDesktop ? 'EEEE, d MMMM' : 'd MMMM',
      locale,
    ).format(selectedDate);

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

class _DayView extends StatelessWidget {
  const _DayView({required this.isDesktop, required this.onAddVisit});

  final bool isDesktop;
  final VoidCallback onAddVisit;

  @override
  Widget build(BuildContext context) {
    final schedule = [
      _ScheduleItem.free('09:00', '10:30', 'calendar.freeWindow'),
      _ScheduleItem.visit(
        '10:30',
        '11:30',
        'Anna Brown',
        'calendar.appointmentTypes.consultation',
        AppColors.brand,
      ),
      _ScheduleItem.free('11:30', '13:00', 'calendar.freeWindow'),
      _ScheduleItem.breakTime('13:00', '14:00'),
      _ScheduleItem.visit(
        '14:00',
        '15:30',
        'Michael Wilson',
        'calendar.appointmentTypes.treatment',
        const Color(0xFF6D78C8),
      ),
      _ScheduleItem.free('15:30', '18:00', 'calendar.freeWindow'),
    ];

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CalendarSummary(onAddVisit: onAddVisit, visitCount: 3),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: schedule
                .asMap()
                .entries
                .map(
                  (entry) => _ScheduleRow(
                    item: entry.value,
                    isDesktop: isDesktop,
                    showDivider: entry.key < schedule.length - 1,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );

    if (!isDesktop) return content;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: content),
        const SizedBox(width: AppSpacing.lg),
        const Expanded(flex: 3, child: _DayLegend()),
      ],
    );
  }
}

class _CalendarSummary extends StatelessWidget {
  const _CalendarSummary({required this.onAddVisit, required this.visitCount});

  final VoidCallback onAddVisit;
  final int visitCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'calendar.visitSummary'.tr(args: ['$visitCount']),
            style: AppTextStyles.titleLarge,
          ),
        ),
        TextButton(
          onPressed: onAddVisit,
          child: Text('calendar.blockTime'.tr()),
        ),
      ],
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.item,
    required this.isDesktop,
    required this.showDivider,
  });

  final _ScheduleItem item;
  final bool isDesktop;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isFree = item.kind == _ScheduleKind.free;
    final isBreak = item.kind == _ScheduleKind.breakTime;
    final accentColor = isFree
        ? colorScheme.outlineVariant
        : isBreak
        ? colorScheme.outline
        : item.color!;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isBreak
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.38)
            : null,
        border: Border(
          bottom: showDivider
              ? BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                )
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: isDesktop ? 88 : 72,
            child: Text(
              '${item.start} - ${item.end}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isBreak
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              isFree
                  ? Icons.add_circle_outline_rounded
                  : isBreak
                  ? Icons.pause_circle_outline_rounded
                  : Icons.person_outline_rounded,
              size: 19,
              color: accentColor,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBreak
                      ? 'calendar.break'.tr()
                      : isFree
                      ? item.label.tr()
                      : item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.subtitle!.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isFree)
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}

class _DayLegend extends StatelessWidget {
  const _DayLegend();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('calendar.legend.title'.tr(), style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.md),
          const _LegendItem(
            color: AppColors.brand,
            label: 'calendar.legend.visits',
          ),
          _LegendItem(
            color: Theme.of(context).colorScheme.outlineVariant,
            label: 'calendar.legend.free',
          ),
          _LegendItem(
            color: Theme.of(context).colorScheme.outline,
            label: 'calendar.legend.breaks',
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'calendar.legend.hint'.tr(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(label.tr(), style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class _WeekView extends StatelessWidget {
  const _WeekView({
    required this.isDesktop,
    required this.selectedDate,
    required this.onAddVisit,
    required this.onSelectDay,
  });

  final bool isDesktop;
  final DateTime selectedDate;
  final VoidCallback onAddVisit;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final monday = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );
    final locale = context.locale.toLanguageTag();

    final content = Column(
      children: [
        _CalendarSummary(onAddVisit: onAddVisit, visitCount: 18),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Column(
              children: [
                for (var index = 0; index < 7; index++) ...[
                  _WeekDayRow(
                    date: monday.add(Duration(days: index)),
                    locale: locale,
                    isSelected: DateUtils.isSameDay(
                      monday.add(Duration(days: index)),
                      selectedDate,
                    ),
                    isWeekend:
                        monday.add(Duration(days: index)).weekday >
                        DateTime.friday,
                    summary:
                        monday.add(Duration(days: index)).weekday >
                            DateTime.friday
                        ? 'calendar.weekend'.tr()
                        : index.isEven
                        ? 'calendar.weekSummary'.tr(args: ['2', '3'])
                        : 'calendar.weekSummary'.tr(args: ['4', '2']),
                    onTap: () => onSelectDay(monday.add(Duration(days: index))),
                    showDivider: index < 6,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );

    if (!isDesktop) return content;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: content),
        const SizedBox(width: AppSpacing.lg),
        const Expanded(
          flex: 3,
          child: _CalendarAtAGlance(
            metrics: [
              _GlanceMetric(
                icon: Icons.event_available_outlined,
                value: '18',
                label: 'calendar.glance.weekVisits',
              ),
              _GlanceMetric(
                icon: Icons.schedule_outlined,
                value: '12',
                label: 'calendar.glance.weekFreeWindows',
              ),
              _GlanceMetric(
                icon: Icons.today_outlined,
                value: '5',
                label: 'calendar.glance.weekWorkingDays',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeekDayRow extends StatelessWidget {
  const _WeekDayRow({
    required this.date,
    required this.locale,
    required this.isSelected,
    required this.isWeekend,
    required this.summary,
    required this.onTap,
    required this.showDivider,
  });

  final DateTime date;
  final String locale;
  final bool isSelected;
  final bool isWeekend;
  final String summary;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = isWeekend
        ? colorScheme.onSurfaceVariant
        : colorScheme.primary;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: showDivider
                ? BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                  )
                : BorderSide.none,
          ),
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.55)
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 88,
              child: Text(
                DateFormat('EEE', locale).format(date),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                isWeekend
                    ? Icons.remove_circle_outline_rounded
                    : Icons.calendar_today_outlined,
                size: 19,
                color: accentColor,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('d MMMM', locale).format(date),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    summary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthView extends StatelessWidget {
  const _MonthView({
    required this.isDesktop,
    required this.selectedDate,
    required this.onAddVisit,
    required this.onSelectDay,
  });

  final bool isDesktop;
  final DateTime selectedDate;
  final VoidCallback onAddVisit;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
    final leadingDays = firstDay.weekday - 1;
    final daysInMonth = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
    ).day;
    final cells = List.generate(
      leadingDays + daysInMonth,
      (index) => index < leadingDays
          ? null
          : DateTime(
              selectedDate.year,
              selectedDate.month,
              index - leadingDays + 1,
            ),
    );
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    final locale = context.locale.toLanguageTag();

    final content = Column(
      children: [
        _CalendarSummary(onAddVisit: onAddVisit, visitCount: 74),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Column(
              children: [
                SizedBox(
                  height: 68,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        DateFormat('LLLL yyyy', locale).format(selectedDate),
                        style: AppTextStyles.titleLarge,
                      ),
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                SizedBox(
                  height: 68,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(
                        7,
                        (index) => Expanded(
                          child: Center(
                            child: Text(
                              DateFormat(
                                'EEEEE',
                                locale,
                              ).format(mondayOfWeek(index)),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                ClipRect(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cells.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisExtent: 68,
                        ),
                    itemBuilder: (context, index) {
                      final date = cells[index];
                      final isLastWeek = index >= cells.length - 7;
                      final weekBorder = Border(
                        bottom: isLastWeek
                            ? BorderSide.none
                            : BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant
                                    .withValues(alpha: 0.45),
                              ),
                      );
                      if (date == null) {
                        return DecoratedBox(
                          decoration: BoxDecoration(border: weekBorder),
                          child: const SizedBox.expand(),
                        );
                      }
                      final isSelected = DateUtils.isSameDay(
                        date,
                        selectedDate,
                      );
                      return DecoratedBox(
                        decoration: BoxDecoration(border: weekBorder),
                        child: InkWell(
                          onTap: () => onSelectDay(date),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              child: ColoredBox(
                                color: isSelected
                                    ? Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                    : Colors.transparent,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${date.day}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: date.weekday > DateTime.friday
                                            ? Theme.of(context)
                                                  .colorScheme
                                                  .outlineVariant
                                            : AppColors.brand,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (!isDesktop) return content;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: content),
        const SizedBox(width: AppSpacing.lg),
        const Expanded(
          flex: 3,
          child: _CalendarAtAGlance(
            metrics: [
              _GlanceMetric(
                icon: Icons.event_available_outlined,
                value: '74',
                label: 'calendar.glance.monthVisits',
              ),
              _GlanceMetric(
                icon: Icons.trending_up_rounded,
                value: '82%',
                label: 'calendar.glance.monthLoad',
              ),
              _GlanceMetric(
                icon: Icons.calendar_today_outlined,
                value: '4',
                label: 'calendar.glance.monthBusyDays',
              ),
            ],
          ),
        ),
      ],
    );
  }

  DateTime mondayOfWeek(int weekday) {
    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
    return firstDay
        .subtract(Duration(days: firstDay.weekday - 1))
        .add(Duration(days: weekday));
  }
}

class _CalendarAtAGlance extends StatelessWidget {
  const _CalendarAtAGlance({required this.metrics});

  final List<_GlanceMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('calendar.legend.title'.tr(), style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.md),
          for (final metric in metrics) ...[
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.brand.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(metric.icon, size: 19, color: AppColors.brand),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    metric.label.tr(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  metric.value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (metric != metrics.last) const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _GlanceMetric {
  const _GlanceMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;
}

enum _ScheduleKind { free, visit, breakTime }

class _ScheduleItem {
  const _ScheduleItem({
    required this.kind,
    required this.start,
    required this.end,
    required this.label,
    this.subtitle,
    this.color,
  });

  factory _ScheduleItem.free(String start, String end, String label) =>
      _ScheduleItem(
        kind: _ScheduleKind.free,
        start: start,
        end: end,
        label: label,
      );

  factory _ScheduleItem.visit(
    String start,
    String end,
    String label,
    String subtitle,
    Color color,
  ) => _ScheduleItem(
    kind: _ScheduleKind.visit,
    start: start,
    end: end,
    label: label,
    subtitle: subtitle,
    color: color,
  );

  factory _ScheduleItem.breakTime(String start, String end) => _ScheduleItem(
    kind: _ScheduleKind.breakTime,
    start: start,
    end: end,
    label: 'calendar.break',
  );

  final _ScheduleKind kind;
  final String start;
  final String end;
  final String label;
  final String? subtitle;
  final Color? color;
}
