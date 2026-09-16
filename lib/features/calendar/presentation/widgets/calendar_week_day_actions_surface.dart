import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../scheduling/presentation/providers/availability_provider.dart';
import '../controllers/calendar_day_controller.dart';
import '../controllers/calendar_week_controller.dart';

enum CalendarWeekDayActionResult { openDay }

class CalendarWeekDayActionsSurface extends ConsumerStatefulWidget {
  const CalendarWeekDayActionsSurface({
    super.key,
    required this.day,
    required this.weekProviderKey,
    required this.isDesktop,
  });

  final CalendarWeekDayData day;
  final DateTime weekProviderKey;
  final bool isDesktop;

  static Future<CalendarWeekDayActionResult?> show({
    required BuildContext context,
    required CalendarWeekDayData day,
    required DateTime weekProviderKey,
    required bool isDesktop,
  }) {
    if (isDesktop) {
      return showDialog<CalendarWeekDayActionResult>(
        context: context,
        builder: (context) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: CalendarWeekDayActionsSurface(
              day: day,
              weekProviderKey: weekProviderKey,
              isDesktop: true,
            ),
          ),
        ),
      );
    }

    return showModalBottomSheet<CalendarWeekDayActionResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => CalendarWeekDayActionsSurface(
        day: day,
        weekProviderKey: weekProviderKey,
        isDesktop: false,
      ),
    );
  }

  @override
  ConsumerState<CalendarWeekDayActionsSurface> createState() =>
      _CalendarWeekDayActionsSurfaceState();
}

class _CalendarWeekDayActionsSurfaceState
    extends ConsumerState<CalendarWeekDayActionsSurface> {
  bool _isBusy = false;
  String? _errorMessage;

  Future<void> _setDayOff(bool isDayOff) async {
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(scheduleDayExceptionRepositoryProvider)
          .setWorkingDay(
            day: widget.day.date,
            isWorkingDay: !isDayOff,
          );

      ref.invalidate(profileVisitAvailabilityRepositoryProvider);
      ref.invalidate(calendarDayAvailabilityProvider(widget.day.date));
      ref.invalidate(calendarWeekDataProvider(widget.weekProviderKey));

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = context.locale.toLanguageTag();
    final isDayOff = !widget.day.isWorkingDay;
    final dateLabel = DateFormat(
      'EEEE, d MMMM',
      locale,
    ).format(widget.day.date);
    final visitsLabel = 'calendar.legend.visits'.tr();

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
                  isDayOff
                      ? Icons.event_busy_outlined
                      : Icons.calendar_today_outlined,
                  color: isDayOff
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateLabel, style: AppTextStyles.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$visitsLabel: ${widget.day.visitCount}',
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'calendar.weekend'.tr(),
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isBusy)
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              else
                Switch(
                  value: isDayOff,
                  onChanged: _setDayOff,
                ),
            ],
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _errorMessage!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton.secondary(
            label: 'calendar.views.day'.tr(),
            icon: Icons.open_in_new_rounded,
            fullWidth: true,
            onPressed: _isBusy
                ? null
                : () => Navigator.of(context).pop(
                      CalendarWeekDayActionResult.openDay,
                    ),
          ),
        ],
      ),
    );

    if (widget.isDesktop) {
      return content;
    }

    return SingleChildScrollView(child: content);
  }
}
