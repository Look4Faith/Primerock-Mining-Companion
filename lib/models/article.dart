class Article {
  const Article({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.content,
    required this.readMinutes,
    required this.imageHint,
    required this.tags,
  });

  final String id;
  final String title;
  final String category;
  final String summary;
  final String content;
  final int readMinutes;
  final String imageHint;
  final List<String> tags;

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      summary: json['summary'] as String,
      content: json['content'] as String,
      readMinutes: (json['readMinutes'] as num?)?.toInt() ?? 3,
      imageHint: json['imageHint'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class ArticlesDataset {
  const ArticlesDataset({
    required this.categories,
    required this.articles,
  });

  final List<String> categories;
  final List<Article> articles;

  factory ArticlesDataset.fromJson(Map<String, dynamic> json) {
    return ArticlesDataset(
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      articles: (json['articles'] as List<dynamic>)
          .map((e) => Article.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
