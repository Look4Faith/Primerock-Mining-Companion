import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/storage_keys.dart';
import '../models/mining_record.dart';

class CalcHistoryService {
  final _uuid = const Uuid();
  Box get _box => Hive.box(StorageKeys.hiveBoxCalcHistory);

  Future<void> add(CalcHistoryEntry entry) async {
    final id = entry.id.isEmpty ? _uuid.v4() : entry.id;
    final saved = CalcHistoryEntry(
      id: id,
      calculatorId: entry.calculatorId,
      title: entry.title,
      inputs: entry.inputs,
      result: entry.result,
      timestamp: entry.timestamp,
    );
    await _box.put(saved.id, jsonEncode(saved.toJson()));
  }

  List<CalcHistoryEntry> forCalculator(String calculatorId) {
    return all()
        .where((e) => e.calculatorId == calculatorId)
        .toList();
  }

  List<CalcHistoryEntry> all() {
    final list = <CalcHistoryEntry>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw is String) {
        list.add(
          CalcHistoryEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        );
      }
    }
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<void> clear() async => _box.clear();
}
