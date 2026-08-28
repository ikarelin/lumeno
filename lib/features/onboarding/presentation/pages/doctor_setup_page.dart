import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';

class DoctorSetupPage extends StatefulWidget {
  const DoctorSetupPage({super.key});

  @override
  State<DoctorSetupPage> createState() => _DoctorSetupPageState();
}

class _DoctorSetupPageState extends State<DoctorSetupPage> {
  static const _contentMaxWidth = 520.0;
  static const _logoSize = 128.0;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    super.dispose();
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
              child: Form(
                key: _formKey,
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
                      'onboarding.doctorSetup.title'.tr(),
                      style: AppTextStyles.headlineMedium,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Text(
                      'onboarding.doctorSetup.description'.tr(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      decoration: _inputDecoration(
                        context,
                        label: 'onboarding.doctorSetup.name'.tr(),
                      ),
                      validator: _validateRequired,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    TextFormField(
                      controller: _specialtyController,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      decoration: _inputDecoration(
                        context,
                        label: 'onboarding.doctorSetup.specialty'.tr(),
                      ),
                      validator: _validateRequired,
                      onFieldSubmitted: (_) => _submit(),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    AppButton.primary(
                      label: 'onboarding.doctorSetup.continue'.tr(),
                      fullWidth: true,
                      onPressed: _submit,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    AppButton.secondary(
                      label: MaterialLocalizations.of(context)
                          .backButtonTooltip,
                      fullWidth: true,
                      onPressed: _goBack,
                    ),
                  ],
                ),
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

  String? _validateRequired(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'onboarding.doctorSetup.required'.tr();
    }

    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final region = GoRouterState.of(context).uri.queryParameters['region'];

    final location = region == null
        ? '/clinic-setup'
        : '/clinic-setup?region=$region';

    context.go(location);
  }

  void _goBack() {
    final region = GoRouterState.of(context).uri.queryParameters['region'];

    final location = region == null ? '/sign-up' : '/sign-up?region=$region';

    context.go(location);
  }
}
