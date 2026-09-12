import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/providers/auth_repository_provider.dart';
import '../../features/profile/presentation/providers/doctor_profile_provider.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/app_card.dart';
import '../navigation/app_navigation_items.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class MobileShell extends ConsumerWidget {
  const MobileShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lumeno'),
        leading: Builder(
          builder: (context) {
            return IconButton(
              tooltip: 'mobileShell.openMenu'.tr(),
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
      ),
      drawer: _MobileDrawer(ref: ref),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateIndex(context),
        onDestinationSelected: (index) {
          context.go(AppNavigationItems.items[index].path);
        },
        destinations: AppNavigationItems.items
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.translationKey.tr(),
              ),
            )
            .toList(),
      ),
    );
  }

  int _calculateIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    for (var i = 0; i < AppNavigationItems.items.length; i++) {
      if (location.startsWith(AppNavigationItems.items[i].path)) {
        return i;
      }
    }

    return 0;
  }
}

class _MobileDrawer extends StatelessWidget {
  const _MobileDrawer({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final profile = ref
        .watch(doctorProfileProvider)
        .when(
          data: (profile) => profile,
          loading: () => null,
          error: (_, _) => null,
        );
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata;
    final name =
        profile?.fullName ??
        metadata?['doctor_name'] as String? ??
        user?.email ??
        'Lumeno';
    final specialty = profile?.specialty ?? metadata?['specialty'] as String?;

    return Drawer(
      width: 340,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Lumeno', style: AppTextStyles.titleLarge),
                  ),
                  IconButton(
                    tooltip: 'mobileShell.closeMenu'.tr(),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/profile');
                  },
                  child: Row(
                    children: [
                      AppAvatar(name: name, size: AppAvatarSize.medium),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (specialty != null) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                specialty,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _DrawerSectionLabel(label: 'mobileShell.account'.tr()),
              _DrawerItem(
                icon: Icons.person_outline_rounded,
                label: 'mobileShell.profile'.tr(),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/profile');
                },
              ),
              const Spacer(),
              _DrawerItem(
                icon: Icons.logout_rounded,
                label: 'mobileShell.logOut'.tr(),
                onTap: () async {
                  Navigator.of(context).pop();
                  await ref.read(authRepositoryProvider).signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerSectionLabel extends StatelessWidget {
  const _DrawerSectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelMedium.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      leading: Icon(icon),
      title: Text(label, style: AppTextStyles.bodyMedium),
      onTap: onTap,
    );
  }
}
