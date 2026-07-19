import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Full-page gradient that follows dark / light mode.
class AppPageBackground extends StatelessWidget {
  const AppPageBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.pageGradient(context)),
      child: child,
    );
  }
}

/// Circular logo frame — black panel in light mode so the gold mark stays visible.
class BrandLogoBadge extends StatelessWidget {
  const BrandLogoBadge({
    super.key,
    required this.assetPath,
    this.size = 88,
  });

  final String assetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.logoPanel(context),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.55),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.18),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => SizedBox(
            width: size,
            height: size,
            child: Icon(
              Icons.diamond_outlined,
              color: AppColors.gold,
              size: size * 0.45,
            ),
          ),
        ),
      ),
    );
  }
}
