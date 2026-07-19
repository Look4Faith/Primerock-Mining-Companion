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
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.pageGradient(context)),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How it works',
                    style: TextStyle(
                      color: AppColors.accentSoft(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    explanation,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      height: 1.4,
                    ),
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
              Text(
                'Recent calculations',
                style: TextStyle(
                  color: AppColors.accent(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              history!,
            ],
          ],
        ),
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
          Text(label, style: TextStyle(color: AppColors.textSecondary(context))),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.accentSoft(context),
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
