import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import 'providers/patient_provider.dart';

class PatientsPage extends ConsumerStatefulWidget {
  const PatientsPage({super.key});

  @override
  ConsumerState<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends ConsumerState<PatientsPage> {
  static const _contentMaxWidth = 1120.0;
  static const _searchMaxWidth = 520.0;
  static const _loadingHeight = 320.0;

  final _searchController = TextEditingController();

  String _query = '';
  bool _isPresentingQuickCreate = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patients = ref.watch(patientsProvider);

    final isDesktop =
        MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;

    final patientCount = patients.when<int?>(
      data: (items) => items.length,
      loading: () => null,
      error: (_, _) => null,
    );

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
                  _PatientsHeader(
                    isDesktop: isDesktop,
                    patientCount: patientCount,
                    isBusy: _isPresentingQuickCreate,
                    onAddPatient: _openNewPatient,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  patients.when(
                    data: (items) {
                      return _PatientsContent(
                        patients: items,
                        query: _query,
                        searchController: _searchController,
                        isDesktop: isDesktop,
                        isQuickCreateBusy: _isPresentingQuickCreate,
                        onSearchChanged: (value) {
                          setState(() {
                            _query = value;
                          });
                        },
                        onClearSearch: _clearSearch,
                        onAddPatient: _openNewPatient,
                        onNewVisit: _openNewVisit,
                      );
                    },
                    loading: () {
                      return const SizedBox(
                        height: _loadingHeight,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    error: (_, _) {
                      return _PatientsLoadError(
                        onRetry: () {
                          ref.invalidate(patientsProvider);
                        },
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

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _query = '';
    });
  }

  Future<void> _openNewPatient() async {
    if (_isPresentingQuickCreate) {
      return;
    }

    setState(() {
      _isPresentingQuickCreate = true;
    });

    try {
      await QuickCreatePresenter.show(
        context,
        const QuickCreateContext(
          intent: QuickCreateIntent.newPatient,
          source: QuickCreateSource.patients,
        ),
      );

      if (!mounted) {
        return;
      }

      ref.invalidate(patientsProvider);
    } finally {
      if (mounted) {
        setState(() {
          _isPresentingQuickCreate = false;
        });
      }
    }
  }

  Future<void> _openNewVisit(Patient patient) async {
    if (_isPresentingQuickCreate) {
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
          patient: patient,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPresentingQuickCreate = false;
        });
      }
    }
  }
}

class _PatientsHeader extends StatelessWidget {
  const _PatientsHeader({
    required this.isDesktop,
    required this.patientCount,
    required this.isBusy,
    required this.onAddPatient,
  });

  final bool isDesktop;
  final int? patientCount;
  final bool isBusy;
  final VoidCallback onAddPatient;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final title = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            'patients.title'.tr(),
            style: isDesktop
                ? AppTextStyles.headlineLarge
                : AppTextStyles.headlineMedium,
          ),
        ),
        if (patientCount case final count?) ...[
          const SizedBox(width: AppSpacing.sm),
          Container(
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );

    if (!isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: title),
              const SizedBox(width: AppSpacing.md),
              IconButton.filled(
                tooltip: 'patients.addPatient'.tr(),
                onPressed: isBusy ? null : onAddPatient,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'patients.description'.tr(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: AppSpacing.sm),
              Text(
                'patients.description'.tr(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        AppButton.primary(
          label: 'patients.addPatient'.tr(),
          icon: Icons.add_rounded,
          onPressed: isBusy ? null : onAddPatient,
        ),
      ],
    );
  }
}

class _PatientsContent extends StatelessWidget {
  const _PatientsContent({
    required this.patients,
    required this.query,
    required this.searchController,
    required this.isDesktop,
    required this.isQuickCreateBusy,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onAddPatient,
    required this.onNewVisit,
  });

  final List<Patient> patients;
  final String query;
  final TextEditingController searchController;
  final bool isDesktop;
  final bool isQuickCreateBusy;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onAddPatient;
  final ValueChanged<Patient> onNewVisit;

  @override
  Widget build(BuildContext context) {
    if (patients.isEmpty) {
      return _PatientsEmptyState(
        onAddPatient: onAddPatient,
        isBusy: isQuickCreateBusy,
      );
    }

    final normalizedQuery = query.trim().toLowerCase();

    final filteredPatients = normalizedQuery.isEmpty
        ? patients
        : patients.where((patient) {
            return patient.name.toLowerCase().contains(normalizedQuery) ||
                patient.phone.toLowerCase().contains(normalizedQuery);
          }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: _PatientsPageState._searchMaxWidth,
          ),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: _searchDecoration(
              context,
              hasQuery: normalizedQuery.isNotEmpty,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (filteredPatients.isEmpty)
          const _PatientsNoResults()
        else if (isDesktop)
          _DesktopPatientsList(
            patients: filteredPatients,
            isQuickCreateBusy: isQuickCreateBusy,
            onNewVisit: onNewVisit,
          )
        else
          _MobilePatientsList(
            patients: filteredPatients,
            isQuickCreateBusy: isQuickCreateBusy,
            onNewVisit: onNewVisit,
          ),
      ],
    );
  }

  InputDecoration _searchDecoration(
    BuildContext context, {
    required bool hasQuery,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );

    return InputDecoration(
      hintText: 'patients.searchHint'.tr(),
      prefixIcon: const Icon(Icons.search_rounded),
      suffixIcon: hasQuery
          ? IconButton(
              onPressed: onClearSearch,
              tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
              icon: const Icon(Icons.close_rounded),
            )
          : null,
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.30 : 0.45,
      ),
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
}

