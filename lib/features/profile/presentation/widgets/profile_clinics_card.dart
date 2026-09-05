import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../clinics/domain/clinic.dart';
import '../../../clinics/domain/clinic_membership.dart';
import '../../../clinics/domain/update_clinic_input.dart';
import '../../../clinics/presentation/providers/clinic_provider.dart';

class ProfileClinicsCard extends ConsumerStatefulWidget {
  const ProfileClinicsCard({required this.onAddClinic, super.key});

  final VoidCallback onAddClinic;

  @override
  ConsumerState<ProfileClinicsCard> createState() => _ProfileClinicsCardState();
}

class _ProfileClinicsCardState extends ConsumerState<ProfileClinicsCard> {
  String? _settingDefaultClinicId;
  String? _deletingClinicId;

  bool get _isMutatingClinic =>
      _settingDefaultClinicId != null || _deletingClinicId != null;

  Future<void> _setDefaultClinic(String clinicId) async {
    if (_isMutatingClinic) {
      return;
    }

    setState(() {
      _settingDefaultClinicId = clinicId;
    });

    try {
      final repository = ref.read(clinicMembershipRepositoryProvider);

      await repository.setDefaultClinic(clinicId: clinicId);

      ref.invalidate(clinicMembershipsProvider);
    } catch (_) {
      if (!mounted) {
        return;
      }

      final messenger = ScaffoldMessenger.of(context);

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('profile.setDefaultClinicFailed'.tr())),
        );
    } finally {
      if (mounted) {
        setState(() {
          _settingDefaultClinicId = null;
        });
      }
    }
  }

  Future<void> _editClinic(Clinic clinic) async {
    if (_isMutatingClinic) {
      return;
    }

    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _EditClinicDialog(clinic: clinic);
      },
    );

    if (updated != true || !mounted) {
      return;
    }

    ref
      ..invalidate(clinicMembershipsProvider)
      ..invalidate(clinicsProvider);
  }

  Future<void> _deleteClinic(Clinic clinic) async {
    if (_isMutatingClinic) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          title: Text(
            'clinicManagement.deleteTitle'.tr(),
            style: AppTextStyles.titleLarge,
          ),
          content: Text(
            'clinicManagement.deleteMessage'.tr(),
            style: AppTextStyles.bodyMedium,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text('clinicManagement.cancel'.tr()),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text('clinicManagement.delete'.tr()),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _deletingClinicId = clinic.id;
    });

    try {
      final repository = ref.read(clinicManagementRepositoryProvider);

      await repository.archiveClinicMembership(clinicId: clinic.id);

      ref
        ..invalidate(clinicMembershipsProvider)
        ..invalidate(clinicsProvider);
    } catch (_) {
      if (!mounted) {
        return;
      }

      final messenger = ScaffoldMessenger.of(context);

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('clinicManagement.deleteFailed'.tr())),
        );
    } finally {
      if (mounted) {
        setState(() {
          _deletingClinicId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final memberships = ref.watch(clinicMembershipsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.local_hospital_outlined,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'profile.clinics'.tr(),
                      style: AppTextStyles.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'profile.clinicsDescription'.tr(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          memberships.when(
            data: (items) {
              if (items.isEmpty) {
                return _EmptyClinics(colorScheme: colorScheme);
              }

              final hasMultipleClinics = items.length > 1;

              return Column(
                children: [
                  for (var index = 0; index < items.length; index++) ...[
                    _ClinicRow(
                      membership: items[index],
                      showDefaultBadge:
                          hasMultipleClinics && items[index].isDefault,
                      canSetDefault:
                          hasMultipleClinics && !items[index].isDefault,
                      isSettingDefault:
                          _settingDefaultClinicId == items[index].clinic.id,
                      isDeleting: _deletingClinicId == items[index].clinic.id,
                      isInteractionDisabled: _isMutatingClinic,
                      onEdit: () {
                        _editClinic(items[index].clinic);
                      },
                      onSetDefault: () {
                        _setDefaultClinic(items[index].clinic.id);
                      },
                      onDelete: () {
                        _deleteClinic(items[index].clinic);
                      },
                    ),
                    if (index < items.length - 1)
                      const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              );
            },
            loading: () {
              return const SizedBox(
                height: 96,
                child: Center(child: CircularProgressIndicator()),
              );
            },
            error: (_, _) {
              return _ClinicsError(
                onRetry: () {
                  ref.invalidate(clinicMembershipsProvider);
                },
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton.secondary(
            label: 'profile.addClinic'.tr(),
            icon: Icons.add_rounded,
            fullWidth: true,
            onPressed: _isMutatingClinic ? null : widget.onAddClinic,
          ),
        ],
      ),
    );
  }
}

enum _ClinicAction { edit, setDefault, delete }

class _ClinicRow extends StatelessWidget {
  const _ClinicRow({
    required this.membership,
    required this.showDefaultBadge,
    required this.canSetDefault,
    required this.isSettingDefault,
    required this.isDeleting,
    required this.isInteractionDisabled,
    required this.onEdit,
    required this.onSetDefault,
    required this.onDelete,
  });

  final ClinicMembership membership;
  final bool showDefaultBadge;
  final bool canSetDefault;
  final bool isSettingDefault;
  final bool isDeleting;
  final bool isInteractionDisabled;
  final VoidCallback onEdit;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final clinic = membership.clinic;
    final address = clinic.address.trim();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.business_outlined, color: colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        clinic.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (showDefaultBadge) ...[
                      const SizedBox(width: AppSpacing.sm),
                      _DefaultBadge(colorScheme: colorScheme),
                    ],
                  ],
                ),
                if (address.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          address,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (isSettingDefault || isDeleting) ...[
            const SizedBox(width: AppSpacing.sm),
            const SizedBox(
              width: 24,
              height: 24,
              child: Padding(
                padding: EdgeInsets.all(3),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ] else ...[
            const SizedBox(width: AppSpacing.xs),
            PopupMenuButton<_ClinicAction>(
              enabled: !isInteractionDisabled,
              tooltip: MaterialLocalizations.of(context).showMenuTooltip,
              onSelected: (action) {
                switch (action) {
                  case _ClinicAction.edit:
                    onEdit();
                  case _ClinicAction.setDefault:
                    onSetDefault();
                  case _ClinicAction.delete:
                    onDelete();
                }
              },
              itemBuilder: (context) {
                return <PopupMenuEntry<_ClinicAction>>[
                  PopupMenuItem<_ClinicAction>(
                    value: _ClinicAction.edit,
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Text('clinicManagement.editClinic'.tr()),
                      ],
                    ),
                  ),
                  if (canSetDefault)
                    PopupMenuItem<_ClinicAction>(
                      value: _ClinicAction.setDefault,
                      child: Row(
                        children: [
                          const Icon(Icons.star_outline_rounded, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Text('profile.setDefaultClinic'.tr()),
                        ],
                      ),
                    ),
                  const PopupMenuDivider(),
                  PopupMenuItem<_ClinicAction>(
                    value: _ClinicAction.delete,
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: colorScheme.error,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'clinicManagement.deleteClinic'.tr(),
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ],
                    ),
                  ),
                ];
              },
              icon: const Icon(Icons.more_vert_rounded),
            ),
          ],
        ],
      ),
    );
  }
}

