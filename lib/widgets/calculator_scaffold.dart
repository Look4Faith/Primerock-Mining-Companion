import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'glass_card.dart';

class CalculatorScaffold extends StatelessWidget {
  const CalculatorScaffold({
    super.key,
    required this.title,
    required this.explanation,
    required this.form,
    this.result,
    this.history,
  });

  final String title;
  final String explanation;
  final Widget form;
  final Widget? result;
  final Widget? history;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How it works',
                  style: TextStyle(
                    color: AppColors.goldLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  explanation,
                  style: const TextStyle(color: AppColors.white70, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          form,
          if (result != null) ...[
            const SizedBox(height: 16),
            result!,
          ],
          if (history != null) ...[
            const SizedBox(height: 24),
            const Text(
              'Recent calculations',
              style: TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            history!,
          ],
        ],
      ),
    );
  }
}

class ResultBanner extends StatelessWidget {
  const ResultBanner({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.white70)),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.goldLight,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
