import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const _contentMaxWidth = 440.0;
  static const _logoSize = 104.0;

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
              child: _LanguageSelector(),
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
                        style: AppTextStyles.headlineMedium,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppSpacing.xl),

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

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;

    return PopupMenuButton<Locale>(
      tooltip: '',
      onSelected: context.setLocale,
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: const Locale('en'),
            child: Text('onboarding.language.english'.tr()),
          ),
          PopupMenuItem(
            value: const Locale('ru'),
            child: Text('onboarding.language.russian'.tr()),
          ),
        ];
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              locale.languageCode.toUpperCase(),
              style: AppTextStyles.labelMedium,
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}
