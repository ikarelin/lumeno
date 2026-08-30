import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../features/profile/presentation/providers/doctor_profile_provider.dart';

class SidebarProfile extends ConsumerWidget {
  const SidebarProfile({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final currentPath = GoRouterState.of(context).uri.path;

    final isSelected =
        currentPath == '/profile' || currentPath.startsWith('/profile/');

    final profile = ref
        .watch(doctorProfileProvider)
        .when(
          data: (profile) => profile,
          loading: () => null,
          error: (_, _) => null,
        );

    final fullName = profile?.fullName ?? '—';
    final specialty = profile?.specialty ?? '—';
    final initials = _initials(profile?.fullName);

    final backgroundColor = isSelected
        ? colorScheme.primaryContainer
        : Colors.transparent;

    final foregroundColor = isSelected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    final secondaryForegroundColor = isSelected
        ? colorScheme.onPrimaryContainer.withValues(alpha: 0.72)
        : colorScheme.onSurfaceVariant;

    final avatarBackgroundColor = isSelected
        ? colorScheme.primary
        : colorScheme.primaryContainer;

    final avatarForegroundColor = isSelected
        ? colorScheme.onPrimary
        : colorScheme.onPrimaryContainer;

    final borderColor = isSelected
        ? colorScheme.primary.withValues(alpha: 0.32)
        : colorScheme.outlineVariant;

    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            onTap ??
            () {
              if (isSelected) {
                return;
              }

              context.push('/profile');
            },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: avatarBackgroundColor,
                foregroundColor: avatarForegroundColor,
                child: initials == null
                    ? const Icon(Icons.person_outline_rounded, size: 20)
                    : Text(
                        initials,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: avatarForegroundColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      specialty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: secondaryForegroundColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: secondaryForegroundColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _initials(String? fullName) {
    if (fullName == null) {
      return null;
    }

    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return null;
    }

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
