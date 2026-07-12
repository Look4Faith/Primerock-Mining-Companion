import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/article.dart';
import '../../../services/providers.dart';

final articlesProvider = FutureProvider<ArticlesDataset>((ref) async {
  final service = ref.watch(knowledgeServiceProvider);
  return service.load();
});

final knowledgeSearchQueryProvider = StateProvider<String>((ref) => '');

final knowledgeCategoryProvider = StateProvider<String?>((ref) => null);

final knowledgeBookmarksOnlyProvider = StateProvider<bool>((ref) => false);

final bookmarksRefreshProvider = StateProvider<int>((ref) => 0);

final filteredArticlesProvider = Provider<AsyncValue<List<Article>>>((ref) {
  ref.watch(bookmarksRefreshProvider);
  final dataset = ref.watch(articlesProvider);
  final query = ref.watch(knowledgeSearchQueryProvider).toLowerCase().trim();
  final category = ref.watch(knowledgeCategoryProvider);
  final bookmarksOnly = ref.watch(knowledgeBookmarksOnlyProvider);
  final settings = ref.watch(settingsServiceProvider);

  return dataset.whenData((data) {
    var list = data.articles;

    if (category != null && category.isNotEmpty) {
      list = list.where((a) => a.category == category).toList();
    }

    if (bookmarksOnly) {
      list = list.where((a) => settings.isBookmarked(a.id)).toList();
    }

    if (query.isNotEmpty) {
      list = list.where((a) {
        return a.title.toLowerCase().contains(query) ||
            a.summary.toLowerCase().contains(query) ||
            a.tags.any((t) => t.toLowerCase().contains(query));
      }).toList();
    }

    return list;
  });
});

final articleByIdProvider = Provider.family<AsyncValue<Article?>, String>((ref, id) {
  final dataset = ref.watch(articlesProvider);
  return dataset.whenData((data) {
    for (final article in data.articles) {
      if (article.id == id) return article;
    }
    return null;
  });
});
