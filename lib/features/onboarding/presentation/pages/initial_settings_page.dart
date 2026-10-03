import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../widgets/onboarding_page_frame.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../scheduling/domain/doctor_calendar_time.dart';

class InitialSettingsPage extends StatefulWidget {
  const InitialSettingsPage({super.key, this.deviceTimeZoneLoader});

  final Future<String?> Function()? deviceTimeZoneLoader;

  @override
  State<InitialSettingsPage> createState() => _InitialSettingsPageState();
}

class _InitialSettingsPageState extends State<InitialSettingsPage> {
  static const _timeZoneQueryKey = 'timeZoneId';

  String? _timeZoneId;

  bool _initialized = false;
  bool _isLoadingDeviceTimeZone = false;

  bool get _canContinue => _timeZoneId != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) {
      return;
    }

    _initialized = true;

    final uri = GoRouterState.of(context).uri;
    final routeTimeZone = uri.queryParameters[_timeZoneQueryKey];

    if (_isKnownTimeZone(routeTimeZone)) {
      _timeZoneId = routeTimeZone;
    } else {
      _isLoadingDeviceTimeZone = true;
      _loadDeviceTimeZone();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final languageCode = context.locale.languageCode;

    return OnboardingPageFrame(
      title: 'onboarding.initialSettings.title'.tr(),
      description: 'onboarding.initialSettings.description'.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionLabel(label: 'onboarding.initialSettings.language'.tr()),
          const SizedBox(height: AppSpacing.sm),
          _LanguageSelector(
            languageCode: languageCode,
            onSelected: _changeLanguage,
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionLabel(label: 'onboarding.initialSettings.timeZone'.tr()),
          const SizedBox(height: AppSpacing.sm),
          _TimeZoneSelector(
            value: _timeZoneId,
            isLoading: _isLoadingDeviceTimeZone,
            onTap: _selectTimeZone,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'onboarding.initialSettings.timeZoneHint'.tr(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _InfoNote(
            title: 'onboarding.initialSettings.visitTimeTitle'.tr(),
            body: 'onboarding.initialSettings.visitTimeNote'.tr(),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton.primary(
            label: 'onboarding.initialSettings.continue'.tr(),
            fullWidth: true,
            onPressed: _canContinue ? _continue : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton.text(
            label: MaterialLocalizations.of(context).backButtonTooltip,
            fullWidth: true,
            onPressed: () => context.go('/welcome'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadDeviceTimeZone() async {
    try {
      final id = await _resolveDeviceTimeZone();

      if (!mounted) {
        return;
      }

      if (_isKnownTimeZone(id) && _timeZoneId == null) {
        setState(() {
          _timeZoneId = id;
        });
      }
    } catch (_) {
      // Device detection is a convenience only. Manual IANA selection remains
      // available and is required before the user can continue.
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDeviceTimeZone = false;
        });
      }
    }
  }

  Future<String?> _resolveDeviceTimeZone() async {
    final loader = widget.deviceTimeZoneLoader;

    if (loader != null) {
      return loader();
    }

    final info = await FlutterTimezone.getLocalTimezone();
    return info.identifier;
  }

  Future<void> _changeLanguage(String languageCode) async {
    final locale = Locale(languageCode);

    if (context.locale == locale) {
      return;
    }

    await context.setLocale(locale);

    if (!mounted) {
      return;
    }
  }

  Future<void> _selectTimeZone() async {
    final ids = DoctorCalendarTime.availableTimeZoneIds;
    var search = '';

    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, updateSearch) {
          final normalizedSearch = search.trim().toLowerCase();
          final matches = normalizedSearch.isEmpty
              ? ids
              : ids
                    .where((id) => id.toLowerCase().contains(normalizedSearch))
                    .toList();

          return AlertDialog(
            title: Text('onboarding.initialSettings.timeZone'.tr()),
            content: SizedBox(
              width: 440,
              height: MediaQuery.sizeOf(dialogContext).height * 0.55,
              child: Column(
                children: [
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'onboarding.initialSettings.timeZoneSearch'
                          .tr(),
                      prefixIcon: const Icon(Icons.search_rounded),
                    ),
                    onChanged: (value) {
                      updateSearch(() {
                        search = value;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: ListView.builder(
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final id = matches[index];

                        return ListTile(
                          title: Text(id),
                          selected: id == _timeZoneId,
                          onTap: () => Navigator.of(dialogContext).pop(id),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  MaterialLocalizations.of(context).cancelButtonLabel,
                ),
              ),
            ],
          );
        },
      ),
    );

    if (selected != null && mounted) {
      setState(() {
        _timeZoneId = selected;
      });
    }
  }

  void _continue() {
    final timeZoneId = _timeZoneId;

    if (timeZoneId == null) {
      return;
    }

    context.go(
      Uri(
        path: '/sign-up',
        queryParameters: {_timeZoneQueryKey: timeZoneId},
      ).toString(),
    );
  }

  bool _isKnownTimeZone(String? id) {
    return id != null && DoctorCalendarTime.availableTimeZoneIds.contains(id);
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.titleLarge);
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.languageCode,
    required this.onSelected,
  });

  final String languageCode;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _LanguageOption(
            label: 'onboarding.language.russian'.tr(),
            selected: languageCode == 'ru',
            onTap: () => onSelected('ru'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _LanguageOption(
            label: 'onboarding.language.english'.tr(),
            selected: languageCode != 'ru',
            onTap: () => onSelected('en'),
          ),
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surface = theme.brightness == Brightness.dark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minHeight: 52),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.10)
                : surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.button.copyWith(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeZoneSelector extends StatelessWidget {
  const _TimeZoneSelector({
    required this.value,
    required this.isLoading,
    required this.onTap,
  });

  final String? value;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surface = theme.brightness == Brightness.dark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(Icons.public_rounded, color: colorScheme.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  value ??
                      (isLoading
                          ? 'onboarding.initialSettings.timeZoneDetecting'.tr()
                          : 'onboarding.initialSettings.timeZoneChoose'.tr()),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(Icons.chevron_right_rounded, color: colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  const _InfoNote({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.schedule_rounded, size: 20, color: colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  body,
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
