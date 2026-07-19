import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/app_colors.dart';
import 'glass_card.dart';

class FeatureTile extends StatelessWidget {
  const FeatureTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.index = 0,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.goldGradient,
            ),
            child: Icon(icon, color: AppColors.black),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.accentSoft(context),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.accent(context)),
        ],
      ),
    )
        .animate(delay: (60 * index).ms)
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.15, end: 0);
  }
}
