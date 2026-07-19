import '../core/constants/app_constants.dart';
import '../models/gold_price.dart';
import 'offline_content_service.dart';

/// Gold price repository. Swap remote URL later without changing UI.
class GoldPriceService {
  GoldPriceService(this._content);

  final OfflineContentService _content;
  static const cacheKey = 'gold_prices_v3';

  Future<GoldPriceDataset> load({bool forceRefresh = true}) async {
    final json = await _content.loadJson(
      cacheKey: cacheKey,
      assetPath: AppConstants.goldPricesAsset,
      remotePath: AppConstants.remoteGoldPricesPath,
      forceRefresh: forceRefresh,
    );
    return GoldPriceDataset.fromJson(json);
  }

  Future<({GoldPriceDataset dataset, ContentSource source, DateTime? syncedAt})>
      loadDetailed({bool forceRefresh = true}) async {
    final result = await _content.loadJsonDetailed(
      cacheKey: cacheKey,
      assetPath: AppConstants.goldPricesAsset,
      remotePath: AppConstants.remoteGoldPricesPath,
      forceRefresh: forceRefresh,
    );
    return (
      dataset: GoldPriceDataset.fromJson(result.data),
      source: result.source,
      syncedAt: result.syncedAt,
    );
  }
}
