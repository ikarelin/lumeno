import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_breakpoints.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_section_title.dart';
import '../../../calendar/presentation/widgets/calendar_visit_details_surface.dart';
import '../../../quick_create/domain/quick_create_context.dart';
import '../../../quick_create/domain/quick_create_intent.dart';
import '../../../quick_create/domain/quick_create_source.dart';
import '../../../quick_create/presentation/quick_create_presenter.dart';
import '../../../scheduling/domain/availability_slot.dart';
import '../../../visits/domain/visit.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/dashboard_available_slot_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_next_visit_card.dart';
import '../widgets/dashboard_primary_cards.dart';
import '../widgets/dashboard_upcoming_visits.dart';
import '../widgets/quick_actions.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  static const _contentMaxWidth = 1120.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop =
        MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;
    final visits = ref.watch(dashboardVisitsProvider);
    final availability = ref.watch(dashboardAvailabilityProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DashboardHeader(),
                  const SizedBox(height: AppSpacing.xl),
                  DashboardPrimaryCards(
                    nextVisitCard: _buildNextVisitCard(
                      context,
                      ref,
                      visits,
                      isDesktop: isDesktop,
                    ),
                    availableSlotCard: _buildAvailableSlotCard(
                      context,
                      ref,
                      availability,
                    ),
                  ),
                  if (isDesktop) ...[
                    const SizedBox(height: AppSpacing.xl),
                    AppSectionTitle(
                      title: 'dashboard.upcomingVisits'.tr(),
                      actionLabel: 'dashboard.viewAll'.tr(),
                      onActionTap: () => context.go('/calendar'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildUpcomingVisits(
                      context,
                      ref,
                      visits,
                      isDesktop: isDesktop,
                    ),
                  ],
                  if (!isDesktop) ...[
                    const SizedBox(height: AppSpacing.xl),
                    AppSectionTitle(title: 'dashboard.quickActions'.tr()),
                    const SizedBox(height: AppSpacing.md),
                    QuickActions(
                      onNewPatient: () {
                        QuickCreatePresenter.show(
                          context,
                          const QuickCreateContext(
                            intent: QuickCreateIntent.newPatient,
                            source:
                                QuickCreateSource.mobileDashboardQuickAction,
                          ),
                        );
                      },
                      onNewVisit: () => _openNewVisit(context, ref),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextVisitCard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<DashboardVisitsData> visits, {
    required bool isDesktop,
  }) {
    return visits.when(
      loading: () => const DashboardNextVisitCard(isLoading: true),
      error: (_, _) => DashboardNextVisitCard(
        isError: true,
        message: 'calendar.loadError'.tr(),
        actionLabel: 'patients.retry'.tr(),
        onAction: () => ref.invalidate(dashboardVisitsProvider),
      ),
      data: (data) {
        final visit = data.nextVisit;

        if (visit == null) {
          return DashboardNextVisitCard(
            message: 'dashboard.noUpcomingVisits'.tr(),
            actionLabel: 'dashboard.quickActionsItems.newVisit.title'.tr(),
            onAction: () => _openNewVisit(context, ref),
          );
        }

        return DashboardNextVisitCard(
          time: _formatTime(context, visit.startsAt),
          patientName: _patientName(visit),
          detail: _formatDate(context, visit.startsAt),
          onTap: () => _openVisit(
            context,
            ref,
            visit,
            isDesktop: isDesktop,
          ),
        );
      },
    );
  }

  Widget _buildAvailableSlotCard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<DashboardAvailabilityData> availability,
  ) {
    return availability.when(
      loading: () => const DashboardAvailableSlotCard(isLoading: true),
      error: (_, _) => DashboardAvailableSlotCard(
        isError: true,
        message: 'calendar.loadError'.tr(),
        actionLabel: 'patients.retry'.tr(),
        onAction: () => ref.invalidate(dashboardAvailabilityProvider),
      ),
      data: (data) {
        switch (data.status) {
          case DashboardAvailabilityStatus.scheduleNotConfigured:
            return DashboardAvailableSlotCard(
              message: 'profile.scheduleDefaultsDescription'.tr(),
              actionLabel: 'profile.scheduleDefaults'.tr(),
              onAction: () => context.go('/profile'),
            );
          case DashboardAvailabilityStatus.noSlots:
            return DashboardAvailableSlotCard(
              actionLabel: 'quickCreate.visit.manualTime'.tr(),
              onAction: () => context.go('/calendar'),
            );
          case DashboardAvailabilityStatus.ready:
            final slot = data.slot!;

            return DashboardAvailableSlotCard(
              dateLabel: _formatDate(context, slot.startsAt),
              timeRange: _formatSlotTime(context, slot),
              onTap: () => _openAvailableSlot(context, ref, slot),
            );
        }
      },
    );
  }

  Widget _buildUpcomingVisits(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<DashboardVisitsData> visits, {
    required bool isDesktop,
  }) {
    return visits.when(
      loading: () => const DashboardUpcomingVisits(isLoading: true),
      error: (_, _) => DashboardUpcomingVisits(
        isError: true,
        message: 'calendar.loadError'.tr(),
        actionLabel: 'patients.retry'.tr(),
        onAction: () => ref.invalidate(dashboardVisitsProvider),
      ),
      data: (data) {
        if (data.upcomingVisits.isEmpty) {
          return DashboardUpcomingVisits(
            message: 'dashboard.noUpcomingVisits'.tr(),
            actionLabel: 'dashboard.quickActionsItems.newVisit.title'.tr(),
            onAction: () => _openNewVisit(context, ref),
          );
        }

        return DashboardUpcomingVisits(
          visits: data.upcomingVisits
              .map(
                (visit) => DashboardUpcomingVisit(
                  timeLabel: _formatTime(context, visit.startsAt),
                  patientName: _patientName(visit),
                  detail: _formatDate(context, visit.startsAt),
                  onTap: () => _openVisit(
                    context,
                    ref,
                    visit,
                    isDesktop: isDesktop,
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  Future<void> _openVisit(
    BuildContext context,
    WidgetRef ref,
    Visit visit, {
    required bool isDesktop,
  }) async {
    await CalendarVisitDetailsSurface.show(
      context: context,
      visit: visit,
      selectedDate: visit.startsAt.toLocal(),
      isDesktop: isDesktop,
    );

    ref
      ..invalidate(dashboardVisitsProvider)
      ..invalidate(dashboardAvailabilityProvider);
  }

  Future<void> _openAvailableSlot(
    BuildContext context,
    WidgetRef ref,
    AvailabilitySlot slot,
  ) async {
    await QuickCreatePresenter.show(
      context,
      QuickCreateContext(
        intent: QuickCreateIntent.nextAvailableSlot,
        source: QuickCreateSource.dashboardAvailableSlot,
        startsAt: slot.startsAt,
        durationMinutes: slot.durationMinutes,
      ),
    );

    ref
      ..invalidate(dashboardVisitsProvider)
      ..invalidate(dashboardAvailabilityProvider);
  }

  Future<void> _openNewVisit(BuildContext context, WidgetRef ref) async {
    await QuickCreatePresenter.show(
      context,
      const QuickCreateContext(
        intent: QuickCreateIntent.newVisit,
        source: QuickCreateSource.mobileDashboardQuickAction,
      ),
    );

    ref
      ..invalidate(dashboardVisitsProvider)
      ..invalidate(dashboardAvailabilityProvider);
  }


  String _formatTime(BuildContext context, DateTime value) {
    return DateFormat.Hm(
      context.locale.toLanguageTag(),
    ).format(value.toLocal());
  }

  String _formatDate(BuildContext context, DateTime value) {
    return DateFormat(
      'EEE, d MMM',
      context.locale.toLanguageTag(),
    ).format(value.toLocal());
  }

  String _formatSlotTime(BuildContext context, AvailabilitySlot slot) {
    final format = DateFormat.Hm(context.locale.toLanguageTag());
    return '${format.format(slot.startsAt.toLocal())} - ${format.format(slot.endsAt.toLocal())}';
  }

  String _patientName(Visit visit) {
    final patientName = visit.patientName?.trim();
    return patientName == null || patientName.isEmpty
        ? visit.patientId
        : patientName;
  }
}
