import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_breakpoints.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../quick_create/domain/quick_create_context.dart';
import '../../quick_create/domain/quick_create_intent.dart';
import '../../quick_create/domain/quick_create_source.dart';
import '../../quick_create/presentation/quick_create_presenter.dart';
import '../domain/patient.dart';
import '../domain/patient_contact_channel.dart';
import '../domain/update_patient_input.dart';
import '../../visits/presentation/providers/patient_visits_provider.dart';
import 'providers/patient_provider.dart';
import 'widgets/patient_visit_summary_cards.dart';

class PatientWorkspacePage extends ConsumerWidget {
  const PatientWorkspacePage({required this.patientId, super.key});

  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patient = ref.watch(patientByIdProvider(patientId));

    return Scaffold(
      body: SafeArea(
        child: patient.when(
          data: (patient) {
            if (patient == null) {
              return _WorkspaceState(
                title: 'patients.notFound'.tr(),
                description: 'patients.notFoundDescription'.tr(),
                icon: Icons.person_off_outlined,
                onBack: () => _goBack(context),
              );
            }

            return _PatientWorkspaceContent(patient: patient);
          },
          loading: () {
            return _WorkspaceLoading(onBack: () => _goBack(context));
          },
          error: (_, _) {
            return _WorkspaceState(
              title: 'patients.loadFailed'.tr(),
              icon: Icons.error_outline_rounded,
              onBack: () => _goBack(context),
              actionLabel: 'patients.retry'.tr(),
              onAction: () {
                ref.invalidate(patientByIdProvider(patientId));
              },
            );
          },
        ),
      ),
    );
  }

  static void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go('/patients');
  }
}

class _PatientWorkspaceContent extends ConsumerStatefulWidget {
  const _PatientWorkspaceContent({required this.patient});

  final Patient patient;

  @override
  ConsumerState<_PatientWorkspaceContent> createState() =>
      _PatientWorkspaceContentState();
}

