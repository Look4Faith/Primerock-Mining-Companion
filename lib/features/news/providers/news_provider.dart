import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/news_item.dart';
import '../../../services/providers.dart';

final newsProvider = FutureProvider<NewsDataset>((ref) async {
  final service = ref.watch(newsServiceProvider);
  return service.load();
});

final newsSearchQueryProvider = StateProvider<String>((ref) => '');

final newsCategoryProvider = StateProvider<String?>((ref) => null);

final filteredNewsProvider = Provider<AsyncValue<List<NewsItem>>>((ref) {
  final dataset = ref.watch(newsProvider);
  final query = ref.watch(newsSearchQueryProvider).toLowerCase().trim();
  final category = ref.watch(newsCategoryProvider);

  return dataset.whenData((data) {
    var list = List<NewsItem>.from(data.items)
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

final newsItemByIdProvider = Provider.family<AsyncValue<NewsItem?>, String>((ref, id) {
  final dataset = ref.watch(newsProvider);
  return dataset.whenData((data) {
    for (final item in data.items) {
      if (item.id == id) return item;
    }
    return null;
  });
});
