import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../clinics/domain/clinic_membership.dart';
import '../../../clinics/presentation/providers/clinic_provider.dart';

class ProfileClinicsCard extends ConsumerStatefulWidget {
  const ProfileClinicsCard({required this.onAddClinic, super.key});

  final VoidCallback onAddClinic;

  @override
  ConsumerState<ProfileClinicsCard> createState() => _ProfileClinicsCardState();
}

class _ProfileClinicsCardState extends ConsumerState<ProfileClinicsCard> {
  String? _settingDefaultClinicId;

  bool get _isSettingDefault => _settingDefaultClinicId != null;

  Future<void> _setDefaultClinic(String clinicId) async {
    if (_isSettingDefault) {
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
                      showActions:
                          hasMultipleClinics && !items[index].isDefault,
                      isSettingDefault:
                          _settingDefaultClinicId == items[index].clinic.id,
                      isInteractionDisabled: _isSettingDefault,
                      onSetDefault: () {
                        _setDefaultClinic(items[index].clinic.id);
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
            onPressed: _isSettingDefault ? null : widget.onAddClinic,
          ),
        ],
      ),
    );
  }
}

enum _ClinicAction { setDefault }

class _ClinicRow extends StatelessWidget {
  const _ClinicRow({
    required this.membership,
    required this.showDefaultBadge,
    required this.showActions,
    required this.isSettingDefault,
    required this.isInteractionDisabled,
    required this.onSetDefault,
  });

  final ClinicMembership membership;
  final bool showDefaultBadge;
  final bool showActions;
  final bool isSettingDefault;
  final bool isInteractionDisabled;
  final VoidCallback onSetDefault;

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
          if (isSettingDefault) ...[
            const SizedBox(width: AppSpacing.sm),
            const SizedBox(
              width: 24,
              height: 24,
              child: Padding(
                padding: EdgeInsets.all(3),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ] else if (showActions) ...[
            const SizedBox(width: AppSpacing.xs),
            PopupMenuButton<_ClinicAction>(
              enabled: !isInteractionDisabled,
              tooltip: MaterialLocalizations.of(context).showMenuTooltip,
              onSelected: (action) {
                switch (action) {
                  case _ClinicAction.setDefault:
                    onSetDefault();
                }
              },
              itemBuilder: (context) {
                return [
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
