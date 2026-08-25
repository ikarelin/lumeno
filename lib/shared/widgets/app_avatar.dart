import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppAvatarSize.medium,
  });

  final String? imageUrl;

  final String? name;

  final AppAvatarSize size;

  @override
  Widget build(BuildContext context) {
    final avatarSize = _avatarSize;

    return CircleAvatar(
      radius: avatarSize / 2,

      backgroundColor: AppColors.brand.withValues(alpha: 0.12),

      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,

      child: imageUrl == null
          ? Text(
              _initials,
              style: TextStyle(
                color: AppColors.brand,
                fontSize: avatarSize * 0.35,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
    );
  }

  double get _avatarSize {
    switch (size) {
      case AppAvatarSize.small:
        return 32;

      case AppAvatarSize.medium:
        return 48;

      case AppAvatarSize.large:
        return 64;
    }
  }

  String get _initials {
    if (name == null || name!.trim().isEmpty) {
      return '?';
    }

    final parts = name!
        .trim()
        .split(' ')
        .where((element) => element.isNotEmpty)
        .toList();

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

enum AppAvatarSize { small, medium, large }
