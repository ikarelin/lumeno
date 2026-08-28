import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class AppLanguageSelector extends StatelessWidget {
  const AppLanguageSelector({super.key});

  static const _languages = [Locale('en'), Locale('ru')];

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: () => _showLanguageMenu(context),
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

  Future<void> _showLanguageMenu(BuildContext context) async {
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    final selectedLocale = await showMenu<Locale>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + renderBox.size.height,
        position.dx + renderBox.size.width,
        0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      color: Theme.of(context).colorScheme.surface,
      items: _languages.map((locale) {
        return PopupMenuItem<Locale>(
          value: locale,
          child: Text(_languageName(locale), style: AppTextStyles.bodyMedium),
        );
      }).toList(),
    );

    if (selectedLocale != null && context.mounted) {
      await context.setLocale(selectedLocale);
    }
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
