import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_language_selector.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const _contentMaxWidth = 440.0;
  static const _logoSize = 128.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              top: AppSpacing.md,
              right: AppSpacing.lg,
              //child: _LanguageSelector(),
              child: AppLanguageSelector(),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/branding/lumeno_logo_mark_concept_v1.png',
                        width: _logoSize,
                        height: _logoSize,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      const Text(
                        'Lumeno',
                        style: AppTextStyles.brand,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      Text(
                        'onboarding.welcome.title'.tr(),
                        style: AppTextStyles.headlineMedium,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      Text(
                        'onboarding.welcome.description'.tr(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      AppButton.primary(
                        label: 'onboarding.welcome.createAccount'.tr(),
                        fullWidth: true,
                        onPressed: () {
                          context.go('/region');
                        },
                      ),

                      const SizedBox(height: AppSpacing.md),

                      AppButton.secondary(
                        label: 'onboarding.welcome.signIn'.tr(),
                        fullWidth: true,
                        onPressed: () {
                          context.go('/sign-in');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
