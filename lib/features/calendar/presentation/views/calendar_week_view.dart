import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/at_a_glance_card.dart';
import '../controllers/calendar_week_controller.dart';
import '../widgets/calendar_summary.dart';
import '../widgets/calendar_week_day_actions_surface.dart';

class CalendarWeekView extends ConsumerWidget {
  const CalendarWeekView({
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
    final week = ref.watch(calendarWeekDataProvider(selectedDate));

    return week.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => const _WeekLoadErrorCard(),
      data: (data) => _WeekContent(
        data: data,
        isDesktop: isDesktop,
        selectedDate: selectedDate,
        onAddVisit: onAddVisit,
        onSelectDay: onSelectDay,
      ),
    );
  }
}

class _WeekContent extends StatelessWidget {
  const _WeekContent({
    required this.data,
    required this.isDesktop,
    required this.selectedDate,
    required this.onAddVisit,
    required this.onSelectDay,
  });

  final CalendarWeekData data;
  final bool isDesktop;
  final DateTime selectedDate;
  final VoidCallback onAddVisit;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.toLanguageTag();
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
              children: data.days
                  .asMap()
                  .entries
                  .map(
                    (entry) => _WeekDayRow(
                      day: entry.value,
                      locale: locale,
                      isToday: DateUtils.isSameDay(
                        entry.value.date,
                        DateTime.now(),
                      ),
                      isDesktop: isDesktop,
                      onTap: () async {
                        final result = await CalendarWeekDayActionsSurface.show(
                          context: context,
                          day: entry.value,
                          weekProviderKey: selectedDate,
                          isDesktop: isDesktop,
                        );

                        if (result == CalendarWeekDayActionResult.openDay) {
                          onSelectDay(entry.value.date);
                        }
                      },
                      showDivider: entry.key < data.days.length - 1,
                    ),
                  )
                  .toList(growable: false),
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
                label: 'calendar.glance.weekVisits',
              ),
              AtAGlanceMetric(
                icon: Icons.schedule_outlined,
                value: '${data.availableWindowCount}',
                label: 'calendar.glance.weekFreeWindows',
              ),
              AtAGlanceMetric(
                icon: Icons.today_outlined,
                value: '${data.workingDayCount}',
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
    required this.day,
    required this.locale,
    required this.isToday,
    required this.isDesktop,
    required this.onTap,
    required this.showDivider,
  });

  final CalendarWeekDayData day;
  final String locale;
  final bool isToday;
  final bool isDesktop;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDayOff = !day.isWorkingDay;
    final accentColor = isDayOff ? colorScheme.outline : colorScheme.primary;
    final visitsLabel = 'calendar.legend.visits'.tr();
    final summary = isDayOff
        ? day.visitCount > 0
              ? '${'calendar.weekend'.tr()} · $visitsLabel: ${day.visitCount}'
              : 'calendar.weekend'.tr()
        : '$visitsLabel: ${day.visitCount} · '
              '${'calendar.glance.weekFreeWindows'.tr()}: '
              '${day.availableWindowCount}';

    final row = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isToday
            ? colorScheme.primary.withValues(alpha: 0.08)
            : isDayOff
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
              DateFormat('EEE', locale).format(day.date),
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDayOff
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
              isDayOff
                  ? Icons.event_busy_outlined
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
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        DateFormat('d MMMM', locale).format(day.date),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'calendar.today'.tr(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
    );

    return Material(
      type: MaterialType.transparency,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

class _WeekLoadErrorCard extends StatelessWidget {
  const _WeekLoadErrorCard();

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
