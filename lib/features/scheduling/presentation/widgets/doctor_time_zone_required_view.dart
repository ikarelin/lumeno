import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// A recoverable setup state, not a generic calendar/network load error.
/// Do not show this view for other errors or infer a zone from the device.
class DoctorTimeZoneRequiredView extends StatelessWidget {
  const DoctorTimeZoneRequiredView({
    super.key,
    required this.onOpenProfile,
  });

  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.public_rounded, size: 40),
              const SizedBox(height: 16),
              Text('profile.timeZone'.tr(), style: textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(
                'calendar.timeZoneSetupRequired'.tr(),
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onOpenProfile,
                icon: const Icon(Icons.settings_outlined),
                label: Text('calendar.timeZoneSetupAction'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
