import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum AppAvatarSize { sm, md, lg, xl }

/// Avatar utilisateur/école — utilisé pour les deux, avec repli sur les initiales du nom quand
/// il n'y a pas de photo (jamais d'icône générique grise : le repli reste identifiable).
class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, this.imageUrl, required this.name, this.size = AppAvatarSize.md});

  final String? imageUrl;
  final String name;
  final AppAvatarSize size;

  double get _diameter => switch (size) {
        AppAvatarSize.sm => 28,
        AppAvatarSize.md => 40,
        AppAvatarSize.lg => 56,
        AppAvatarSize.xl => 88,
      };

  double get _fontSize => switch (size) {
        AppAvatarSize.sm => 11,
        AppAvatarSize.md => 15,
        AppAvatarSize.lg => 20,
        AppAvatarSize.xl => 32,
      };

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final diameter = _diameter;

    Widget fallback() => Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(color: colors.brand100, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            _initials,
            style: TextStyle(color: colors.brand600, fontWeight: FontWeight.w700, fontSize: _fontSize),
          ),
        );

    if (imageUrl == null || imageUrl!.isEmpty) return fallback();

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: diameter,
        height: diameter,
        fit: BoxFit.cover,
        placeholder: (context, url) => fallback(),
        errorWidget: (context, url, error) => fallback(),
      ),
    );
  }
}
