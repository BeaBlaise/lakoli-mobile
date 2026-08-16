import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Rectangle animé (pulsation douce) pour les états de chargement — pas de dépendance externe
/// pour un effet aussi simple qu'une opacité qui respire. Composer plusieurs [SkeletonBox] pour
/// bâtir un squelette de carte de publication/école/vidéo (voir PublicationCardSkeleton).
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({super.key, this.width, this.height = 14, this.radius = 6});

  final double? width;
  final double height;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.35 + (_controller.value * 0.25),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(widget.radius)),
          ),
        );
      },
    );
  }
}
