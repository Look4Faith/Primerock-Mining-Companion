import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/skeleton_loader.dart';
import '../providers/news_provider.dart';

class NewsDetailPage extends ConsumerWidget {
  const NewsDetailPage({super.key, required this.newsId});

  final String newsId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(newsItemByIdProvider(newsId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('News'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.pageGradient(context)),
        child: itemAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: SkeletonLoader(height: 200, count: 2),
          ),
          error: (e, _) => ErrorState(
            message: e.toString(),
            onRetry: () => ref.invalidate(newsProvider),
          ),
          data: (item) {
            if (item == null) {
              return const EmptyState(
                title: 'Article not found',
                message: 'This news item may have been removed.',
                icon: Icons.newspaper_outlined,
              );
            }

            final hasSourceUrl = item.sourceUrl.trim().isNotEmpty;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.category,
                        style: TextStyle(
                          color: AppColors.accent(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        Formatters.date(item.date),
                        style: TextStyle(color: AppColors.textMuted(context)),
                      ),
                    ],
                  ).animate().fadeIn(),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.accentSoft(context),
                          fontWeight: FontWeight.bold,
                        ),
                  ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.05),
                  if (item.sourceName.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.sourceName,
                      style: TextStyle(color: AppColors.textMuted(context)),
                    ),
                  ],
                  const SizedBox(height: 20),
                  GlassCard(
                    child: Text(
                      item.body,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        height: 1.6,
                        fontSize: 15,
                      ),
                    ),
                  ).animate(delay: 200.ms).fadeIn(),
                  if (item.tags.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: item.tags
                          .map(
                            (t) => Chip(
                              label: Text(t),
                              backgroundColor: AppColors.surfaceElevated,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  if (hasSourceUrl) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _openSource(context, item.sourceUrl),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Read original source'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openSource(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        throw AppFailure('Could not open $url');
      }
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
