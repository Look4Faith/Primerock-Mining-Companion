import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/lab_content.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/skeleton_loader.dart';
import '../providers/lab_content_provider.dart';

class LaboratoryPage extends ConsumerWidget {
  const LaboratoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(labContentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Primerock Laboratory'),
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
            child: SkeletonLoader(height: 100, count: 5),
          ),
          error: (e, _) => ErrorState(
            message: e.toString(),
            onRetry: () => ref.invalidate(labContentProvider),
          ),
          data: (content) => _LabBody(content: content),
        ),
      ),
    );
  }
}

class _LabBody extends StatelessWidget {
  const _LabBody({required this.content});

  final LabContent content;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content.companyName ?? AppConstants.companyName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.goldLight,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (content.tagline != null) ...[
                const SizedBox(height: 4),
                Text(
                  content.tagline!,
                  style: const TextStyle(color: AppColors.gold),
                ),
              ],
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.08),
        const SizedBox(height: 24),
        const SectionHeader(title: 'About'),
        GlassCard(
          child: Text(
            content.about,
            style: const TextStyle(color: AppColors.white70, height: 1.5),
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Our Services'),
        ...content.services.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.name,
                    style: const TextStyle(
                      color: AppColors.goldLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.description,
                    style: const TextStyle(color: AppColors.white70, height: 1.4),
                  ),
                  if (s.turnaround != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Turnaround: ${s.turnaround}',
                      style: const TextStyle(color: AppColors.white38, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Why Choose Us'),
        ...content.whyChooseUs.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.title.isNotEmpty)
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (item.title.isNotEmpty) const SizedBox(height: 6),
                  Text(
                    item.body,
                    style: const TextStyle(color: AppColors.white70, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Our Process'),
        ...content.processSteps.asMap().entries.map(
          (entry) {
            final step = entry.value;
            final index = entry.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.black,
                      radius: 18,
                      child: Text('${step.step > 0 ? step.step : index + 1}'),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.title,
                            style: const TextStyle(
                              color: AppColors.goldLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (step.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              step.description,
                              style: const TextStyle(
                                color: AppColors.white70,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        const SectionHeader(title: 'FAQ'),
        ...content.faqs.map(
          (faq) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassCard(
              padding: EdgeInsets.zero,
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(
                    faq.question,
                    style: const TextStyle(
                      color: AppColors.goldLight,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  iconColor: AppColors.gold,
                  collapsedIconColor: AppColors.white38,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          faq.answer,
                          style: const TextStyle(color: AppColors.white70, height: 1.45),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.push('/booking'),
            icon: const Icon(Icons.event_available_outlined),
            label: const Text('Book a consultation'),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
