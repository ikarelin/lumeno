import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';

class ClinicSetupPage extends StatefulWidget {
  const ClinicSetupPage({super.key});

  @override
  State<ClinicSetupPage> createState() => _ClinicSetupPageState();
}

class _ClinicSetupPageState extends State<ClinicSetupPage> {
  static const _contentMaxWidth = 520.0;
  static const _logoSize = 128.0;

  final _clinicNameController = TextEditingController();

  bool get _canContinue => _clinicNameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _clinicNameController.addListener(_handleClinicNameChanged);
  }

  @override
  void dispose() {
    _clinicNameController.removeListener(_handleClinicNameChanged);
    _clinicNameController.dispose();
    super.dispose();
  }

  void _handleClinicNameChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                    'onboarding.clinicSetup.title'.tr(),
                    style: AppTextStyles.headlineMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Text(
                    'onboarding.clinicSetup.description'.tr(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  TextFormField(
                    controller: _clinicNameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    decoration: _inputDecoration(
                      context,
                      label: 'onboarding.clinicSetup.clinicName'.tr(),
                    ),
                    onFieldSubmitted: (_) {
                      if (_canContinue) {
                        _continue();
                      }
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  AppButton.primary(
                    label: 'onboarding.clinicSetup.continue'.tr(),
                    fullWidth: true,
                    onPressed: _canContinue ? _continue : null,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  AppButton.secondary(
                    label: 'onboarding.clinicSetup.addLater'.tr(),
                    fullWidth: true,
                    onPressed: _addLater,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  AppButton.text(
                    label: MaterialLocalizations.of(context).backButtonTooltip,
                    fullWidth: true,
                    onPressed: _goBack,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
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
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
    );
  }

  void _continue() {
    FocusScope.of(context).unfocus();

    if (!_canContinue) {
      return;
    }

    context.go('/dashboard');
  }

  void _addLater() {
    FocusScope.of(context).unfocus();
    context.go('/dashboard');
  }

  void _goBack() {
    final region = GoRouterState.of(context).uri.queryParameters['region'];

    final location = region == null
        ? '/doctor-setup'
        : '/doctor-setup?region=$region';

    context.go(location);
  }
}
