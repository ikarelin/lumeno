import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../onboarding/presentation/widgets/onboarding_page_frame.dart';
import '../../domain/auth_sign_in_repository.dart';
import '../controllers/auth_sign_in_controller.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key, this.repository});

  final AuthSignInRepository? repository;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  AuthSignInController? _authSignInController;

  bool _passwordVisible = false;

  bool get _isSubmitting => _authSignInController?.isSubmitting ?? false;

  @override
  void initState() {
    super.initState();

    final repository = widget.repository;

    if (repository != null) {
      _authSignInController = AuthSignInController(repository)
        ..addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    _authSignInController
      ?..removeListener(_handleControllerChanged)
      ..dispose();

    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OnboardingPageFrame(
      title: 'onboarding.signIn.title'.tr(),
      description: 'onboarding.signIn.description'.tr(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              enabled: !_isSubmitting,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              decoration: onboardingInputDecoration(
                context,
                label: 'onboarding.signIn.email'.tr(),
              ),
              validator: _validateEmail,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _passwordController,
              enabled: !_isSubmitting,
              obscureText: !_passwordVisible,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              autocorrect: false,
              enableSuggestions: false,
              decoration: onboardingInputDecoration(
                context,
                label: 'onboarding.signIn.password'.tr(),
                suffixIcon: IconButton(
                  tooltip: _passwordVisible
                      ? MaterialLocalizations.of(context).hideAccountsLabel
                      : MaterialLocalizations.of(context).showAccountsLabel,
                  onPressed: _isSubmitting
                      ? null
                      : () {
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
              label: _isSubmitting
                  ? 'onboarding.signIn.signingIn'.tr()
                  : 'onboarding.signIn.signIn'.tr(),
              fullWidth: true,
              onPressed: _isSubmitting ? null : _submit,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton.text(
              label: MaterialLocalizations.of(context).backButtonTooltip,
              fullWidth: true,
              onPressed: _isSubmitting ? null : () => context.go('/welcome'),
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
                  onPressed: _isSubmitting
                      ? null
                      : () => context.go('/initial-settings'),
                  child: Text('onboarding.signIn.createAccount'.tr()),
                ),
              ],
            ),
          ],
        ),
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

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final controller = _authSignInController;

    if (controller == null) {
      context.go('/dashboard');
      return;
    }

    final signedIn = await controller.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (!signedIn) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('onboarding.signIn.signInFailed'.tr())),
        );
    }
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }
}
