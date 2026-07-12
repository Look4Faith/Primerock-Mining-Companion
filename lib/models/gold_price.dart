class GoldPriceCategory {
  const GoldPriceCategory({
    required this.id,
    required this.label,
    required this.usdPerGram,
    required this.usdPerOz,
    this.zigPerGram,
  });

  final String id;
  final String label;
  final double usdPerGram;
  final double usdPerOz;
  final double? zigPerGram;

  factory GoldPriceCategory.fromJson(Map<String, dynamic> json) {
    return GoldPriceCategory(
      id: json['id'] as String? ?? json['label'] as String? ?? 'unknown',
      label: json['label'] as String? ?? json['id'] as String? ?? 'Category',
      usdPerGram: (json['usdPerGram'] as num?)?.toDouble() ??
          (json['usd'] as num?)?.toDouble() ??
          0,
      usdPerOz: (json['usdPerOz'] as num?)?.toDouble() ?? 0,
      zigPerGram: (json['zigPerGram'] as num?)?.toDouble() ??
          (json['zig'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'usdPerGram': usdPerGram,
        'usdPerOz': usdPerOz,
        if (zigPerGram != null) 'zigPerGram': zigPerGram,
      };
}

/// One FGR daily price sheet (all purity / method categories).
class GoldPriceDay {
  const GoldPriceDay({
    required this.date,
    required this.categories,
  });

  final DateTime date;
  final List<GoldPriceCategory> categories;

  GoldPriceCategory? get fireAssayCash {
    for (final c in categories) {
      if (c.id == 'fire_assay_cash' ||
          c.label.toLowerCase().contains('fire assay')) {
        return c;
      }
    }
    return categories.isEmpty ? null : categories.last;
  }

  GoldPriceCategory? get sg90 {
    for (final c in categories) {
      if (c.id == 'sg90' || c.label.toLowerCase().contains('90%')) {
        return c;
      }
    }
    return null;
  }

  /// Primary chart / headline series: Fire Assay Cash USD/g.
  double get usd => fireAssayCash?.usdPerGram ?? 0;

  /// Optional ZiG if published; FGR sheets are usually USD-only.
  double? get zig => fireAssayCash?.zigPerGram;

  factory GoldPriceDay.fromJson(Map<String, dynamic> json) {
    // Legacy flat format: { date, usd, zig }
    if (json.containsKey('usd') && !json.containsKey('categories')) {
      final usd = (json['usd'] as num).toDouble();
      final zig = (json['zig'] as num?)?.toDouble();
      return GoldPriceDay(
        date: DateTime.parse(json['date'] as String),
        categories: [
          GoldPriceCategory(
            id: 'legacy',
            label: 'Reference USD/g',
            usdPerGram: usd,
            usdPerOz: usd * 31.1035,
            zigPerGram: zig,
          ),
        ],
      );
    }

    final cats = (json['categories'] as List<dynamic>? ?? [])
        .map((e) => GoldPriceCategory.fromJson(e as Map<String, dynamic>))
        .toList();
    return GoldPriceDay(
      date: DateTime.parse(json['date'] as String),
      categories: cats,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String().substring(0, 10),
        'categories': categories.map((c) => c.toJson()).toList(),
      };
}

/// Backward-compatible alias used by charts / older call sites.
typedef GoldPrice = GoldPriceDay;

class GoldPriceDataset {
  const GoldPriceDataset({
    required this.source,
    required this.lastUpdated,
    required this.note,
    required this.prices,
    this.sourceUrl = 'https://fgr.co.zw/',
    this.operationsUrl =
        'https://fgr.co.zw/gold-operations/gold-buying-and-gold-refining-operations/',
    this.paymentNote = '',
    this.troyOunceGrams = 31.1035,
  });

  final String source;
  final String sourceUrl;
  final String operationsUrl;
  final String lastUpdated;
  final String note;
  final String paymentNote;
  final double troyOunceGrams;
  final List<GoldPriceDay> prices;

  GoldPriceDay? get latest => prices.isEmpty ? null : prices.last;

  factory GoldPriceDataset.fromJson(Map<String, dynamic> json) {
    final daysRaw = json['days'] as List<dynamic>? ??
        json['prices'] as List<dynamic>? ??
        [];
    final list = daysRaw
        .map((e) => GoldPriceDay.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return GoldPriceDataset(
      source: json['source'] as String? ?? 'Fidelity Gold Refinery (FGR)',
      sourceUrl: json['sourceUrl'] as String? ?? 'https://fgr.co.zw/',
      operationsUrl: json['operationsUrl'] as String? ??
          'https://fgr.co.zw/gold-operations/gold-buying-and-gold-refining-operations/',
      lastUpdated: json['lastUpdated'] as String? ?? '',
      note: json['note'] as String? ?? '',
      paymentNote: json['paymentNote'] as String? ?? '',
      troyOunceGrams: (json['troyOunceGrams'] as num?)?.toDouble() ?? 31.1035,
      prices: list,
    );
  }
}
