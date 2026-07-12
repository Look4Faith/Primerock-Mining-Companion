import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/mining_record.dart';
import '../../../services/mining_records_service.dart';
import '../../../services/providers.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/section_header.dart';
import '../providers/records_provider.dart';

class RecordsPage extends ConsumerWidget {
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(recordsListProvider);
    final summaries = ref.watch(monthlySummariesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Records'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export PDF',
            onPressed: records.isEmpty
                ? null
                : () async {
                    await ref.read(pdfExportServiceProvider).exportRecords(records);
                  },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/records/form'),
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search notes or dates…',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) =>
                    ref.read(recordsSearchQueryProvider.notifier).state = v,
              ),
            ),
            Expanded(
              child: records.isEmpty
                  ? EmptyState(
                      title: 'No records yet',
                      message: 'Tap + to log your first production entry.',
                      icon: Icons.assignment_outlined,
                      actionLabel: 'Add record',
                      onAction: () => context.push('/records/form'),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (summaries.isNotEmpty) ...[
                          const SectionHeader(
                            title: 'Monthly Summary',
                            subtitle: 'Last 6 months',
                          ),
                          SizedBox(
                            height: 130,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: summaries.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 10),
                              itemBuilder: (_, i) =>
                                  _SummaryCard(summary: summaries[i]),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const SectionHeader(title: 'Gold Recovered'),
                          GlassCard(
                            padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                            child: SizedBox(
                              height: 200,
                              child: _GoldChart(records: records),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const SectionHeader(title: 'All Entries'),
                        ],
                        ...records.map(
                          (r) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _RecordTile(record: r),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final MonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Formatters.monthYear(summary.month),
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${Formatters.number(summary.goldRecovered)} g gold',
              style: const TextStyle(color: AppColors.goldLight, fontSize: 13),
            ),
            Text(
              '${summary.entryCount} entries',
              style: const TextStyle(color: AppColors.white38, fontSize: 12),
            ),
            const Spacer(),
            Text(
              'Net ${Formatters.usd(summary.net)}',
              style: TextStyle(
                color: summary.net >= 0 ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoldChart extends StatelessWidget {
  const _GoldChart({required this.records});

  final List<MiningRecord> records;

  @override
  Widget build(BuildContext context) {
    final sorted = [...records]..sort((a, b) => a.date.compareTo(b.date));
    final recent = sorted.length > 12 ? sorted.sublist(sorted.length - 12) : sorted;

    if (recent.isEmpty) {
      return const Center(child: Text('No data', style: TextStyle(color: AppColors.white38)));
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < recent.length; i++) {
      spots.add(FlSpot(i.toDouble(), recent[i].goldRecovered));
    }

    final maxY = recent.map((r) => r.goldRecovered).reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        maxY: maxY <= 0 ? 1 : maxY * 1.2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppColors.divider, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (v, _) => Text(
                v.toInt().toString(),
                style: const TextStyle(color: AppColors.white38, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= recent.length) return const SizedBox.shrink();
                return Text(
                  Formatters.dateShort(recent[i].date),
                  style: const TextStyle(color: AppColors.white38, fontSize: 9),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(
          recent.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: recent[i].goldRecovered,
                color: AppColors.gold,
                width: 14,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordTile extends ConsumerWidget {
  const _RecordTile({required this.record});

  final MiningRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      onTap: () => context.push('/records/form/${record.id}'),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Formatters.date(record.date),
                  style: const TextStyle(
                    color: AppColors.goldLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gold ${Formatters.number(record.goldRecovered)} g · Ore ${Formatters.number(record.oreProcessed)} t',
                  style: const TextStyle(color: AppColors.white70, fontSize: 13),
                ),
                if (record.notes.isNotEmpty)
                  Text(
                    record.notes,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.white38, fontSize: 12),
                  ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.gold),
        ],
      ),
    );
  }
}