class _PatientWorkspaceContentState
    extends ConsumerState<_PatientWorkspaceContent> {
  static const _contentMaxWidth = 1120.0;

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _telegramController;
  late final TextEditingController _noteController;

  late Patient _baselinePatient;

  Set<PatientContactChannel> _preferredContactChannels =
      <PatientContactChannel>{};

  bool _whatsappAvailable = false;
  bool _isSaving = false;
  bool _isPresentingQuickCreate = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _telegramController = TextEditingController();
    _noteController = TextEditingController();

    _applyPatient(widget.patient);
  }

  @override
  void didUpdateWidget(covariant _PatientWorkspaceContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.patient != widget.patient) {
      _applyPatient(widget.patient);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _telegramController.dispose();
    _noteController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDesktop: isDesktop),
              const SizedBox(height: AppSpacing.xl),
              PatientVisitSummaryCards(
                patientId: _baselinePatient.id,
                canOpenDetails: !_isInteractionBusy && !_hasChanges,
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: AppButton.secondary(
                  label: 'patientVisitHistory.allVisits'.tr(),
                  icon: Icons.history_rounded,
                  onPressed: _isInteractionBusy || _hasChanges
                      ? null
                      : () => context.push(
                          '/patients/${Uri.encodeComponent(_baselinePatient.id)}/visits',
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildContactCard(context, isDesktop: isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {required bool isDesktop}) {
    final colorScheme = Theme.of(context).colorScheme;

    final identity = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'patients.workspace'.tr(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _baselinePatient.name,
            style: isDesktop
                ? AppTextStyles.headlineLarge
                : AppTextStyles.headlineMedium,
          ),
          if (_baselinePatient.phone.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _baselinePatient.phone,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );

    if (!isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              identity,
              const SizedBox(width: AppSpacing.md),
              IconButton.filled(
                tooltip: 'patients.newVisit'.tr(),
                onPressed: _isInteractionBusy || _hasChanges
                    ? null
                    : _openNewVisit,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        identity,
        const SizedBox(width: AppSpacing.xl),
        AppButton.primary(
          label: 'patients.newVisit'.tr(),
          icon: Icons.add_rounded,
          onPressed: _isInteractionBusy || _hasChanges ? null : _openNewVisit,
        ),
      ],
    );
  }

  Widget _buildContactCard(BuildContext context, {required bool isDesktop}) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WorkspaceSectionHeader(
              icon: Icons.contact_phone_outlined,
              title: 'patients.contactDetails'.tr(),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (isDesktop) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildNameField()),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: _buildPhoneField()),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildEmailField()),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: _buildTelegramField()),
                ],
              ),
            ] else ...[
              _buildNameField(),
              const SizedBox(height: AppSpacing.md),
              _buildPhoneField(),
              const SizedBox(height: AppSpacing.md),
              _buildEmailField(),
              const SizedBox(height: AppSpacing.md),
              _buildTelegramField(),
            ],
            const SizedBox(height: AppSpacing.lg),
            Divider(height: 1, color: colorScheme.outlineVariant),
            const SizedBox(height: AppSpacing.lg),
            _buildWhatsappAvailabilityControl(context),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'patients.preferredContact'.tr(),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _buildPreferredChip(
                  context,
                  channel: PatientContactChannel.phone,
                  label: 'patients.phone'.tr(),
                ),
                _buildPreferredChip(
                  context,
                  channel: PatientContactChannel.email,
                  label: 'patients.email'.tr(),
                ),
                _buildPreferredChip(
                  context,
                  channel: PatientContactChannel.telegram,
                  label: 'patients.telegram'.tr(),
                ),
                _buildPreferredChip(
                  context,
                  channel: PatientContactChannel.whatsapp,
                  label: 'patients.whatsapp'.tr(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Divider(height: 1, color: colorScheme.outlineVariant),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _noteController,
              enabled: !_isSaving,
              onChanged: (_) {
                setState(() {});
              },
              minLines: 3,
              maxLines: 5,
              decoration: _inputDecoration(
                context,
                label: 'patients.noteOptional'.tr(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildFormActions(isDesktop: isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsappAvailabilityControl(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.30 : 0.45,
        ),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'patients.whatsappAvailable'.tr(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'patients.whatsappDescription'.tr(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Switch(
            value: _whatsappAvailable,
            onChanged: _isSaving ? null : _onWhatsappAvailabilityChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildFormActions({required bool isDesktop}) {
    final cancelButton = AppButton.secondary(
      label: 'patients.cancel'.tr(),
      fullWidth: !isDesktop,
      onPressed: _isSaving || !_hasChanges ? null : _resetForm,
    );

    final saveButton = AppButton.primary(
      label: _isSaving ? 'patients.saving'.tr() : 'patients.saveChanges'.tr(),
      fullWidth: !isDesktop,
      onPressed: _isSaving || !_hasChanges || !_currentInput.isValid
          ? null
          : _save,
    );

    if (!isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          saveButton,
          const SizedBox(height: AppSpacing.sm),
          cancelButton,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        cancelButton,
        const SizedBox(width: AppSpacing.sm),
        saveButton,
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      enabled: !_isSaving,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      onChanged: (_) {
        setState(() {});
      },
      validator: _requiredValidator,
      decoration: _inputDecoration(context, label: 'patients.name'.tr()),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      enabled: !_isSaving,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      onChanged: (value) {
        setState(() {
          if (value.trim().isEmpty) {
            _preferredContactChannels.remove(PatientContactChannel.phone);
          }
        });
      },
      validator: _requiredValidator,
      decoration: _inputDecoration(context, label: 'patients.phone'.tr()),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      enabled: !_isSaving,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onChanged: (value) {
        setState(() {
          if (value.trim().isEmpty) {
            _preferredContactChannels.remove(PatientContactChannel.email);
          }
        });
      },
      decoration: _inputDecoration(context, label: 'patients.email'.tr()),
    );
  }

  Widget _buildTelegramField() {
    return TextFormField(
      controller: _telegramController,
      enabled: !_isSaving,
      textInputAction: TextInputAction.next,
      onChanged: (value) {
        setState(() {
          if (value.trim().isEmpty) {
            _preferredContactChannels.remove(PatientContactChannel.telegram);
          }
        });
      },
      decoration: _inputDecoration(context, label: 'patients.telegram'.tr()),
    );
  }

  Widget _buildPreferredChip(
    BuildContext context, {
    required PatientContactChannel channel,
    required String label,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final available = _isChannelAvailable(channel);
    final selected = _preferredContactChannels.contains(channel);

    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: true,
      checkmarkColor: colorScheme.primary,
      selectedColor: colorScheme.primary.withValues(alpha: 0.12),
      backgroundColor: Colors.transparent,
      side: BorderSide(
        color: selected
            ? colorScheme.primary.withValues(alpha: 0.55)
            : colorScheme.outlineVariant,
      ),
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
      onSelected: _isSaving || !available
          ? null
          : (selected) {
              setState(() {
                if (selected) {
                  _preferredContactChannels.add(channel);
                } else {
                  _preferredContactChannels.remove(channel);
                }
              });
            },
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    bool alignLabelWithHint = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );

    return InputDecoration(
      labelText: label,
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.30 : 0.45,
      ),
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

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'patients.required'.tr();
    }

    return null;
  }

  bool _isChannelAvailable(PatientContactChannel channel) {
    return switch (channel) {
      PatientContactChannel.phone => _phoneController.text.trim().isNotEmpty,
      PatientContactChannel.email => _emailController.text.trim().isNotEmpty,
      PatientContactChannel.telegram =>
        _telegramController.text.trim().isNotEmpty,
      PatientContactChannel.whatsapp =>
        _whatsappAvailable && _phoneController.text.trim().isNotEmpty,
    };
  }

  void _onWhatsappAvailabilityChanged(bool value) {
    setState(() {
      _whatsappAvailable = value;

      if (!value) {
        _preferredContactChannels.remove(PatientContactChannel.whatsapp);
      }
    });
  }

  UpdatePatientInput get _currentInput {
    return UpdatePatientInput(
      patientId: _baselinePatient.id,
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      telegram: _telegramController.text,
      whatsappAvailable: _whatsappAvailable,
      preferredContactChannels: Set<PatientContactChannel>.of(
        _preferredContactChannels,
      ),
      note: _noteController.text,
    );
  }

  bool get _hasChanges {
    final patient = _baselinePatient;

    return _nameController.text != patient.name ||
        _phoneController.text != patient.phone ||
        _emailController.text != patient.email ||
        _telegramController.text != patient.telegram ||
        _whatsappAvailable != patient.whatsappAvailable ||
        !_sameChannels(
          _preferredContactChannels,
          patient.preferredContactChannels,
        ) ||
        _noteController.text != patient.note;
  }

  bool _sameChannels(
    Set<PatientContactChannel> left,
    Set<PatientContactChannel> right,
  ) {
    return left.length == right.length && left.containsAll(right);
  }

  bool get _isInteractionBusy => _isSaving || _isPresentingQuickCreate;

  void _applyPatient(Patient patient) {
    _baselinePatient = patient;

    _nameController.text = patient.name;
    _phoneController.text = patient.phone;
    _emailController.text = patient.email;
    _telegramController.text = patient.telegram;
    _noteController.text = patient.note;

    _whatsappAvailable = patient.whatsappAvailable;

    _preferredContactChannels = Set<PatientContactChannel>.of(
      patient.preferredContactChannels,
    );
  }

  void _resetForm() {
    setState(() {
      _applyPatient(_baselinePatient);
    });

    _formKey.currentState?.reset();
  }

  Future<void> _save() async {
    if (_isInteractionBusy) {
      return;
    }

    final isFormValid = _formKey.currentState?.validate() ?? false;

    final input = _currentInput;

    if (!isFormValid || !input.isValid) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repository = ref.read(patientManagementRepositoryProvider);

      final updatedPatient = await repository.updatePatient(input);

      if (!mounted) {
        return;
      }

      setState(() {
        _applyPatient(updatedPatient);
      });

      ref.invalidate(patientsProvider);
      ref.invalidate(patientByIdProvider(updatedPatient.id));

      final messenger = ScaffoldMessenger.of(context);

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('patients.updated'.tr())));
    } catch (_) {
      if (!mounted) {
        return;
      }

      final messenger = ScaffoldMessenger.of(context);

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('patients.saveFailed'.tr())));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _openNewVisit() async {
    if (_isInteractionBusy || _hasChanges) {
      return;
    }

    setState(() {
      _isPresentingQuickCreate = true;
    });

    try {
      await QuickCreatePresenter.show(
        context,
        QuickCreateContext(
          intent: QuickCreateIntent.newVisit,
          source: QuickCreateSource.patients,
          patient: _baselinePatient,
        ),
      );
      if (mounted) {
        ref.invalidate(patientNextVisitProvider(_baselinePatient.id));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPresentingQuickCreate = false;
        });
      }
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go('/patients');
  }
}

class _WorkspaceSectionHeader extends StatelessWidget {
  const _WorkspaceSectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, size: 20, color: colorScheme.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(title, style: AppTextStyles.titleLarge)),
      ],
    );
  }
}

class _WorkspaceLoading extends StatelessWidget {
  const _WorkspaceLoading({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}

class _WorkspaceState extends StatelessWidget {
  const _WorkspaceState({
    required this.title,
    required this.icon,
    required this.onBack,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? description;
  final IconData icon;
  final VoidCallback onBack;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: AppCard(
                child: Column(
                  children: [
                    Icon(icon, size: 40, color: colorScheme.primary),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleLarge,
                    ),
                    if (description != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        description!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (actionLabel != null && onAction != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      AppButton.primary(
                        label: actionLabel!,
                        onPressed: onAction,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
