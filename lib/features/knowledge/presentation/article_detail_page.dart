import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/providers.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/skeleton_loader.dart';
import '../providers/knowledge_provider.dart';

class ArticleDetailPage extends ConsumerWidget {
  const ArticleDetailPage({super.key, required this.articleId});

  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(bookmarksRefreshProvider);
    final articleAsync = ref.watch(articleByIdProvider(articleId));
    final settings = ref.watch(settingsServiceProvider);
    final bookmarked = settings.isBookmarked(articleId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border),
            tooltip: bookmarked ? 'Remove bookmark' : 'Bookmark',
            onPressed: () async {
              await ref.read(settingsServiceProvider).toggleBookmark(articleId);
              ref.read(bookmarksRefreshProvider.notifier).state++;
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.pageGradient(context)),
        child: articleAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: SkeletonLoader(height: 200, count: 2),
          ),
          error: (e, _) => ErrorState(
            message: e.toString(),
            onRetry: () => ref.invalidate(articlesProvider),
          ),
          data: (article) {
            if (article == null) {
              return const EmptyState(
                title: 'Article not found',
                message: 'This article may have been removed.',
                icon: Icons.article_outlined,
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.category,
                    style: TextStyle(
                      color: AppColors.accent(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(),
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.accentSoft(context),
                          fontWeight: FontWeight.bold,
                        ),
                  ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.05),
                  const SizedBox(height: 8),
                  Text(
                    '${article.readMinutes} min read',
                    style: TextStyle(color: AppColors.textMuted(context)),
                  ),
                  const SizedBox(height: 20),
                  GlassCard(
                    child: Text(
                      article.content,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        height: 1.6,
                        fontSize: 15,
                      ),
                    ),
                  ).animate(delay: 200.ms).fadeIn(),
                  if (article.tags.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: article.tags
                          .map(
                            (t) => Chip(
                              label: Text(t),
                              backgroundColor: AppColors.surfaceElevated,
                            ),
                          )
                          .toList(),
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
}
