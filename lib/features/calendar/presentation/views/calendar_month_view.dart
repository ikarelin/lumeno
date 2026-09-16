import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/at_a_glance_card.dart';
import '../controllers/calendar_month_controller.dart';
import '../widgets/calendar_summary.dart';

class CalendarMonthView extends ConsumerWidget {
  const CalendarMonthView({
    super.key,
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
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(calendarMonthDataProvider(selectedDate));

    return month.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => const _MonthLoadErrorCard(),
      data: (data) => _MonthContent(
        data: data,
        isDesktop: isDesktop,
        onAddVisit: onAddVisit,
        onSelectDay: onSelectDay,
      ),
    );
  }
}

class _MonthContent extends StatelessWidget {
  const _MonthContent({
    required this.data,
    required this.isDesktop,
    required this.onAddVisit,
    required this.onSelectDay,
  });

  final CalendarMonthData data;
  final bool isDesktop;
  final VoidCallback onAddVisit;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.toLanguageTag();
    final leadingDays = data.firstDay.weekday - DateTime.monday;
    final cells = <CalendarMonthDayData?>[
      ...List<CalendarMonthDayData?>.filled(leadingDays, null),
      ...data.days,
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CalendarSummary(
          onAddVisit: onAddVisit,
          visitCount: data.visitCount,
        ),
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
                        DateFormat('LLLL yyyy', locale).format(data.firstDay),
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
                              ).format(_mondayOfWeek(data.firstDay, index)),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
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
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cells.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisExtent: 68,
                  ),
                  itemBuilder: (context, index) {
                    final day = cells[index];
                    final isLastWeek = index >= cells.length - 7;
                    final showDivider = !isLastWeek;
                    if (day == null) {
                      return _EmptyMonthCell(showDivider: showDivider);
                    }

                    return _MonthDayCell(
                      day: day,
                      isToday: DateUtils.isSameDay(day.date, DateTime.now()),
                      showDivider: showDivider,
                      onTap: () => onSelectDay(day.date),
                    );
                  },
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
        Expanded(
          flex: 3,
          child: AtAGlanceCard(
            title: 'calendar.legend.title',
            metrics: [
              AtAGlanceMetric(
                icon: Icons.event_available_outlined,
                value: '${data.visitCount}',
                label: 'calendar.glance.monthVisits',
              ),
              AtAGlanceMetric(
                icon: Icons.today_outlined,
                value: '${data.workingDayCount}',
                label: 'calendar.glance.weekWorkingDays',
              ),
              AtAGlanceMetric(
                icon: Icons.calendar_today_outlined,
                value: '${data.busyDayCount}',
                label: 'calendar.glance.monthBusyDays',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MonthDayCell extends StatelessWidget {
  const _MonthDayCell({
    required this.day,
    required this.isToday,
    required this.showDivider,
    required this.onTap,
  });

  final CalendarMonthDayData day;
  final bool isToday;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDayOff = !day.isWorkingDay;

    final cell = Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: showDivider
              ? BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                )
              : BorderSide.none,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: ColoredBox(
            color: isToday
                ? colorScheme.primary.withValues(alpha: 0.08)
                : isDayOff
                    ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.32)
                    : Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${day.date.day}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDayOff
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  height: 16,
                  child: day.visitCount > 0
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.brand,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${day.visitCount}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : isDayOff
                          ? Icon(
                              Icons.remove_rounded,
                              size: 14,
                              color: colorScheme.outline,
                            )
                          : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: InkWell(onTap: onTap, child: cell),
    );
  }
}

class _EmptyMonthCell extends StatelessWidget {
  const _EmptyMonthCell({required this.showDivider});

  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: showDivider
              ? BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.45),
                )
              : BorderSide.none,
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _MonthLoadErrorCard extends StatelessWidget {
  const _MonthLoadErrorCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Text(
        'calendar.loadError'.tr(),
        style: AppTextStyles.bodyMedium.copyWith(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}

DateTime _mondayOfWeek(DateTime firstDay, int weekday) {
  return firstDay
      .subtract(Duration(days: firstDay.weekday - DateTime.monday))
      .add(Duration(days: weekday));
}
