import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class AppButton extends StatelessWidget {
  const AppButton._({
    required this.label,
    required this.onPressed,
    required this.variant,
    this.icon,
    this.fullWidth = false,
    super.key,
  });

  factory AppButton.primary({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    bool fullWidth = false,
    Key? key,
  }) {
    return AppButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: icon,
      fullWidth: fullWidth,
      variant: AppButtonVariant.primary,
    );
  }

  factory AppButton.secondary({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    bool fullWidth = false,
    Key? key,
  }) {
    return AppButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: icon,
      fullWidth: fullWidth,
      variant: AppButtonVariant.secondary,
    );
  }

  factory AppButton.text({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    bool fullWidth = false,
    Key? key,
  }) {
    return AppButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: icon,
      fullWidth: fullWidth,
      variant: AppButtonVariant.text,
    );
  }

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool fullWidth;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final button = switch (variant) {
      AppButtonVariant.primary => _buildFilledButton(),
      AppButtonVariant.secondary => _buildOutlinedButton(),
      AppButtonVariant.text => _buildTextButton(),
    };

    if (!fullWidth) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }

  Widget _buildFilledButton() {
    final style = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(52),

      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      textStyle: AppTextStyles.button,
    );

    if (icon case final icon?) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: style,
      );
    }

    return FilledButton(onPressed: onPressed, style: style, child: Text(label));
  }

  Widget _buildOutlinedButton() {
    final style = OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(52),

      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      textStyle: AppTextStyles.button,
    );

    if (icon case final icon?) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: style,
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: style,
      child: Text(label),
    );
  }

  Widget _buildTextButton() {
    final style = TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      textStyle: AppTextStyles.button,
    );

    if (icon case final icon?) {
      return TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: style,
      );
    }

    return TextButton(onPressed: onPressed, style: style, child: Text(label));
  }
}

enum AppButtonVariant { primary, secondary, text }
