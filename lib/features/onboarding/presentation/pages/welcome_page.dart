import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../widgets/onboarding_page_frame.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPageFrame(
      title: 'onboarding.welcome.title'.tr(),
      description: 'onboarding.welcome.description'.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton.primary(
            label: 'onboarding.welcome.createAccount'.tr(),
            fullWidth: true,
            onPressed: () => context.go('/initial-settings'),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton.secondary(
            label: 'onboarding.welcome.signIn'.tr(),
            fullWidth: true,
            onPressed: () => context.go('/sign-in'),
          ),
        ],
      ),
    );
  }
}
