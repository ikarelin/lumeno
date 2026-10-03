import 'package:flutter/material.dart';

import '../../../../app/theme/app_breakpoints.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class OnboardingPageFrame extends StatelessWidget {
  const OnboardingPageFrame({
    required this.title,
    required this.description,
    required this.child,
    super.key,
  });

  static const contentMaxWidth = 520.0;
  static const logoSize = 80.0;

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final shouldCenterVertically =
                constraints.maxWidth >= AppBreakpoints.desktop &&
                constraints.maxHeight >= 720;
            final availableHeight = constraints.maxHeight - (AppSpacing.lg * 2);
            final viewportMinHeight = availableHeight > 0
                ? availableHeight
                : 0.0;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: shouldCenterVertically ? viewportMinHeight : 0,
                ),
                child: Align(
                  alignment: shouldCenterVertically
                      ? const Alignment(0, -0.12)
                      : Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: contentMaxWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/branding/lumeno_logo_mark_concept_v1.png',
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        const Text(
                          'Lumeno',
                          style: AppTextStyles.brand,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          title,
                          style: AppTextStyles.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          description,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        child,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

InputDecoration onboardingInputDecoration(
  BuildContext context, {
  required String label,
  Widget? suffixIcon,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final surface = theme.brightness == Brightness.dark
      ? AppColors.surfaceDark
      : AppColors.surfaceLight;

  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.lg),
    borderSide: BorderSide(color: colorScheme.outlineVariant),
  );

  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: surface,
    suffixIcon: suffixIcon,
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: BorderSide(color: colorScheme.primary, width: 2),
    ),
    errorBorder: border.copyWith(
      borderSide: BorderSide(color: colorScheme.error),
    ),
    focusedErrorBorder: border.copyWith(
      borderSide: BorderSide(color: colorScheme.error, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
  );
}
