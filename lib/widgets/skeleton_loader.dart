import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../core/theme/app_colors.dart';

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({
    super.key,
    this.height = 88,
    this.count = 3,
  });

  final double height;
  final int count;

  @override
  Widget build(BuildContext context) {
    final base = AppColors.elevated(context);
    final highlight = AppColors.isDark(context)
        ? AppColors.card
        : AppColors.lightCard;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Column(
        children: List.generate(
          count,
          (i) => Container(
            height: height,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
