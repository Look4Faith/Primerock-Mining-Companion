import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/feature_tile.dart';
import '../../../widgets/section_header.dart';
import '../domain/calculator_definitions.dart';

class CalculatorsHubPage extends StatelessWidget {
  const CalculatorsHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mining Calculators')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(
            title: 'Calculator Suite',
            subtitle:
                'Plant-lab formulas for gold value, recovery, cyanide, slurry, pH, and more.',
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final useGrid = constraints.maxWidth >= 600;
              if (!useGrid) {
                return Column(
                  children: [
                    for (var i = 0; i < kCalculators.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      FeatureTile(
                        index: i,
                        title: kCalculators[i].title,
                        subtitle: kCalculators[i].subtitle,
                        icon: kCalculators[i].icon,
                        onTap: () => context.push(kCalculators[i].route),
                      ),
                    ],
                  ],
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.35,
                ),
                itemCount: kCalculators.length,
                itemBuilder: (context, index) {
                  final calc = kCalculators[index];
                  return _CalculatorGridCard(
                    definition: calc,
                    onTap: () => context.push(calc.route),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CalculatorGridCard extends StatelessWidget {
  const _CalculatorGridCard({
    required this.definition,
    required this.onTap,
  });

  final CalculatorDefinition definition;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.glass,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.goldGradient,
                ),
                child: Icon(definition.icon, color: AppColors.black),
              ),
              const Spacer(),
              Text(
                definition.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.accentSoft(context),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                definition.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
