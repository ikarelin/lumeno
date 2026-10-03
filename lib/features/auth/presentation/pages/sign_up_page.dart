import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../onboarding/presentation/widgets/onboarding_page_frame.dart';
import '../../../scheduling/domain/doctor_calendar_time.dart';
import '../../domain/auth_repository.dart';
import '../controllers/auth_sign_up_controller.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({this.authRepository, super.key});

  final AuthRepository? authRepository;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  static const _timeZoneQueryKey = 'timeZoneId';

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  AuthSignUpController? _signUpController;

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();

    final repository = widget.authRepository;

    if (repository != null) {
      _signUpController = AuthSignUpController(repository)
        ..addListener(_handleSignUpStateChanged);
    }
  }

  @override
  void dispose() {
    final signUpController = _signUpController;

    if (signUpController != null) {
      signUpController.removeListener(_handleSignUpStateChanged);
      signUpController.dispose();
    }

    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSubmitting = _signUpController?.isSubmitting ?? false;

    return OnboardingPageFrame(
      title: 'onboarding.signUp.title'.tr(),
      description: 'onboarding.signUp.description'.tr(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              enabled: !isSubmitting,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              decoration: onboardingInputDecoration(
                context,
                label: 'onboarding.signUp.email'.tr(),
              ),
              validator: _validateEmail,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _passwordController,
              enabled: !isSubmitting,
              obscureText: !_passwordVisible,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              autocorrect: false,
              enableSuggestions: false,
              decoration: onboardingInputDecoration(
                context,
                label: 'onboarding.signUp.password'.tr(),
                suffixIcon: IconButton(
                  tooltip: _passwordVisible
                      ? MaterialLocalizations.of(context).hideAccountsLabel
                      : MaterialLocalizations.of(context).showAccountsLabel,
                  onPressed: isSubmitting
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
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _confirmPasswordController,
              enabled: !isSubmitting,
              obscureText: !_confirmPasswordVisible,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              autocorrect: false,
              enableSuggestions: false,
              decoration: onboardingInputDecoration(
                context,
                label: 'onboarding.signUp.confirmPassword'.tr(),
                suffixIcon: IconButton(
                  tooltip: _confirmPasswordVisible
                      ? MaterialLocalizations.of(context).hideAccountsLabel
                      : MaterialLocalizations.of(context).showAccountsLabel,
                  onPressed: isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _confirmPasswordVisible = !_confirmPasswordVisible;
                          });
                        },
                  icon: Icon(
                    _confirmPasswordVisible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                ),
              ),
              validator: _validateConfirmPassword,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton.primary(
              label: isSubmitting
                  ? 'onboarding.signUp.creatingAccount'.tr()
                  : 'onboarding.signUp.createAccount'.tr(),
              fullWidth: true,
              onPressed: isSubmitting ? null : _submit,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton.text(
              label: MaterialLocalizations.of(context).backButtonTooltip,
              fullWidth: true,
              onPressed: isSubmitting ? null : _goBack,
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'onboarding.signUp.alreadyHaveAccount'.tr(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                TextButton(
                  onPressed: isSubmitting ? null : () => context.go('/sign-in'),
                  child: Text('onboarding.signUp.signIn'.tr()),
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
      return 'onboarding.signUp.invalidEmail'.tr();
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').length < 8) {
      return 'onboarding.signUp.passwordTooShort'.tr();
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'onboarding.signUp.passwordMismatch'.tr();
    }

    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final uri = GoRouterState.of(context).uri;
    final timeZoneId = uri.queryParameters[_timeZoneQueryKey];

    if (!_hasValidInitialSettings(timeZoneId: timeZoneId)) {
      context.go('/initial-settings');
      return;
    }

    final signUpController = _signUpController;

    if (signUpController == null) {
      context.go(
        Uri(
          path: '/doctor-setup',
          queryParameters: {_timeZoneQueryKey: timeZoneId!},
        ).toString(),
      );
      return;
    }

    final email = _emailController.text.trim();

    final result = await signUpController.signUp(
      email: email,
      password: _passwordController.text,
      doctorTimeZoneId: timeZoneId!,
    );

    if (!mounted) {
      return;
    }

    switch (result) {
      case AuthSignUpStatus.authenticated:
        context.go('/doctor-setup');

      case AuthSignUpStatus.emailConfirmationRequired:
        await _showEmailConfirmationDialog(email);

        if (!mounted) {
          return;
        }

        context.go('/sign-in');

      case null:
        if (signUpController.lastError != null) {
          _showSignUpError();
        }
    }
  }

  Future<void> _showEmailConfirmationDialog(String email) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('onboarding.signUp.emailConfirmationTitle'.tr()),
          content: Text(
            'onboarding.signUp.emailConfirmationMessage'.tr(
              namedArgs: {'email': email},
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                MaterialLocalizations.of(dialogContext).okButtonLabel,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSignUpError() {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('onboarding.signUp.signUpFailed'.tr())),
      );
  }

  void _handleSignUpStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _goBack() {
    final uri = GoRouterState.of(context).uri;
    final timeZoneId = uri.queryParameters[_timeZoneQueryKey];

    context.go(
      Uri(
        path: '/initial-settings',
        queryParameters: {_timeZoneQueryKey: ?timeZoneId},
      ).toString(),
    );
  }

  bool _hasValidInitialSettings({required String? timeZoneId}) {
    if (timeZoneId == null) {
      return false;
    }

    return DoctorCalendarTime.availableTimeZoneIds.contains(timeZoneId);
  }
}
