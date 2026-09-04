import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../clinics/domain/clinic_repository.dart';
import '../../../clinics/presentation/providers/clinic_provider.dart';
import '../controllers/clinic_setup_controller.dart';

class ClinicSetupPage extends ConsumerStatefulWidget {
  const ClinicSetupPage({super.key, this.repository});

  final ClinicRepository? repository;

  @override
  ConsumerState<ClinicSetupPage> createState() => _ClinicSetupPageState();
}

class _ClinicSetupPageState extends ConsumerState<ClinicSetupPage> {
  static const _contentMaxWidth = 520.0;
  static const _logoSize = 128.0;

  final _clinicNameController = TextEditingController();
  final _addressController = TextEditingController();

  ClinicSetupController? _clinicSetupController;

  bool get _canContinue => _clinicNameController.text.trim().isNotEmpty;

  bool get _isSubmitting => _clinicSetupController?.isSubmitting ?? false;

  bool get _openedFromProfile =>
      GoRouterState.of(context).uri.queryParameters['from'] == 'profile';

  @override
  void initState() {
    super.initState();

    _clinicNameController.addListener(_handleClinicNameChanged);

    final repository = widget.repository;

    if (repository != null) {
      _clinicSetupController = ClinicSetupController(repository)
        ..addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    _clinicSetupController
      ?..removeListener(_handleControllerChanged)
      ..dispose();

    _clinicNameController.removeListener(_handleClinicNameChanged);

    _clinicNameController.dispose();
    _addressController.dispose();

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
                    enabled: !_isSubmitting,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                      context,
                      label: 'onboarding.clinicSetup.clinicName'.tr(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _addressController,
                    enabled: !_isSubmitting,
                    keyboardType: TextInputType.streetAddress,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    decoration: _inputDecoration(
                      context,
                      label: 'onboarding.clinicSetup.address'.tr(),
                    ),
                    onFieldSubmitted: (_) {
                      if (_canContinue && !_isSubmitting) {
                        _submit();
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton.primary(
                    label: _isSubmitting
                        ? 'onboarding.clinicSetup.saving'.tr()
                        : 'onboarding.clinicSetup.continue'.tr(),
                    fullWidth: true,
                    onPressed: _canContinue && !_isSubmitting ? _submit : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton.secondary(
                    label: _openedFromProfile
                        ? MaterialLocalizations.of(context).cancelButtonLabel
                        : 'onboarding.clinicSetup.addLater'.tr(),
                    fullWidth: true,
                    onPressed: _isSubmitting ? null : _skip,
                  ),
                  if (!_openedFromProfile) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppButton.text(
                      label: MaterialLocalizations.of(context)
                          .backButtonTooltip,
                      fullWidth: true,
                      onPressed: _isSubmitting ? null : _goBack,
                    ),
                  ],
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

  Future<void> _submit() async {
    if (_isSubmitting || !_canContinue) {
      return;
    }

    FocusScope.of(context).unfocus();

    final controller = _clinicSetupController;

    if (controller == null) {
      _goToDestination();
      return;
    }

    final created = await controller.createClinic(
      name: _clinicNameController.text,
      address: _addressController.text,
    );

    if (!mounted) {
      return;
    }

    if (!created) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('onboarding.clinicSetup.saveFailed'.tr())),
        );

      return;
    }

    ref.invalidate(clinicsProvider);
    ref.invalidate(clinicMembershipsProvider);

    _goToDestination();
  }

  void _skip() {
    FocusScope.of(context).unfocus();

    _goToDestination();
  }

  void _goToDestination() {
    if (_openedFromProfile) {
      context.go('/profile');
      return;
    }

    context.go('/dashboard');
  }

  void _goBack() {
    final region = GoRouterState.of(context).uri.queryParameters['region'];

    final location = region == null
        ? '/doctor-setup'
        : '/doctor-setup?region=$region';

    context.go(location);
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }
}
