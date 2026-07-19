import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/providers.dart';
import '../../../widgets/app_page_background.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1800), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final complete = ref.read(settingsServiceProvider).onboardingComplete;
    context.go(complete ? '/home' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: AppColors.pageGradient(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BrandLogoBadge(assetPath: AppConstants.logoAsset, size: 120)
                .animate()
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 600.ms),
            const SizedBox(height: 28),
            Text(
              AppConstants.appName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.accentSoft(context),
                    fontWeight: FontWeight.bold,
                  ),
            )
                .animate(delay: 300.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 8),
            Text(
              AppConstants.companyName,
              style: TextStyle(color: AppColors.textSecondary(context)),
            ).animate(delay: 450.ms).fadeIn(duration: 500.ms),
            const SizedBox(height: 48),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.gold,
              ),
            ).animate(delay: 600.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}
