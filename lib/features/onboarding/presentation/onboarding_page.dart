import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/providers.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardSlide(
      icon: Icons.home_work_outlined,
      title: 'Your Mining Companion',
      body:
          'Primerock Mining Companion brings gold prices, calculators, knowledge, and production tracking into one premium offline-first app.',
    ),
    _OnboardSlide(
      icon: Icons.calculate_outlined,
      title: 'Offline Calculators',
      body:
          'Run ore grade, recovery, and profit calculations in the field — no signal required. Save history for later review.',
    ),
    _OnboardSlide(
      icon: Icons.science_outlined,
      title: 'Primerock Laboratory',
      body:
          'Connect with Primerock Solutions for fire assay, bullion analysis, and trusted lab services across Zimbabwe.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final settings = ref.read(settingsServiceProvider);
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await settings.setDisplayName(name);
    }
    await settings.setOnboardingComplete(true);
    if (mounted) context.go('/home');
  }

  void _skip() => _finish();

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.pageGradient(context)),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _skip,
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    final slide = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(slide.icon, size: 72, color: AppColors.gold)
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .scale(begin: const Offset(0.9, 0.9)),
                          const SizedBox(height: 32),
                          Text(
                            slide.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppColors.accentSoft(context),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            slide.body,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary(context),
                              height: 1.5,
                              fontSize: 15,
                            ),
                          ),
                          if (isLast && index == _pages.length - 1) ...[
                            const SizedBox(height: 32),
                            TextField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Your name (optional)',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? AppColors.gold
                          : AppColors.textMuted(context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _next,
                    child: Text(isLast ? 'Get Started' : 'Continue'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  AppConstants.companyName,
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardSlide {
  const _OnboardSlide({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}
