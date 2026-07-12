import 'package:flutter_test/flutter_test.dart';
import 'package:primerock_mining_companion/models/gold_price.dart';

void main() {
  test('parses FGR category sheet and exposes Fire Assay Cash', () {
    final dataset = GoldPriceDataset.fromJson({
      'source': 'Fidelity Gold Refinery (FGR)',
      'lastUpdated': '2026-07-10',
      'note': 'test',
      'days': [
        {
          'date': '2026-07-09',
          'categories': [
            {
              'id': 'sg90',
              'label': 'SG 90% and Above',
              'usdPerGram': 122.54,
              'usdPerOz': 3811.22,
            },
            {
              'id': 'fire_assay_cash',
              'label': 'Fire Assay (Cash)',
              'usdPerGram': 123.19,
              'usdPerOz': 3831.43,
            },
          ],
        },
        {
          'date': '2026-07-10',
          'categories': [
            {
              'id': 'sg90',
              'label': 'SG 90% and Above',
              'usdPerGram': 124.79,
              'usdPerOz': 3881.20,
            },
            {
              'id': 'fire_assay_cash',
              'label': 'Fire Assay (Cash)',
              'usdPerGram': 125.45,
              'usdPerOz': 3901.73,
            },
          ],
        },
      ],
    });

    expect(dataset.prices.first.date.day, 9);
    expect(dataset.latest!.fireAssayCash!.usdPerGram, 125.45);
    expect(dataset.latest!.usd, 125.45);
    expect(dataset.latest!.sg90!.usdPerGram, 124.79);
  });

  test('legacy flat usd/zig still parses', () {
    final dataset = GoldPriceDataset.fromJson({
      'source': 'legacy',
      'lastUpdated': '2026-07-01',
      'note': 'n',
      'prices': [
        {'date': '2026-07-01', 'usd': 68, 'zig': 1950},
        {'date': '2026-07-02', 'usd': 69, 'zig': 2000},
      ],
    });
    expect(dataset.latest!.usd, 69);
  });
}
