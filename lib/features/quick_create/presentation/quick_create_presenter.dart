import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_breakpoints.dart';
import '../../../app/theme/app_radius.dart';
import '../domain/quick_create_context.dart';
import 'controllers/quick_create_controller.dart';
import 'providers/quick_create_providers.dart';
import 'widgets/quick_create_surface.dart';

abstract final class QuickCreatePresenter {
  static const _desktopPanelWidth = 520.0;

  static Future<QuickCreateResult?> show(
    BuildContext context,
    QuickCreateContext quickCreateContext,
  ) async {
    final store = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(quickCreateStoreProvider);

    final controller = QuickCreateController(
      context: quickCreateContext,
      patientRepository: store,
      clinicRepository: store,
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
      pageBuilder: (dialogContext, _, _) {
        return Align(
          alignment: Alignment.centerRight,
          child: SafeArea(
            left: false,
            child: Material(
              key: const Key('quick-create-desktop-panel'),
              color: Theme.of(dialogContext).colorScheme.surface,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppRadius.xl),
              ),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: _desktopPanelWidth,
                height: double.infinity,
                child: QuickCreateSurface(
                  controller: controller,
                  onClose: () => Navigator.of(dialogContext).pop(),
                  onCompleted: (result) {
                    Navigator.of(dialogContext).pop(result);
                  },
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, _, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(opacity: curvedAnimation, child: child),
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
                  onClose: () => Navigator.of(sheetContext).pop(),
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
