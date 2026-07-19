import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/gold_price.dart';
import '../../../services/offline_content_service.dart';
import '../../../services/providers.dart';

class GoldPricesViewState {
  const GoldPricesViewState({
    required this.dataset,
    required this.source,
    this.syncedAt,
  });

  final GoldPriceDataset dataset;
  final ContentSource source;
  final DateTime? syncedAt;
}

final goldPricesProvider = FutureProvider<GoldPricesViewState>((ref) async {
  final service = ref.watch(goldPriceServiceProvider);
  final result = await service.loadDetailed(forceRefresh: true);
  return GoldPricesViewState(
    dataset: result.dataset,
    source: result.source,
    syncedAt: result.syncedAt,
  );
});
