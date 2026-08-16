import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Champ de saisie unique pour l'app — le style vient entièrement de InputDecorationTheme
/// (voir AppTheme), ce widget n'ajoute que le label au-dessus et le message d'erreur en
/// dessous, dans une mise en page cohérente partout (connexion, création de publication, etc.).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.suffixIcon,
  });

  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: obscureText ? 1 : maxLines,
          enabled: enabled,
          onChanged: onChanged,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(hintText: hint, suffixIcon: suffixIcon),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(errorText!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.error)),
        ],
      ],
    );
  }
}