class _EditClinicDialog extends ConsumerStatefulWidget {
  const _EditClinicDialog({required this.clinic});

  final Clinic clinic;

  @override
  ConsumerState<_EditClinicDialog> createState() => _EditClinicDialogState();
}

class _EditClinicDialogState extends ConsumerState<_EditClinicDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;

  bool _isSaving = false;
  String? _errorMessage;

  bool get _canSave => _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.clinic.name);
    _addressController = TextEditingController(text: widget.clinic.address);

    _nameController.addListener(_handleInputChanged);
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_handleInputChanged)
      ..dispose();

    _addressController.dispose();

    super.dispose();
  }

  void _handleInputChanged() {
    if (mounted) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  Future<void> _save() async {
    if (_isSaving || !_canSave) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(clinicManagementRepositoryProvider);

      await repository.updateClinic(
        UpdateClinicInput(
          clinicId: widget.clinic.id,
          name: _nameController.text,
          address: _addressController.text,
        ),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _errorMessage = 'clinicManagement.updateFailed'.tr();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(
        'clinicManagement.editClinic'.tr(),
        style: AppTextStyles.titleLarge,
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              enabled: !_isSaving,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'clinicManagement.clinicName'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _addressController,
              enabled: !_isSaving,
              keyboardType: TextInputType.streetAddress,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'clinicManagement.address'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              onFieldSubmitted: (_) {
                if (_canSave && !_isSaving) {
                  _save();
                }
              },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                _errorMessage!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      actions: [
        AppButton.text(
          label: 'clinicManagement.cancel'.tr(),
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.of(context).pop(false);
                },
        ),
        AppButton.primary(
          label: _isSaving
              ? 'clinicManagement.saving'.tr()
              : 'clinicManagement.saveChanges'.tr(),
          onPressed: _canSave && !_isSaving ? _save : null,
        ),
      ],
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.24)),
      ),
      child: Text(
        'profile.defaultClinic'.tr(),
        style: AppTextStyles.bodyMedium.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyClinics extends StatelessWidget {
  const _EmptyClinics({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: [
          Icon(
            Icons.add_business_outlined,
            size: 40,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'profile.noClinics'.tr(),
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ClinicsError extends StatelessWidget {
  const _ClinicsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(Icons.error_outline_rounded, color: colorScheme.error),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            'profile.clinicsLoadFailed'.tr(),
            style: AppTextStyles.bodyMedium,
          ),
        ),
        IconButton(
          onPressed: onRetry,
          tooltip: MaterialLocalizations.of(context)
              .refreshIndicatorSemanticLabel,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }
}
