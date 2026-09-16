import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../scheduling/domain/availability_interval.dart';
import '../../../visits/domain/visit.dart';
import '../controllers/calendar_day_controller.dart';
import '../models/calendar_day_timeline_item.dart';
import '../widgets/calendar_summary.dart';
import '../widgets/calendar_visit_details_surface.dart';

class CalendarDayView extends ConsumerWidget {
  const CalendarDayView({
    super.key,
    required this.selectedDate,
    required this.isDesktop,
    required this.onAddVisit,
    required this.onAddVisitAt,
    required this.onOverrideAvailability,
  });

  final DateTime selectedDate;
  final bool isDesktop;
  final VoidCallback onAddVisit;
  final ValueChanged<DateTime> onAddVisitAt;
  final ValueChanged<AvailabilityInterval> onOverrideAvailability;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visits = ref.watch(calendarDayVisitsProvider(selectedDate));
    final availability = ref.watch(
      calendarDayAvailabilityProvider(selectedDate),
    );
    final locale = context.locale.toLanguageTag();
    final scheduledVisits = visits is AsyncData<List<Visit>>
        ? visits.value
              .where((visit) => visit.status == VisitStatus.scheduled)
              .toList(growable: false)
        : const <Visit>[];

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CalendarSummary(
          onAddVisit: onAddVisit,
          visitCount: scheduledVisits.length,
        ),
        const SizedBox(height: AppSpacing.md),
        visits.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _LoadErrorCard(),
          data: (items) {
            return availability.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _LoadErrorCard(),
              data: (dayAvailability) {
                final timeline = buildCalendarDayTimeline(
                  visits: items,
                  availability: dayAvailability,
                );

                if (timeline.isEmpty) {
                  return AppCard(
                    child: Text(
                      'calendar.noVisits'.tr(),
                      style: AppTextStyles.bodyLarge,
                    ),
                  );
                }

                final schedule = timeline
                    .map(
                      (item) => _ScheduleItem.fromTimeline(
                        item,
                        locale: locale,
                        patientLabel: 'calendar.patient'.tr(),
                      ),
                    )
                    .toList(growable: false);

                return AppCard(
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
                            onTap: switch (entry.value.kind) {
                              _ScheduleKind.free => () {
                                  onAddVisitAt(entry.value.startsAt);
                                },
                              _ScheduleKind.visit => () {
                                  CalendarVisitDetailsSurface.show(
                                    context: context,
                                    visit: entry.value.visit!,
                                    selectedDate: selectedDate,
                                    isDesktop: isDesktop,
                                  );
                                },
                              _ScheduleKind.breakTime ||
                              _ScheduleKind.dayOff => () {
                                  onOverrideAvailability(
                                    AvailabilityInterval(
                                      startsAt: entry.value.startsAt,
                                      endsAt: entry.value.endsAt,
                                    ),
                                  );
                                },
                            },
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            );
          },
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

class _LoadErrorCard extends StatelessWidget {
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

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.item,
    required this.isDesktop,
    required this.showDivider,
    this.onTap,
  });

  final _ScheduleItem item;
  final bool isDesktop;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isFree = item.kind == _ScheduleKind.free;
    final isBreak = item.kind == _ScheduleKind.breakTime;
    final isDayOff = item.kind == _ScheduleKind.dayOff;
    final isVisit = item.kind == _ScheduleKind.visit;
    final isSoftUnavailable = isBreak || isDayOff;
    final accentColor = isFree
        ? colorScheme.outlineVariant
        : isSoftUnavailable
        ? colorScheme.outline
        : item.color!;

    final row = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isVisit
            ? accentColor.withValues(alpha: 0.08)
            : isSoftUnavailable
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
                color: isSoftUnavailable
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
                  : isDayOff
                  ? Icons.event_busy_outlined
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
                      : isDayOff
                      ? 'calendar.weekend'.tr()
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
                    item.kind == _ScheduleKind.visit
                        ? item.subtitle!
                        : item.subtitle!.tr(),
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
          if (isFree || isSoftUnavailable || item.kind == _ScheduleKind.visit)
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );

    if (onTap == null) {
      return row;
    }

    return Material(
      type: MaterialType.transparency,
      child: InkWell(onTap: onTap, child: row),
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

enum _ScheduleKind { free, visit, breakTime, dayOff }

class _ScheduleItem {
  const _ScheduleItem({
    required this.kind,
    required this.startsAt,
    required this.endsAt,
    required this.start,
    required this.end,
    required this.label,
    this.subtitle,
    this.color,
    this.visit,
  });

  factory _ScheduleItem.fromTimeline(
    CalendarDayTimelineItem item, {
    required String locale,
    required String patientLabel,
  }) {
    final start = DateFormat('HH:mm', locale).format(item.startsAt);
    final end = DateFormat('HH:mm', locale).format(item.endsAt);

    return switch (item.kind) {
      CalendarDayTimelineItemKind.free => _ScheduleItem(
          kind: _ScheduleKind.free,
          startsAt: item.startsAt,
          endsAt: item.endsAt,
          start: start,
          end: end,
          label: 'calendar.legend.free',
        ),
      CalendarDayTimelineItemKind.breakTime => _ScheduleItem(
          kind: _ScheduleKind.breakTime,
          startsAt: item.startsAt,
          endsAt: item.endsAt,
          start: start,
          end: end,
          label: 'calendar.break',
        ),
      CalendarDayTimelineItemKind.dayOff => _ScheduleItem(
          kind: _ScheduleKind.dayOff,
          startsAt: item.startsAt,
          endsAt: item.endsAt,
          start: start,
          end: end,
          label: 'calendar.weekend',
        ),
      CalendarDayTimelineItemKind.visit => _ScheduleItem(
          kind: _ScheduleKind.visit,
          startsAt: item.startsAt,
          endsAt: item.endsAt,
          start: start,
          end: end,
          label:
              '$patientLabel ${item.visit!.patientName ?? item.visit!.patientId}',
          subtitle: item.visit!.note.trim().isEmpty
              ? null
              : item.visit!.note.trim(),
          color: AppColors.brand,
          visit: item.visit,
        ),
    };
  }

  final _ScheduleKind kind;
  final DateTime startsAt;
  final DateTime endsAt;
  final String start;
  final String end;
  final String label;
  final String? subtitle;
  final Color? color;
  final Visit? visit;
}