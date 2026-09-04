import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_breakpoints.dart';
import '../../../app/theme/app_radius.dart';
import '../../../shared/widgets/sidebar/app_sidebar.dart';
import '../../clinics/presentation/providers/clinic_provider.dart';
import '../domain/quick_create_context.dart';
import '../domain/quick_create_intent.dart';
import 'controllers/quick_create_controller.dart';
import 'providers/quick_create_providers.dart';
import 'widgets/quick_create_surface.dart';

abstract final class QuickCreatePresenter {
  static const _desktopPanelWidth = 520.0;
  static const _desktopNewPatientPanelHeight = 620.0;

  static Future<QuickCreateResult?> show(
    BuildContext context,
    QuickCreateContext quickCreateContext,
  ) async {
    final container = ProviderScope.containerOf(context, listen: false);

    final store = container.read(quickCreateStoreProvider);

    final clinicRepository = container.read(clinicRepositoryProvider);

    final clinicMembershipRepository = container.read(
      clinicMembershipRepositoryProvider,
    );

    final controller = QuickCreateController(
      context: quickCreateContext,
      patientRepository: store,
      clinicRepository: clinicRepository,
      clinicMembershipRepository: clinicMembershipRepository,
      visitRepository: store,
      availabilityRepository: store,
    );

    unawaited(controller.load());

    try {
      if (MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop) {
        return await _showDesktop(context, controller);
      }

      return await _showMobile(context, controller);
    } finally {
      controller.dispose();
    }
  }

  static Future<QuickCreateResult?> _showDesktop(
    BuildContext context,
    QuickCreateController controller,
  ) {
    return showGeneralDialog<QuickCreateResult>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.38),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (dialogContext, animation, _) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final mediaQuery = MediaQuery.of(dialogContext);

            final availableHeight = math
                .max(
                  0.0,
                  mediaQuery.size.height -
                      mediaQuery.padding.top -
                      mediaQuery.padding.bottom,
                )
                .toDouble();

            final isCompactNewPatient =
                controller.state.intent == QuickCreateIntent.newPatient &&
                !controller.state.isSchedulingPatient;

            final panelHeight = isCompactNewPatient
                ? math
                      .min(_desktopNewPatientPanelHeight, availableHeight)
                      .toDouble()
                : availableHeight;

            return Padding(
              padding: const EdgeInsets.only(left: AppSidebar.width),
              child: SafeArea(
                left: false,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(-1, 0),
                        end: Offset.zero,
                      ).animate(curvedAnimation),
                      child: FadeTransition(
                        opacity: curvedAnimation,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          width: _desktopPanelWidth,
                          height: panelHeight,
                          child: Material(
                            key: const Key('quick-create-desktop-panel'),
                            color: Theme.of(dialogContext).colorScheme.surface,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(AppRadius.xl),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: QuickCreateSurface(
                              controller: controller,
                              onClose: () {
                                Navigator.of(dialogContext).pop();
                              },
                              onCompleted: (result) {
                                Navigator.of(dialogContext).pop(result);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Future<QuickCreateResult?> _showMobile(
    BuildContext context,
    QuickCreateController controller,
  ) {
    return showModalBottomSheet<QuickCreateResult>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.38),
      builder: (sheetContext) {
        final bottomInset = MediaQuery.viewInsetsOf(sheetContext).bottom;

        return AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: bottomInset),
          child: DraggableScrollableSheet(
            key: const Key('quick-create-mobile-sheet'),
            expand: false,
            initialChildSize: 0.92,
            minChildSize: 0.62,
            maxChildSize: 0.97,
            builder: (context, scrollController) {
              return Material(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
                clipBehavior: Clip.antiAlias,
                child: QuickCreateSurface(
                  controller: controller,
                  scrollController: scrollController,
                  showDragHandle: true,
                  onClose: () {
                    Navigator.of(sheetContext).pop();
                  },
                  onCompleted: (result) {
                    Navigator.of(sheetContext).pop(result);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
