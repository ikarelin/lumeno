import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/account_region.dart';

class RegionPage extends StatefulWidget {
  const RegionPage({super.key});

  @override
  State<RegionPage> createState() => _RegionPageState();
}

class _RegionPageState extends State<RegionPage> {
  static const _contentMaxWidth = 520.0;
  static const _logoSize = 128.0;

  AccountRegion? _selectedRegion;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/branding/lumeno_logo_mark_concept_v1.png',
                      width: _logoSize,
                      height: _logoSize,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  const Text(
                    'Lumeno',
                    style: AppTextStyles.brand,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    'onboarding.region.title'.tr(),
                    style: AppTextStyles.headlineMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Text(
                    'onboarding.region.description'.tr(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  _RegionOptionCard(
                    title: 'onboarding.region.russia.title'.tr(),
                    description: 'onboarding.region.russia.description'.tr(),
                    selected: _selectedRegion == AccountRegion.russia,
                    onTap: () {
                      setState(() {
                        _selectedRegion = AccountRegion.russia;
                      });
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  _RegionOptionCard(
                    title: 'onboarding.region.europeInternational.title'.tr(),
                    description:
                        'onboarding.region.europeInternational.description'
                            .tr(),
                    selected:
                        _selectedRegion == AccountRegion.europeInternational,
                    onTap: () {
                      setState(() {
                        _selectedRegion = AccountRegion.europeInternational;
                      });
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  AppButton.primary(
                    label: 'onboarding.region.continue'.tr(),
                    fullWidth: true,
                    onPressed: _selectedRegion == null
                        ? null
                        : () {
                            context.go(
                              '/sign-up?region=${_selectedRegion!.routeValue}',
                            );
                          },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  AppButton.secondary(
                    label: MaterialLocalizations.of(context).backButtonTooltip,
                    fullWidth: true,
                    onPressed: () {
                      context.go('/welcome');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegionOptionCard extends StatelessWidget {
  const _RegionOptionCard({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final unselectedSurface = theme.brightness == Brightness.dark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: selected
                  ? colorScheme.primary.withAlpha(18)
                  : unselectedSurface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: selected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.titleLarge),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: selected
                      ? Icon(
                          Icons.check_circle_rounded,
                          key: const ValueKey('selected'),
                          color: colorScheme.primary,
                        )
                      : Icon(
                          Icons.circle_outlined,
                          key: const ValueKey('unselected'),
                          color: colorScheme.outline,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
