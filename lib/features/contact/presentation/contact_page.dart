import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/contact_launcher.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/skeleton_loader.dart';
import '../../laboratory/providers/lab_content_provider.dart';

class ContactPage extends ConsumerWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(labContentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: contentAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: SkeletonLoader(height: 80, count: 4),
          ),
          error: (e, _) => ErrorState(
            message: e.toString(),
            onRetry: () => ref.invalidate(labContentProvider),
          ),
          data: (content) {
            final contact = content.contact;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.companyName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.goldLight,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        contact.address,
                        style: const TextStyle(color: AppColors.white70, height: 1.4),
                      ),
                      if (contact.hours != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          contact.hours!,
                          style: const TextStyle(color: AppColors.white38),
                        ),
                      ],
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.1),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Get in Touch'),
                _ContactButton(
                  icon: Icons.phone,
                  label: 'Call',
                  subtitle: contact.phone,
                  onTap: () => _launch(context, () => ContactLauncher.phone(contact.phone)),
                ),
                const SizedBox(height: 10),
                _ContactButton(
                  icon: Icons.chat,
                  label: 'WhatsApp',
                  subtitle: contact.whatsapp,
                  onTap: () => _launch(
                    context,
                    () => ContactLauncher.whatsapp(contact.whatsapp),
                  ),
                ),
                const SizedBox(height: 10),
                _ContactButton(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  subtitle: contact.email,
                  onTap: () => _launch(
                    context,
                    () => ContactLauncher.email(contact.email),
                  ),
                ),
                const SizedBox(height: 10),
                _ContactButton(
                  icon: Icons.map_outlined,
                  label: 'Open in Google Maps',
                  subtitle: contact.mapsQuery,
                  onTap: () => _launch(
                    context,
                    () => ContactLauncher.openMaps(contact.mapsQuery),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Book a visit'),
                _ContactButton(
                  icon: Icons.event_available_outlined,
                  label: 'Book Consultation',
                  subtitle: 'Send lab request via WhatsApp',
                  onTap: () => context.push('/booking'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _launch(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } on AppFailure catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link: $e')),
        );
      }
    }
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
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
                  label,
                  style: const TextStyle(
                    color: AppColors.goldLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.open_in_new, color: AppColors.gold, size: 20),
        ],
      ),
    );
  }
}
