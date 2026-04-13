import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/stats_provider.dart';
import '../../providers/prayer_provider.dart';
import '../../core/utils/date_utils.dart';
import 'components/stats_pagination_header.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('stats_title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(statsProvider.notifier).refresh();
              // ignore: unused_result
              ref.refresh(dayPrayersProvider);
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.softEmerald),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stats) => RefreshIndicator(
          color: AppColors.softEmerald,
          backgroundColor: Theme.of(context).cardColor,
          onRefresh: () => ref.read(statsProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              // ── Streak Card ─────────────────────────────────────────────
              _StreakCard(streak: stats.streak),
              const SizedBox(height: 16),

              // ── Daily / Weekly / Monthly ─────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _StatMiniCard(
                      label: 'stats_today'.tr(),
                      percent: stats.todayPercent,
                      color: AppColors.softEmerald,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatMiniCard(
                      label: 'stats_this_week'.tr(),
                      percent: stats.weeklyPercent,
                      color: const Color(0xFF5C9BD6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatMiniCard(
                      label: 'stats_this_month'.tr(),
                      percent: stats.monthlyPercent,
                      color: const Color(0xFFAB7EDB),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Weekly Bar Chart ──────────────────────────────────────────
              _WeeklyBarChart(
                statusCounts: stats.weeklyDailyStatusCounts,
                labels: stats.weeklyLabels,
                rangeLabel: stats.weeklyRangeLabel,
                onOffsetChanged: (d) => ref.read(statsProvider.notifier).changeWeeklyOffset(d),
              ),
              const SizedBox(height: 20),

              // ── Monthly Distribution Pie Chart ───────────────────────────
              _StatusPieChart(
                aggregate: stats.monthlyAggregate,
                rangeLabel: stats.monthlyRangeLabel,
                titleKey: 'stats_monthly_distribution',
                onOffsetChanged: (d) => ref.read(statsProvider.notifier).changeMonthlyOffset(d),
              ),
              const SizedBox(height: 20),

              // ── Yearly Summary Card (with integrated Line Graph) ─────────
              _YearlySummaryCard(
                aggregate: stats.yearlyAggregate,
                label: stats.yearlyLabel,
                monthlyPercents: stats.yearlyMonthlyPercents,
                onOffsetChanged: (d) => ref.read(statsProvider.notifier).changeYearlyOffset(d),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Streak Card ───────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  final int streak;
  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.deepGreen, AppColors.softEmerald],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.softEmerald.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'stats_current_streak'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightText.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$streak',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 52,
                        fontWeight: FontWeight.w800,
                        color: AppColors.lightText,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        streak == 1 ? 'stats_day'.tr() : 'stats_days'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.lightText.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  streak == 0
                      ? 'stats_streak_empty'.tr()
                      : 'stats_streak_active'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.lightText.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Colors.orangeAccent,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mini Stat Card ────────────────────────────────────────────────────────────

class _StatMiniCard extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;

  const _StatMiniCard({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            '${percent.toStringAsFixed(0)}%',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Weekly Bar Chart ──────────────────────────────────────────────────────────

class _WeeklyBarChart extends StatelessWidget {
  final List<Map<String, int>> statusCounts;
  final List<String> labels;
  final String rangeLabel;
  final Function(int) onOffsetChanged;

  const _WeeklyBarChart({
    required this.statusCounts,
    required this.labels,
    required this.rangeLabel,
    required this.onOffsetChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatsPaginationHeader(
            title: 'stats_7_day_overview'.tr(),
            subtitle: rangeLabel,
            onBack: () => onOffsetChanged(1),
            onForward: () => onOffsetChanged(-1),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: statusCounts.isEmpty
                ? Center(
                    child: Text('stats_no_data'.tr(),
                        style: const TextStyle(color: AppColors.grey)))
                : BarChart(
                    BarChartData(
                      maxY: 5,
                      minY: 0,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipPadding: const EdgeInsets.all(8),
                          tooltipMargin: 6,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final counts = statusCounts[groupIndex];
                            final onTime = counts['onTime'] ?? 0;
                            final qaza = counts['qaza'] ?? 0;
                            final missed = counts['missed'] ?? 0;
                            final total = onTime + qaza;

                            return BarTooltipItem(
                              '$total done',
                              const TextStyle(
                                color: AppColors.lightText,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              children: [
                                if (missed > 0)
                                  TextSpan(
                                    text: '\n$missed missed',
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 1,
                            getTitlesWidget: (value, _) => Text(
                              '${value.toInt()}',
                              style: const TextStyle(
                                  color: AppColors.grey, fontSize: 10),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              final i = value.toInt();
                              if (i < 0 || i >= labels.length) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  labels[i],
                                  style: const TextStyle(
                                      color: AppColors.grey, fontSize: 11),
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: theme.dividerColor,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(statusCounts.length, (i) {
                        final counts = statusCounts[i];
                        final onTime = (counts['onTime'] ?? 0).toDouble();
                        final qaza = (counts['qaza'] ?? 0).toDouble();
                        final missed = (counts['missed'] ?? 0).toDouble();

                        final List<BarChartRodStackItem> stackItems = [];
                        double currentY = 0;
                        if (onTime > 0) {
                          stackItems.add(BarChartRodStackItem(currentY,
                              currentY + onTime, AppColors.softEmerald));
                          currentY += onTime;
                        }
                        if (qaza > 0) {
                          stackItems.add(BarChartRodStackItem(
                              currentY, currentY + qaza, AppColors.qaza));
                          currentY += qaza;
                        }
                        if (missed > 0) {
                          stackItems.add(BarChartRodStackItem(
                              currentY, currentY + missed, AppColors.missed));
                          currentY += missed;
                        }

                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: 5,
                              color: Colors.transparent,
                              width: 22,
                              borderRadius: BorderRadius.circular(6),
                              rodStackItems: stackItems,
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: 5,
                                color: AppColors.grey.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Pie Chart ─────────────────────────────────────────────────────────────────

class _StatusPieChart extends StatefulWidget {
  final Map<String, int> aggregate;
  final String rangeLabel;
  final String titleKey;
  final Function(int) onOffsetChanged;

  const _StatusPieChart({
    required this.aggregate,
    required this.rangeLabel,
    required this.titleKey,
    required this.onOffsetChanged,
  });

  @override
  State<_StatusPieChart> createState() => _StatusPieChartState();
}

class _StatusPieChartState extends State<_StatusPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onTime = widget.aggregate['onTime'] ?? 0;
    final qaza = widget.aggregate['qaza'] ?? 0;
    final missed = widget.aggregate['missed'] ?? 0;
    final notAdded = widget.aggregate['notAdded'] ?? 0;
    final total = onTime + qaza + missed + notAdded;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatsPaginationHeader(
            title: widget.titleKey.tr(),
            subtitle: widget.rangeLabel,
            onBack: () => widget.onOffsetChanged(1),
            onForward: () => widget.onOffsetChanged(-1),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: total == 0
                    ? Center(
                        child: Text('stats_no_data_short'.tr(),
                            style: const TextStyle(color: AppColors.grey)))
                    : PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback:
                                (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  _touchedIndex = -1;
                                  return;
                                }
                                _touchedIndex = pieTouchResponse
                                    .touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 3,
                          centerSpaceRadius: 38,
                          sections: [
                            _pieSection(onTime, total, AppColors.onTime,
                                'stats_on_time'.tr(), 0),
                            _pieSection(qaza, total, AppColors.qaza,
                                'stats_qaza'.tr(), 1),
                            _pieSection(missed, total, AppColors.missed,
                                'stats_missed'.tr(), 2),
                            if ((widget.aggregate['notAdded'] ?? 0) > 0)
                              _pieSection(widget.aggregate['notAdded']!, total,
                                  AppColors.statusNone, 'stats_not_added'.tr(), 3),
                          ],
                        ),
                      ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendItem(
                        color: AppColors.onTime,
                        label: 'stats_on_time'.tr(),
                        count: onTime),
                    const SizedBox(height: 8),
                    _LegendItem(
                        color: AppColors.qaza,
                        label: 'stats_qaza'.tr(),
                        count: qaza),
                    const SizedBox(height: 8),
                    _LegendItem(
                        color: AppColors.missed,
                        label: 'stats_missed'.tr(),
                        count: missed),
                    if ((widget.aggregate['notAdded'] ?? 0) > 0) ...[
                      const SizedBox(height: 8),
                      _LegendItem(
                          color: AppColors.statusNone,
                          label: 'stats_not_added'.tr(),
                          count: widget.aggregate['notAdded']!),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PieChartSectionData _pieSection(
      int value, int total, Color color, String title, int index) {
    final isTouched = index == _touchedIndex;
    final radius = isTouched ? 55.0 : 46.0;
    final pct = total == 0 ? 0.0 : (value / total * 100);
    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      radius: radius,
      title: pct >= 10 ? '${pct.toStringAsFixed(0)}%' : '',
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _LegendItem(
      {required this.color, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Text(
          '$count',
          style: theme.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}

// ── Yearly Summary Card ──────────────────────────────────────────────────────

class _YearlySummaryCard extends StatelessWidget {
  final Map<String, int> aggregate;
  final String label;
  final List<double> monthlyPercents;
  final Function(int) onOffsetChanged;

  const _YearlySummaryCard({
    required this.aggregate,
    required this.label,
    required this.monthlyPercents,
    required this.onOffsetChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onTime = aggregate['onTime'] ?? 0;
    final qaza = aggregate['qaza'] ?? 0;
    final missed = aggregate['missed'] ?? 0;
    final notAdded = aggregate['notAdded'] ?? 0;
    final total = onTime + qaza + missed + notAdded;
    final pct = total == 0 ? 0.0 : (onTime / total * 100);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatsPaginationHeader(
            title: 'stats_yearly_summary'.tr(),
            subtitle: label,
            onBack: () => onOffsetChanged(1),
            onForward: () => onOffsetChanged(-1),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MonthStat(
                  value: onTime,
                  label: 'stats_on_time'.tr(),
                  color: AppColors.onTime),
              _MonthStat(
                  value: qaza, label: 'stats_qaza'.tr(), color: AppColors.qaza),
              _MonthStat(
                  value: missed,
                  label: 'stats_missed'.tr(),
                  color: AppColors.missed),
              _MonthStat(
                  value: notAdded,
                  label: 'stats_not_added'.tr(),
                  color: AppColors.statusNone),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'stats_total'.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '$total',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.softEmerald,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'stats_completion_rate'.tr(),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct / 100,
              backgroundColor: AppColors.softEmerald.withValues(alpha: 0.15),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.softEmerald),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${pct.toStringAsFixed(1)}% ${'stats_prayers_on_time'.tr()}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.softEmerald,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: !_hasData
                ? Center(
                    child: Text('stats_no_data'.tr(),
                        style: const TextStyle(color: AppColors.grey)))
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 25,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: theme.dividerColor.withValues(alpha: 0.5),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final int index = value.toInt();
                              if (index < 0 || index >= 12 || (index % 2 != 0 && index != 11)) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  SalahDateUtils.monthAbbr(index + 1),
                                  style: const TextStyle(color: AppColors.grey, fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 25,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}',
                                style: const TextStyle(color: AppColors.grey, fontSize: 10),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: 11,
                      minY: 0,
                      maxY: 100,
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(12, (i) => FlSpot(i.toDouble(), monthlyPercents[i])),
                          isCurved: true,
                          color: AppColors.softEmerald,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.softEmerald.withValues(alpha: 0.3),
                                AppColors.softEmerald.withValues(alpha: 0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  bool get _hasData => monthlyPercents.any((v) => v > 0);
}

class _MonthStat extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _MonthStat(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          '$value',
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
