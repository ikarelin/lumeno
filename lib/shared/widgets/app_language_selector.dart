import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_popup_menu.dart';

class AppLanguageSelector extends StatelessWidget {
  const AppLanguageSelector({super.key});

  static const _languages = [Locale('en'), Locale('ru')];

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final colorScheme = Theme.of(context).colorScheme;

    return AppPopupMenu<Locale>(
      onSelected: (selectedLocale) async {
        await context.setLocale(selectedLocale);
      },
      itemBuilder: (context) {
        return _languages.map((locale) {
          return AppPopupMenuItem<Locale>(
            value: locale,
            label: _languageName(locale),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              locale.languageCode.toUpperCase(),
              style: AppTextStyles.labelMedium,
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  String _languageName(Locale locale) {
    switch (locale.languageCode) {
      case 'ru':
        return 'onboarding.language.russian'.tr();
      case 'en':
      default:
        return 'onboarding.language.english'.tr();
    }
  }
}
