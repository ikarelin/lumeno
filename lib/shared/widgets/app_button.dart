import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class AppButton extends StatelessWidget {
  const AppButton._({
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    super.key,
  });

  factory AppButton.primary({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    Key? key,
  }) {
    return AppButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: icon,
      variant: AppButtonVariant.primary,
    );
  }

  factory AppButton.secondary({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    Key? key,
  }) {
    return AppButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: icon,
      variant: AppButtonVariant.secondary,
    );
  }

  factory AppButton.text({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    Key? key,
  }) {
    return AppButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: icon,
      variant: AppButtonVariant.text,
    );
  }

  final String label;

  final VoidCallback onPressed;

  final IconData? icon;

  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case AppButtonVariant.primary:
        return _buildFilledButton(context);

      case AppButtonVariant.secondary:
        return _buildOutlinedButton(context);

      case AppButtonVariant.text:
        return _buildTextButton(context);
    }
  }

  Widget _buildFilledButton(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,

      icon: _icon(),

      label: Text(label),

      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),

        textStyle: AppTextStyles.button,
      ),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,

      icon: _icon(),

      label: Text(label),

      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),

        textStyle: AppTextStyles.button,
      ),
    );
  }

  Widget _buildTextButton(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,

      icon: _icon(),

      label: Text(label),

      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),

        textStyle: AppTextStyles.button,
      ),
    );
  }

  Widget _icon() {
    if (icon == null) {
      return const SizedBox.shrink();
    }

    return Icon(icon);
  }
}

enum AppButtonVariant { primary, secondary, text }
