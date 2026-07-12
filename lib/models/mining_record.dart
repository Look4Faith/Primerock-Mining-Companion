class MiningRecord {
  MiningRecord({
    required this.id,
    required this.date,
    this.productionQuantity = 0,
    this.oreProcessed = 0,
    this.goldRecovered = 0,
    this.expenses = 0,
    this.sales = 0,
    this.notes = '',
  });

  final String id;
  DateTime date;
  double productionQuantity;
  double oreProcessed;
  double goldRecovered;
  double expenses;
  double sales;
  String notes;

  double get net => sales - expenses;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'productionQuantity': productionQuantity,
        'oreProcessed': oreProcessed,
        'goldRecovered': goldRecovered,
        'expenses': expenses,
        'sales': sales,
        'notes': notes,
      };

  factory MiningRecord.fromJson(Map<String, dynamic> json) {
    return MiningRecord(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      productionQuantity: (json['productionQuantity'] as num?)?.toDouble() ?? 0,
      oreProcessed: (json['oreProcessed'] as num?)?.toDouble() ?? 0,
      goldRecovered: (json['goldRecovered'] as num?)?.toDouble() ?? 0,
      expenses: (json['expenses'] as num?)?.toDouble() ?? 0,
      sales: (json['sales'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String? ?? '',
    );
  }

  MiningRecord copyWith({
    DateTime? date,
    double? productionQuantity,
    double? oreProcessed,
    double? goldRecovered,
    double? expenses,
    double? sales,
    String? notes,
  }) {
    return MiningRecord(
      id: id,
      date: date ?? this.date,
      productionQuantity: productionQuantity ?? this.productionQuantity,
      oreProcessed: oreProcessed ?? this.oreProcessed,
      goldRecovered: goldRecovered ?? this.goldRecovered,
      expenses: expenses ?? this.expenses,
      sales: sales ?? this.sales,
      notes: notes ?? this.notes,
    );
  }
}

class CalcHistoryEntry {
  const CalcHistoryEntry({
    required this.id,
    required this.calculatorId,
    required this.title,
    required this.inputs,
    required this.result,
    required this.timestamp,
  });

  final String id;
  final String calculatorId;
  final String title;
  final Map<String, String> inputs;
  final String result;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'id': id,
        'calculatorId': calculatorId,
        'title': title,
        'inputs': inputs,
        'result': result,
        'timestamp': timestamp.toIso8601String(),
      };

  factory CalcHistoryEntry.fromJson(Map<String, dynamic> json) {
    return CalcHistoryEntry(
      id: json['id'] as String,
      calculatorId: json['calculatorId'] as String,
      title: json['title'] as String,
      inputs: Map<String, String>.from(json['inputs'] as Map),
      result: json['result'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
