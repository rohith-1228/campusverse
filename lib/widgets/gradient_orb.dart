import 'package:flutter/material.dart';

class GradientOrb extends StatelessWidget {
  final double size;
  final List<Color> colors;
  final Alignment center;
  final double blur;
  final double opacity;

  const GradientOrb({
    super.key,
    this.size = 280,
    required this.colors,
    this.center = Alignment.center,
    this.blur = 80,
    this.opacity = 0.45,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: center,
            radius: 0.85,
            colors: colors
                .map((c) => c.withAlpha((opacity * 255).round()))
                .toList(),
          ),
        ),
      ),
    );
  }
}
