import '../core/constants/app_constants.dart';
import '../models/news_item.dart';
import 'offline_content_service.dart';

class NewsService {
  NewsService(this._content);

  final OfflineContentService _content;
  static const cacheKey = 'news_v2';

  Future<NewsDataset> load({bool forceRefresh = true}) async {
    final json = await _content.loadJson(
      cacheKey: cacheKey,
      assetPath: AppConstants.newsAsset,
      remotePath: AppConstants.remoteNewsPath,
      forceRefresh: forceRefresh,
    );
    return NewsDataset.fromJson(json);
  }

  Future<({NewsDataset dataset, ContentSource source, DateTime? syncedAt})>
      loadDetailed({bool forceRefresh = true}) async {
    final result = await _content.loadJsonDetailed(
      cacheKey: cacheKey,
      assetPath: AppConstants.newsAsset,
      remotePath: AppConstants.remoteNewsPath,
      forceRefresh: forceRefresh,
    );
    return (
      dataset: NewsDataset.fromJson(result.data),
      source: result.source,
      syncedAt: result.syncedAt,
    );
  }
}
