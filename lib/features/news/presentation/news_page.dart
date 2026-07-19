import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/news_item.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/skeleton_loader.dart';
import '../providers/news_provider.dart';

class NewsPage extends ConsumerWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(newsProvider);
    final newsAsync = ref.watch(filteredNewsProvider);
    final selectedCategory = ref.watch(newsCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mining News'),
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
                  hintText: 'Search news…',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) =>
                    ref.read(newsSearchQueryProvider.notifier).state = v,
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
                            ref.read(newsCategoryProvider.notifier).state = null,
                      ),
                    ),
                    ...dataset.categories.map(
                      (cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat),
                          selected: selectedCategory == cat,
                          onSelected: (_) =>
                              ref.read(newsCategoryProvider.notifier).state = cat,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SectionHeader(title: 'Latest'),
            ),
            Expanded(
              child: newsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: SkeletonLoader(),
                ),
                error: (e, _) => ErrorState(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(newsProvider),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const EmptyState(
                      title: 'No news found',
                      message: 'Try a different search or category.',
                      icon: Icons.newspaper_outlined,
                    );
                  }
                  return RefreshIndicator(
                    color: AppColors.gold,
                    onRefresh: () async => ref.invalidate(newsProvider),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: items.length,
                      itemBuilder: (context, index) =>
                          _NewsTile(item: items[index]),
                    ),
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

class _NewsTile extends StatelessWidget {
  const _NewsTile({required this.item});

  final NewsItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        onTap: () => context.push('/news/${item.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  item.category,
                  style: TextStyle(
                    color: AppColors.accent(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  Formatters.dateShort(item.date),
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.accentSoft(context),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              item.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                height: 1.35,
              ),
            ),
            if (item.sourceName.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                item.sourceName,
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
