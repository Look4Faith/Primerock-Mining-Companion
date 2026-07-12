import '../core/constants/app_constants.dart';
import '../models/article.dart';
import 'offline_content_service.dart';

class KnowledgeService {
  KnowledgeService(this._content);

  final OfflineContentService _content;
  static const _cacheKey = 'articles';

  Future<ArticlesDataset> load() async {
    final json = await _content.loadJson(
      cacheKey: _cacheKey,
      assetPath: AppConstants.articlesAsset,
      remotePath: AppConstants.remoteArticlesPath,
    );
    return ArticlesDataset.fromJson(json);
  }
}
