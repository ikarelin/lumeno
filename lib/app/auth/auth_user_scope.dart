import 'dart:async';

import 'package:flutter/widgets.dart';

/// Gives each authenticated user a fresh widget subtree. Place ProviderScope
/// inside [child] so all user-specific Riverpod caches are disposed when the
/// Supabase session changes (including sign-out).
class AuthUserScope extends StatefulWidget {
  const AuthUserScope({
    required this.initialUserId,
    required this.userIds,
    required this.child,
    super.key,
  });

  final String? initialUserId;
  final Stream<String?> userIds;
  final Widget child;

  @override
  State<AuthUserScope> createState() => _AuthUserScopeState();
}

class _AuthUserScopeState extends State<AuthUserScope> {
  late String? _userId;
  late final StreamSubscription<String?> _subscription;

  @override
  void initState() {
    super.initState();
    _userId = widget.initialUserId;
    _subscription = widget.userIds.listen((nextUserId) {
      if (!mounted || nextUserId == _userId) return;
      setState(() => _userId = nextUserId);
    });
  }

  @override
  Widget build(BuildContext context) => KeyedSubtree(
        key: ValueKey<String?>(_userId),
        child: widget.child,
      );

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
