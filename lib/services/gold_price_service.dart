import '../core/constants/app_constants.dart';
import '../models/gold_price.dart';
import 'offline_content_service.dart';

/// Gold price repository. Swap remote URL later without changing UI.
class GoldPriceService {
  GoldPriceService(this._content);

  final OfflineContentService _content;
  static const _cacheKey = 'gold_prices_v2';

  Future<GoldPriceDataset> load() async {
    final json = await _content.loadJson(
      cacheKey: _cacheKey,
      assetPath: AppConstants.goldPricesAsset,
      remotePath: AppConstants.remoteGoldPricesPath,
    );
    return GoldPriceDataset.fromJson(json);
  }
}
