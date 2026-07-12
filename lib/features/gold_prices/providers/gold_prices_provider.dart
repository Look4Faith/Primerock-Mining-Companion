import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/gold_price.dart';
import '../../../services/providers.dart';

final goldPricesProvider = FutureProvider<GoldPriceDataset>((ref) async {
  final service = ref.watch(goldPriceServiceProvider);
  return service.load();
});
