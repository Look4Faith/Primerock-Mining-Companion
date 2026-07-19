import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/article.dart';
import '../../../services/providers.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/skeleton_loader.dart';
import '../providers/knowledge_provider.dart';

class KnowledgeHubPage extends ConsumerWidget {
  const KnowledgeHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(articlesProvider);
    final articlesAsync = ref.watch(filteredArticlesProvider);
    final selectedCategory = ref.watch(knowledgeCategoryProvider);
    final bookmarksOnly = ref.watch(knowledgeBookmarksOnlyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Hub'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.pageGradient(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search articles…',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) =>
                    ref.read(knowledgeSearchQueryProvider.notifier).state = v,
              ),
            ),
            const SizedBox(height: 12),
            categoriesAsync.when(
              loading: () => const SizedBox(
                height: 44,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (dataset) => SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('All'),
                        selected: selectedCategory == null,
                        onSelected: (_) =>
                            ref.read(knowledgeCategoryProvider.notifier).state = null,
                      ),
                    ),
                    ...dataset.categories.map(
                      (cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat),
                          selected: selectedCategory == cat,
                          onSelected: (_) => ref
                              .read(knowledgeCategoryProvider.notifier)
                              .state = cat,
                        ),
                      ),
                    ),
                    FilterChip(
                      label: const Text('Bookmarks'),
                      avatar: const Icon(Icons.bookmark, size: 18),
                      selected: bookmarksOnly,
                      onSelected: (v) =>
                          ref.read(knowledgeBookmarksOnlyProvider.notifier).state = v,
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SectionHeader(title: 'Articles'),
            ),
            Expanded(
              child: articlesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: SkeletonLoader(),
                ),
                error: (e, _) => ErrorState(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(articlesProvider),
                ),
                data: (articles) {
                  if (articles.isEmpty) {
                    return EmptyState(
                      title: 'No articles found',
                      message: bookmarksOnly
                          ? 'Bookmark articles to see them here.'
                          : 'Try a different search or category.',
                      icon: Icons.menu_book_outlined,
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: articles.length,
                    itemBuilder: (context, index) =>
                        _ArticleTile(article: articles[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleTile extends ConsumerWidget {
  const _ArticleTile({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(bookmarksRefreshProvider);
    final bookmarked =
        ref.watch(settingsServiceProvider).isBookmarked(article.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        onTap: () => context.push('/knowledge/${article.id}'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.category,
                    style: TextStyle(
                      color: AppColors.accent(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.accentSoft(context),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${article.readMinutes} min read',
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              bookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: bookmarked ? AppColors.gold : AppColors.textMuted(context),
            ),
          ],
        ),
      ),
    );
  }
}
