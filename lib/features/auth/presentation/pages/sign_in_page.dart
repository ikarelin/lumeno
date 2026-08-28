import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  static const _contentMaxWidth = 520.0;
  static const _logoSize = 128.0;

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                      'onboarding.signIn.title'.tr(),
                      style: AppTextStyles.headlineMedium,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Text(
                      'onboarding.signIn.description'.tr(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      autocorrect: false,
                      decoration: _inputDecoration(
                        context,
                        label: 'onboarding.signIn.email'.tr(),
                      ),
                      validator: _validateEmail,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: _inputDecoration(
                        context,
                        label: 'onboarding.signIn.password'.tr(),
                        suffixIcon: IconButton(
                          tooltip: _passwordVisible
                              ? MaterialLocalizations.of(context)
                                    .hideAccountsLabel
                              : MaterialLocalizations.of(context)
                                    .showAccountsLabel,
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                        ),
                      ),
                      validator: _validatePassword,
                      onFieldSubmitted: (_) => _submit(),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    AppButton.primary(
                      label: 'onboarding.signIn.signIn'.tr(),
                      fullWidth: true,
                      onPressed: _submit,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    AppButton.secondary(
                      label: MaterialLocalizations.of(context)
                          .backButtonTooltip,
                      fullWidth: true,
                      onPressed: () {
                        context.go('/welcome');
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'onboarding.signIn.noAccount'.tr(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.go('/region');
                          },
                          child: Text('onboarding.signIn.createAccount'.tr()),
                        ),
                      ],
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

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailPattern.hasMatch(email)) {
      return 'onboarding.signIn.invalidEmail'.tr();
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'onboarding.signIn.passwordRequired'.tr();
    }

    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    context.go('/dashboard');
  }
}
