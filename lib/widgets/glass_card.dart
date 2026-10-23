import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final Gradient? borderGradient;
  final Gradient? backgroundGradient;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 22.0,
    this.blur = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.onTap,
    this.borderGradient,
    this.backgroundGradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBg = isDark
        ? AppColors.darkGlassCard
        : AppColors.lightGlassCard;

    final defaultBorder = isDark
        ? AppColors.darkGlassBorder
        : AppColors.lightGlassBorder;

    Widget cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundGradient == null ? (backgroundColor ?? defaultBg) : null,
        gradient: backgroundGradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );

    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: AppColors.primary.withAlpha((0.2 * 255).round()),
        highlightColor: AppColors.primary.withAlpha((0.1 * 255).round()),
        child: cardContent,
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha((0.25 * 255).round())
                : AppColors.primary.withAlpha((0.08 * 255).round()),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? defaultBorder,
                width: borderWidth,
              ),
            ),
            child: cardContent,
          ),
        ),
      ),
    );
  }
}
