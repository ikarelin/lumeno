import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../widgets/onboarding_page_frame.dart';
import '../../domain/doctor_setup_repository.dart';
import '../controllers/doctor_setup_controller.dart';

class DoctorSetupPage extends StatefulWidget {
  const DoctorSetupPage({super.key, this.repository});

  final DoctorSetupRepository? repository;

  @override
  State<DoctorSetupPage> createState() => _DoctorSetupPageState();
}

class _DoctorSetupPageState extends State<DoctorSetupPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();

  DoctorSetupController? _doctorSetupController;

  bool get _isSubmitting => _doctorSetupController?.isSubmitting ?? false;

  @override
  void initState() {
    super.initState();

    final repository = widget.repository;

    if (repository != null) {
      _doctorSetupController = DoctorSetupController(repository)
        ..addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    _doctorSetupController
      ?..removeListener(_handleControllerChanged)
      ..dispose();

    _nameController.dispose();
    _specialtyController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPageFrame(
      title: 'onboarding.doctorSetup.title'.tr(),
      description: 'onboarding.doctorSetup.description'.tr(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              enabled: !_isSubmitting,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              decoration: onboardingInputDecoration(
                context,
                label: 'onboarding.doctorSetup.name'.tr(),
              ),
              validator: _validateRequired,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _specialtyController,
              enabled: !_isSubmitting,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              decoration: onboardingInputDecoration(
                context,
                label: 'onboarding.doctorSetup.specialty'.tr(),
              ),
              validator: _validateRequired,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton.primary(
              label: _isSubmitting
                  ? 'onboarding.doctorSetup.saving'.tr()
                  : 'onboarding.doctorSetup.continue'.tr(),
              fullWidth: true,
              onPressed: _isSubmitting ? null : _submit,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton.text(
              label: MaterialLocalizations.of(context).backButtonTooltip,
              fullWidth: true,
              onPressed: _isSubmitting ? null : _goBack,
            ),
          ],
        ),
      ),
    );
  }

  String? _validateRequired(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'onboarding.doctorSetup.required'.tr();
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

    final controller = _doctorSetupController;

    if (controller == null) {
      _goToClinicSetup();
      return;
    }

    final completed = await controller.completeDoctorSetup(
      doctorName: _nameController.text,
      specialty: _specialtyController.text,
    );

    if (!mounted) {
      return;
    }

    if (!completed) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('onboarding.doctorSetup.saveFailed'.tr())),
        );

      return;
    }

    _goToClinicSetup();
  }

  void _goToClinicSetup() {
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

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }
}
