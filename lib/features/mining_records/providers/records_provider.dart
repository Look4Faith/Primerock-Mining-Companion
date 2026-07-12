import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/mining_record.dart';
import '../../../services/mining_records_service.dart';
import '../../../services/providers.dart';

final recordsRefreshProvider = StateProvider<int>((ref) => 0);

final recordsSearchQueryProvider = StateProvider<String>((ref) => '');

final recordsListProvider = Provider<List<MiningRecord>>((ref) {
  ref.watch(recordsRefreshProvider);
  final service = ref.watch(miningRecordsServiceProvider);
  final query = ref.watch(recordsSearchQueryProvider).trim();
  if (query.isEmpty) return service.getAll();
  return service.search(query);
});

final monthlySummariesProvider = Provider<List<MonthlySummary>>((ref) {
  ref.watch(recordsRefreshProvider);
  final service = ref.watch(miningRecordsServiceProvider);
  final records = service.getAll();
  if (records.isEmpty) return [];

  final months = <String, DateTime>{};
  for (final r in records) {
    final key = '${r.date.year}-${r.date.month}';
    months[key] = DateTime(r.date.year, r.date.month);
  }

  final sorted = months.values.toList()..sort((a, b) => b.compareTo(a));
  return sorted.take(6).map(service.summarizeMonth).toList();
});

final recordByIdProvider = Provider.family<MiningRecord?, String>((ref, id) {
  ref.watch(recordsRefreshProvider);
  final service = ref.watch(miningRecordsServiceProvider);
  try {
    return service.getAll().firstWhere((r) => r.id == id);
  } catch (_) {
    return null;
  }
});

void refreshRecords(WidgetRef ref) {
  ref.read(recordsRefreshProvider.notifier).state++;
}
