import '../core/constants/app_constants.dart';
import '../models/news_item.dart';
import 'offline_content_service.dart';

class NewsService {
  NewsService(this._content);

  final OfflineContentService _content;
  static const _cacheKey = 'news_v1';

  Future<NewsDataset> load() async {
    final json = await _content.loadJson(
      cacheKey: _cacheKey,
      assetPath: AppConstants.newsAsset,
      remotePath: AppConstants.remoteNewsPath,
    );
    return NewsDataset.fromJson(json);
  }
}
