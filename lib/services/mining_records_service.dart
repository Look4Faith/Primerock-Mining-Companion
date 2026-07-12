import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/storage_keys.dart';
import '../models/mining_record.dart';

class MiningRecordsService {
  MiningRecordsService();

  final _uuid = const Uuid();
  Box get _box => Hive.box(StorageKeys.hiveBoxRecords);

  List<MiningRecord> getAll() {
    final list = <MiningRecord>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw is String) {
        list.add(MiningRecord.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      } else if (raw is Map) {
        list.add(MiningRecord.fromJson(Map<String, dynamic>.from(raw)));
      }
    }
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<MiningRecord> create(MiningRecord draft) async {
    final record = draft.id.isEmpty
        ? draft.copyWith() // keep fields; assign id below
        : draft;
    final saved = MiningRecord(
      id: record.id.isEmpty ? _uuid.v4() : record.id,
      date: record.date,
      productionQuantity: record.productionQuantity,
      oreProcessed: record.oreProcessed,
      goldRecovered: record.goldRecovered,
      expenses: record.expenses,
      sales: record.sales,
      notes: record.notes,
    );
    await _box.put(saved.id, jsonEncode(saved.toJson()));
    return saved;
  }

  Future<void> update(MiningRecord record) async {
    await _box.put(record.id, jsonEncode(record.toJson()));
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  List<MiningRecord> search(String query) {
    final q = query.toLowerCase();
    return getAll().where((r) {
      return r.notes.toLowerCase().contains(q) ||
          r.date.toIso8601String().contains(q);
    }).toList();
  }

  MonthlySummary summarizeMonth(DateTime month) {
    final records = getAll().where(
      (r) => r.date.year == month.year && r.date.month == month.month,
    );
    var ore = 0.0, gold = 0.0, expenses = 0.0, sales = 0.0, production = 0.0;
    for (final r in records) {
      ore += r.oreProcessed;
      gold += r.goldRecovered;
      expenses += r.expenses;
      sales += r.sales;
      production += r.productionQuantity;
    }
    return MonthlySummary(
      month: month,
      oreProcessed: ore,
      goldRecovered: gold,
      expenses: expenses,
      sales: sales,
      productionQuantity: production,
      entryCount: records.length,
    );
  }
}

class MonthlySummary {
  const MonthlySummary({
    required this.month,
    required this.oreProcessed,
    required this.goldRecovered,
    required this.expenses,
    required this.sales,
    required this.productionQuantity,
    required this.entryCount,
  });

  final DateTime month;
  final double oreProcessed;
  final double goldRecovered;
  final double expenses;
  final double sales;
  final double productionQuantity;
  final int entryCount;

  double get net => sales - expenses;
}
