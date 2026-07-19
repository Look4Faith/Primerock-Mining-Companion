import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/news_item.dart';
import '../../../services/offline_content_service.dart';
import '../../../services/providers.dart';

class NewsViewState {
  const NewsViewState({
    required this.dataset,
    required this.source,
    this.syncedAt,
  });

  final NewsDataset dataset;
  final ContentSource source;
  final DateTime? syncedAt;
}

final newsProvider = FutureProvider<NewsViewState>((ref) async {
  final service = ref.watch(newsServiceProvider);
  final result = await service.loadDetailed(forceRefresh: true);
  return NewsViewState(
    dataset: result.dataset,
    source: result.source,
    syncedAt: result.syncedAt,
  );
});

final newsSearchQueryProvider = StateProvider<String>((ref) => '');

final newsCategoryProvider = StateProvider<String?>((ref) => null);

final filteredNewsProvider = Provider<AsyncValue<List<NewsItem>>>((ref) {
  final dataset = ref.watch(newsProvider);
  final query = ref.watch(newsSearchQueryProvider).toLowerCase().trim();
  final category = ref.watch(newsCategoryProvider);

  return dataset.whenData((state) {
    var list = List<NewsItem>.from(state.dataset.items)
      ..sort((a, b) => b.date.compareTo(a.date));

    if (category != null && category.isNotEmpty) {
      list = list.where((n) => n.category == category).toList();
    }

    if (query.isNotEmpty) {
      list = list.where((n) {
        return n.title.toLowerCase().contains(query) ||
            n.summary.toLowerCase().contains(query) ||
            n.body.toLowerCase().contains(query) ||
            n.tags.any((t) => t.toLowerCase().contains(query));
      }).toList();
    }

    return list;
  });
});

final newsItemByIdProvider =
    Provider.family<AsyncValue<NewsItem?>, String>((ref, id) {
  final dataset = ref.watch(newsProvider);
  return dataset.whenData((state) {
    for (final item in state.dataset.items) {
      if (item.id == id) return item;
    }
    return null;
  });
});
