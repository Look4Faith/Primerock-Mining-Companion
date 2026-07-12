import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/providers.dart';
import '../../../widgets/feature_tile.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayName = ref.watch(settingsServiceProvider).displayName;
    final greeting = displayName.isNotEmpty ? 'Welcome, $displayName' : 'Welcome, Miner';

    final features = [
      _Feature(
        title: 'Gold Price',
        subtitle: 'FGR buying rates (USD/g & oz)',
        icon: Icons.show_chart_rounded,
        route: '/gold-prices',
      ),
      _Feature(
        title: 'Calculators',
        subtitle: 'Ore grade, recovery & profit tools',
        icon: Icons.calculate_outlined,
        route: '/calculators',
      ),
      _Feature(
        title: 'Knowledge Hub',
        subtitle: 'Mining guides & best practices',
        icon: Icons.menu_book_outlined,
        route: '/knowledge',
      ),
      _Feature(
        title: 'Mining News',
        subtitle: 'Industry & gold updates',
        icon: Icons.newspaper_outlined,
        route: '/news',
      ),
      _Feature(
        title: 'Mining Assistant',
        subtitle: 'Ask questions offline',
        icon: Icons.smart_toy_outlined,
        route: '/assistant',
      ),
      _Feature(
        title: 'Production Records',
        subtitle: 'Track ore, gold & finances',
        icon: Icons.assignment_outlined,
        route: '/records',
      ),
      _Feature(
        title: 'Primerock Laboratory',
        subtitle: 'Assays, fire assay & more',
        icon: Icons.science_outlined,
        route: '/laboratory',
      ),
      _Feature(
        title: 'Book Consultation',
        subtitle: 'WhatsApp Primerock lab',
        icon: Icons.event_available_outlined,
        route: '/booking',
      ),
      _Feature(
        title: 'Contact',
        subtitle: 'Reach Primerock Solutions',
        icon: Icons.contact_phone_outlined,
        route: '/contact',
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                title: Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Settings',
                    onPressed: () => context.push('/settings'),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.15),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              AppConstants.logoAsset,
                              width: 88,
                              height: 88,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 88,
                                height: 88,
                                color: AppColors.surfaceElevated,
                                child: const Icon(
                                  Icons.diamond_outlined,
                                  color: AppColors.gold,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        greeting,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.goldLight,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your offline-first mining companion by ${AppConstants.companyName}.',
                        style: const TextStyle(color: AppColors.white70, height: 1.4),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Tools & Services',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: features.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final f = features[index];
                    return FeatureTile(
                      index: index,
                      title: f.title,
                      subtitle: f.subtitle,
                      icon: f.icon,
                      onTap: () => context.push(f.route),
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature {
  const _Feature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
}
