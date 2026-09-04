import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/theme/app_breakpoints.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/theme_mode_controller.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_language_selector.dart';
import '../../../auth/presentation/providers/auth_repository_provider.dart';
import '../../domain/doctor_profile.dart';
import '../providers/doctor_profile_provider.dart';
import '../widgets/profile_clinics_card.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static const _contentMaxWidth = 1120.0;
  static const _loadingHeight = 320.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(doctorProfileProvider);

    final email = Supabase.instance.client.auth.currentUser?.email ?? '';

    final isDesktop =
        MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'profile.title'.tr(),
                    style: isDesktop
                        ? AppTextStyles.headlineLarge
                        : AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'profile.description'.tr(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  profile.when(
                    data: (doctorProfile) {
                      return _ProfileContent(
                        profile: doctorProfile,
                        email: email,
                        isDesktop: isDesktop,
                      );
                    },
                    loading: () {
                      return const SizedBox(
                        height: _loadingHeight,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    error: (_, _) {
                      return AppCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: colorScheme.error,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                'profile.saveFailed'.tr(),
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                ref.invalidate(doctorProfileProvider);
                              },
                              icon: const Icon(Icons.refresh_rounded),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends ConsumerStatefulWidget {
  const _ProfileContent({
    required this.profile,
    required this.email,
    required this.isDesktop,
  });

  final DoctorProfile? profile;
  final String email;
  final bool isDesktop;

  @override
  ConsumerState<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends ConsumerState<_ProfileContent> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _specialtyController;

  bool _isSaving = false;
  bool _isLoggingOut = false;

  bool get _isBusy => _isSaving || _isLoggingOut;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.profile?.fullName ?? '',
    );

    _specialtyController = TextEditingController(
      text: widget.profile?.specialty ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant _ProfileContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldProfile = oldWidget.profile;
    final newProfile = widget.profile;

    if (oldProfile?.fullName != newProfile?.fullName) {
      _nameController.text = newProfile?.fullName ?? '';
    }

    if (oldProfile?.specialty != newProfile?.specialty) {
      _specialtyController.text = newProfile?.specialty ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isDesktop) {
      return Column(
        children: [
          _IdentityCard(profile: widget.profile, email: widget.email),
          const SizedBox(height: AppSpacing.lg),
          ProfileClinicsCard(onAddClinic: _openClinicSetup),
          const SizedBox(height: AppSpacing.lg),
          _buildProfessionalDetails(),
          const SizedBox(height: AppSpacing.lg),
          _buildPreferences(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _IdentityCard(profile: widget.profile, email: widget.email),
              const SizedBox(height: AppSpacing.lg),
              _buildProfessionalDetails(),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileClinicsCard(onAddClinic: _openClinicSetup),
              const SizedBox(height: AppSpacing.lg),
              _buildPreferences(),
            ],
          ),
        ),
      ],
    );
  }

  void _openClinicSetup() {
    context.go('/clinic-setup?from=profile');
  }

  Widget _buildProfessionalDetails() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeader(
              icon: Icons.person_outline_rounded,
              title: 'profile.professionalDetails'.tr(),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _nameController,
              enabled: !_isBusy,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              decoration: _inputDecoration(label: 'profile.name'.tr()),
              validator: _validateRequired,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _specialtyController,
              enabled: !_isBusy,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              decoration: _inputDecoration(label: 'profile.specialty'.tr()),
              validator: _validateRequired,
              onFieldSubmitted: (_) {
                if (!_isBusy) {
                  _save();
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              initialValue: widget.email,
              readOnly: true,
              decoration: _inputDecoration(
                label: 'profile.email'.tr(),
                helperText: 'profile.emailDescription'.tr(),
                suffixIcon: const Icon(Icons.lock_outline_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppButton.primary(
                    label: _isSaving
                        ? 'profile.saving'.tr()
                        : 'profile.saveChanges'.tr(),
                    fullWidth: !widget.isDesktop,
                    onPressed: _isBusy ? null : _save,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton.secondary(
                    label: _isLoggingOut
                        ? 'profile.loggingOut'.tr()
                        : 'profile.logOut'.tr(),
                    icon: Icons.logout_rounded,
                    fullWidth: !widget.isDesktop,
                    onPressed: _isBusy ? null : _logOut,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferences() {
    final themeMode = ref.watch(themeModeProvider);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            icon: Icons.tune_rounded,
            title: 'profile.preferences'.tr(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  'profile.language'.tr(),
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              const AppLanguageSelector(),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('profile.appearance'.tr(), style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          _AppearanceSelector(
            value: themeMode,
            onChanged: (mode) {
              ref.read(themeModeProvider.notifier).setMode(mode);
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? helperText,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );

    return InputDecoration(
      labelText: label,
      helperText: helperText,
      suffixIcon: suffixIcon,
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

  String? _validateRequired(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'profile.required'.tr();
    }

    return null;
  }

  Future<void> _save() async {
    if (_isBusy) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repository = ref.read(doctorProfileRepositoryProvider);

      await repository.saveCurrentProfile(
        fullName: _nameController.text,
        specialty: _specialtyController.text,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('profile.saved'.tr())));

      ref.invalidate(doctorProfileProvider);
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('profile.saveFailed'.tr())));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _logOut() async {
    if (_isBusy) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoggingOut = true;
    });

    try {
      final repository = ref.read(authRepositoryProvider);

      await repository.signOut();
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('profile.logOutFailed'.tr())));
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.profile, required this.email});

  final DoctorProfile? profile;
  final String email;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final name = profile?.fullName.trim() ?? '';
    final specialty = profile?.specialty.trim() ?? '';

    final avatarName = name.isNotEmpty ? name : email;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          AppAvatar(name: avatarName, size: AppAvatarSize.large),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? '—' : name,
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  specialty.isEmpty ? '—' : specialty,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

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

class _AppearanceSelector extends StatelessWidget {
  const _AppearanceSelector({required this.value, required this.onChanged});

  static const _controlHeight = 52.0;

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: _controlHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              Expanded(
                child: _AppearanceOption(
                  label: 'profile.appearanceSystem'.tr(),
                  selected: value == ThemeMode.system,
                  onTap: () {
                    onChanged(ThemeMode.system);
                  },
                ),
              ),
              Expanded(
                child: _AppearanceOption(
                  label: 'profile.appearanceLight'.tr(),
                  selected: value == ThemeMode.light,
                  onTap: () {
                    onChanged(ThemeMode.light);
                  },
                ),
              ),
              Expanded(
                child: _AppearanceOption(
                  label: 'profile.appearanceDark'.tr(),
                  selected: value == ThemeMode.dark,
                  onTap: () {
                    onChanged(ThemeMode.dark);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppearanceOption extends StatelessWidget {
  const _AppearanceOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: selected
          ? colorScheme.primary.withValues(alpha: 0.12)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