class _DesktopPatientsList extends StatelessWidget {
  const _DesktopPatientsList({
    required this.patients,
    required this.isQuickCreateBusy,
    required this.onNewVisit,
  });

  final List<Patient> patients;
  final bool isQuickCreateBusy;
  final ValueChanged<Patient> onNewVisit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const _DesktopPatientsHeaderRow(),
          Divider(height: 1, color: colorScheme.outlineVariant),
          for (var index = 0; index < patients.length; index++) ...[
            _DesktopPatientRow(
              patient: patients[index],
              isQuickCreateBusy: isQuickCreateBusy,
              onNewVisit: () {
                onNewVisit(patients[index]);
              },
            ),
            if (index < patients.length - 1)
              Divider(height: 1, color: colorScheme.outlineVariant),
          ],
        ],
      ),
    );
  }
}

class _DesktopPatientsHeaderRow extends StatelessWidget {
  const _DesktopPatientsHeaderRow();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text('patients.name'.tr().toUpperCase(), style: style),
          ),
          Expanded(
            flex: 3,
            child: Text('patients.phone'.tr().toUpperCase(), style: style),
          ),
          Expanded(
            flex: 4,
            child: Text('patients.note'.tr().toUpperCase(), style: style),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _DesktopPatientRow extends StatelessWidget {
  const _DesktopPatientRow({
    required this.patient,
    required this.isQuickCreateBusy,
    required this.onNewVisit,
  });

  final Patient patient;
  final bool isQuickCreateBusy;
  final VoidCallback onNewVisit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final note = patient.note.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                _PatientAvatar(name: patient.name),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    patient.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              patient.phone,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              note.isEmpty ? '—' : note,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: IconButton(
              tooltip: 'dashboard.quickActionsItems.newVisit.title'.tr(),
              onPressed: isQuickCreateBusy ? null : onNewVisit,
              icon: const Icon(Icons.calendar_month_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobilePatientsList extends StatelessWidget {
  const _MobilePatientsList({
    required this.patients,
    required this.isQuickCreateBusy,
    required this.onNewVisit,
  });

  final List<Patient> patients;
  final bool isQuickCreateBusy;
  final ValueChanged<Patient> onNewVisit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < patients.length; index++) ...[
            _MobilePatientRow(
              patient: patients[index],
              isQuickCreateBusy: isQuickCreateBusy,
              onNewVisit: () {
                onNewVisit(patients[index]);
              },
            ),
            if (index < patients.length - 1)
              Divider(
                height: 1,
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
                color: colorScheme.outlineVariant,
              ),
          ],
        ],
      ),
    );
  }
}

class _MobilePatientRow extends StatelessWidget {
  const _MobilePatientRow({
    required this.patient,
    required this.isQuickCreateBusy,
    required this.onNewVisit,
  });

  final Patient patient;
  final bool isQuickCreateBusy;
  final VoidCallback onNewVisit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final note = patient.note.trim();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _PatientAvatar(name: patient.name),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  patient.phone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (note.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            tooltip: 'dashboard.quickActionsItems.newVisit.title'.tr(),
            onPressed: isQuickCreateBusy ? null : onNewVisit,
            icon: const Icon(Icons.calendar_month_rounded),
          ),
        ],
      ),
    );
  }
}

class _PatientAvatar extends StatelessWidget {
  const _PatientAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: Text(
        _initials(name),
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w700),
      ),
    );
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      final word = parts.first;
      return word.substring(0, word.length >= 2 ? 2 : 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _PatientsEmptyState extends StatelessWidget {
  const _PatientsEmptyState({required this.onAddPatient, required this.isBusy});

  final VoidCallback onAddPatient;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: 56,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'patients.emptyTitle'.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'patients.emptyDescription'.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton.primary(
                label: 'patients.addPatient'.tr(),
                icon: Icons.add_rounded,
                onPressed: isBusy ? null : onAddPatient,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientsNoResults extends StatelessWidget {
  const _PatientsNoResults();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: 48,
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 32,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'patients.noResults'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientsLoadError extends StatelessWidget {
  const _PatientsLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colorScheme.error),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'patients.loadFailed'.tr(),
              style: AppTextStyles.bodyMedium,
            ),
          ),
          IconButton(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}
