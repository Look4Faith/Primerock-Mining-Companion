import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/gold_price.dart';
import '../../../services/offline_content_service.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/skeleton_loader.dart';
import '../providers/gold_prices_provider.dart';

String _syncLabel(GoldPricesViewState state) {
  final when = state.syncedAt;
  final whenText = when == null
      ? 'not yet'
      : Formatters.date(when.toLocal());
  switch (state.source) {
    case ContentSource.remote:
      return 'Live sync: updated $whenText (Wi‑Fi/data)';
    case ContentSource.cache:
      return 'Offline cache (last sync $whenText). Pull to refresh when online.';
    case ContentSource.asset:
      return 'Bundled copy — connect to Wi‑Fi/data and pull to refresh.';
  }
}

class GoldPricesPage extends ConsumerWidget {
  const GoldPricesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(goldPricesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FGR Gold Prices'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh prices',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(goldPricesProvider),
          ),
          IconButton(
            tooltip: 'Open FGR website',
            icon: const Icon(Icons.open_in_new),
            onPressed: () => launchUrl(
              Uri.parse(AppConstants.fgrHomeUrl),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.pageGradient(context)),
        child: asyncData.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: SkeletonLoader(height: 120, count: 4),
          ),
          error: (e, _) => ErrorState(
            message: e.toString(),
            onRetry: () => ref.invalidate(goldPricesProvider),
          ),
          data: (state) => RefreshIndicator(
            color: AppColors.gold,
            onRefresh: () async => ref.invalidate(goldPricesProvider),
            child: _GoldPricesBody(state: state),
          ),
        ),
      ),
    );
  }
}

class _GoldPricesBody extends StatelessWidget {
  const _GoldPricesBody({required this.state});

  final GoldPricesViewState state;

  @override
  Widget build(BuildContext context) {
    final dataset = state.dataset;
    final latest = dataset.latest;
    final fire = latest?.fireAssayCash;
    final sg90 = latest?.sg90;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (latest != null && fire != null)
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fidelity Gold Refinery — Fire Assay (Cash)',
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _PriceChip(
                        label: 'USD / gram',
                        value: Formatters.usd(fire.usdPerGram),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PriceChip(
                        label: 'USD / oz',
                        value: Formatters.usd(fire.usdPerOz),
                      ),
                    ),
                  ],
                ),
                if (sg90 != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'SG 90%+: ${Formatters.usd(sg90.usdPerGram)}/g · ${Formatters.usd(sg90.usdPerOz)}/oz',
                    style: TextStyle(color: AppColors.accentSoft(context)),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  'As of ${Formatters.date(latest.date)}',
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),
        const SizedBox(height: 16),
        Text(
          'Source: ${dataset.source}',
          style: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _syncLabel(state),
          style: TextStyle(
            color: AppColors.textMuted(context),
            fontSize: 12,
          ),
        ),
        if (dataset.lastUpdated.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Sheet date: ${dataset.lastUpdated}',
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 12,
            ),
          ),
        ],
        if (dataset.paymentNote.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            dataset.paymentNote,
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
        if (dataset.note.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            dataset.note,
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => launchUrl(
            Uri.parse(dataset.sourceUrl),
            mode: LaunchMode.externalApplication,
          ),
          icon: const Icon(Icons.public),
          label: const Text('Open fgr.co.zw'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => launchUrl(
            Uri.parse(dataset.operationsUrl),
            mode: LaunchMode.externalApplication,
          ),
          child: const Text('Gold buying & refining operations'),
        ),
        if (latest != null) ...[
          const SizedBox(height: 24),
          const SectionHeader(
            title: 'Today’s FGR categories',
            subtitle: 'USD per gram and per troy ounce',
          ),
          ...latest.categories.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.label,
                        style: TextStyle(color: AppColors.textSecondary(context)),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${Formatters.usd(c.usdPerGram)}/g',
                          style: TextStyle(
                            color: AppColors.accentSoft(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${Formatters.usd(c.usdPerOz)}/oz',
                          style: TextStyle(
                            color: AppColors.textMuted(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        const SectionHeader(
          title: 'Fire Assay Cash trend',
          subtitle: 'USD per gram history',
        ),
        GlassCard(
          padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
          child: SizedBox(
            height: 220,
            child: dataset.prices.length < 2
                ? const EmptyState(
                    title: 'Not enough data',
                    message: 'Add more daily sheets to see the chart.',
                    icon: Icons.show_chart,
                  )
                : _UsdLineChart(prices: dataset.prices),
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Recent daily sheets'),
        ...dataset.prices.reversed.take(10).map(
          (p) {
            final fac = p.fireAssayCash;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        Formatters.date(p.date),
                        style: TextStyle(color: AppColors.textSecondary(context)),
                      ),
                    ),
                    Text(
                      fac == null
                          ? '—'
                          : '${Formatters.usd(fac.usdPerGram)}/g',
                      style: TextStyle(
                        color: AppColors.accentSoft(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _PriceChip extends StatelessWidget {
  const _PriceChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.accentSoft(context),
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _UsdLineChart extends StatelessWidget {
  const _UsdLineChart({required this.prices});

  final List<GoldPriceDay> prices;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (var i = 0; i < prices.length; i++) {
      spots.add(FlSpot(i.toDouble(), prices[i].usd));
    }

    final minY = prices.map((p) => p.usd).reduce((a, b) => a < b ? a : b);
    final maxY = prices.map((p) => p.usd).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1 + 1;

    return LineChart(
      LineChartData(
        minY: minY - padding,
        maxY: maxY + padding,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.divider,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, _) => Text(
                '\$${value.toStringAsFixed(0)}',
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 10,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: (prices.length / 4).clamp(1, 999).toDouble(),
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= prices.length) return const SizedBox.shrink();
                return Text(
                  DateFormat('d/M').format(prices[i].date),
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.gold,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.gold.withValues(alpha: 0.3),
                  AppColors.gold.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
