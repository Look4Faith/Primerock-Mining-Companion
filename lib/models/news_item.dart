class NewsItem {
  const NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.category,
    required this.date,
    required this.sourceName,
    required this.sourceUrl,
    required this.tags,
  });

  final String id;
  final String title;
  final String summary;
  final String body;
  final String category;
  final DateTime date;
  final String sourceName;
  final String sourceUrl;
  final List<String> tags;

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      body: json['body'] as String,
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      sourceName: json['sourceName'] as String? ?? '',
      sourceUrl: json['sourceUrl'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class NewsDataset {
  const NewsDataset({
    required this.source,
    required this.lastUpdated,
    required this.note,
    required this.items,
    required this.categories,
  });

  final String source;
  final String lastUpdated;
  final String note;
  final List<NewsItem> items;
  final List<String> categories;

  factory NewsDataset.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>)
        .map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
        .toList();

    final categories = items.map((i) => i.category).toSet().toList()..sort();

    return NewsDataset(
      source: json['source'] as String? ?? '',
      lastUpdated: json['lastUpdated'] as String? ?? '',
      note: json['note'] as String? ?? '',
      items: items,
      categories: categories,
    );
  }
}
