import 'dart:math';
import 'package:ebidan/state_management/general/cubit/statistic_cubit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TrenKunjunganStatsScreen extends StatelessWidget {
  final List<String> monthKeys;

  const TrenKunjunganStatsScreen({
    super.key,
    required this.monthKeys,
  });

  @override
  Widget build(BuildContext context) {
    final statistic = context.read<StatisticCubit>().state.statistic;

    final filteredKeys = monthKeys
        .where((k) => statistic!.byMonth.containsKey(k))
        .toList();
    final dataByMonth = filteredKeys.map((k) => statistic?.byMonth[k]!).toList();

    final indikatorList = [
      ("K1", Colors.blue, dataByMonth.map((m) => m!.kunjungan.k1).toList()),
      ("K2", Colors.green, dataByMonth.map((m) => m!.kunjungan.k2).toList()),
      ("K3", Colors.yellow.shade500, dataByMonth.map((m) => m!.kunjungan.k3).toList()),
      ("K4", Colors.orange, dataByMonth.map((m) => m!.kunjungan.k4).toList()),
      ("K5", Colors.pink, dataByMonth.map((m) => m!.kunjungan.k5).toList()),
      ("K6", Colors.red, dataByMonth.map((m) => m!.kunjungan.k6).toList()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tren Kunjungan"),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: indikatorList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 24),
        itemBuilder: (context, i) {
          final (label, color, values) = indikatorList[i];
          return _IndikatorChart(
            label: label,
            color: color,
            values: values,
            monthKeys: filteredKeys,
          );
        },
      ),
    );
  }
}

class _IndikatorChart extends StatelessWidget {
  final String label;
  final Color color;
  final List<int> values;
  final List<String> monthKeys;

  const _IndikatorChart({
    required this.label,
    required this.color,
    required this.values,
    required this.monthKeys,
  });

  String _formatMonth(String key) {
    try {
      final date = DateFormat("yyyy-MM").parse(key);
      return DateFormat("MMM yyyy").format(date); // "Sep 2025"
    } catch (_) {
      return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ensure we only draw as many points as we have month labels
    final len = min(values.length, monthKeys.length);
    final visibleValues = values.take(len).toList();

    final maxVal =
        visibleValues.isNotEmpty ? visibleValues.reduce((a, b) => a > b ? a : b) : 0;
    final minVal =
        visibleValues.isNotEmpty ? visibleValues.reduce((a, b) => a < b ? a : b) : 0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.white, color.withOpacity(0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  // tooltip (use getTooltipColor & getTooltipItems)
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipRoundedRadius: 8,
                      tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      tooltipMargin: 8,
                      // return color for tooltip bg
                      getTooltipColor: (touchedSpots) => Colors.black87,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final idx = spot.x.toInt();
                          final month = (idx >= 0 && idx < monthKeys.length)
                              ? _formatMonth(monthKeys[idx])
                              : '';
                          final val = spot.y.toInt();
                          return LineTooltipItem(
                            "$month\n$val kunjungan",
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                          );
                        }).toList();
                      },
                      // ensure tooltip fits inside chart when near edges
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                    ),
                  ),

                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.14),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 44,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          // show label only for integer indices (avoid duplicates)
                          final index = value.round();
                          if ((value - index).abs() > 1e-6) return const SizedBox.shrink();
                          if (index >= 0 && index < monthKeys.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 8,
                              child: Text(
                                _formatMonth(monthKeys[index]),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),

                  // left/right margin so first/last label stay inside card
                  minX: -0.5,
                  maxX: (len - 1).toDouble() + 0.5,

                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      // gradient line
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.95), color.withOpacity(0.35)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      barWidth: 4,
                      isStrokeCapRound: true,
                      spots: [
                        for (int i = 0; i < len; i++) FlSpot(i.toDouble(), visibleValues[i].toDouble()),
                      ],
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) {
                          final isMax = spot.y == maxVal.toDouble();
                          final isMin = spot.y == minVal.toDouble();
                          return FlDotCirclePainter(
                            radius: isMax || isMin ? 5 : 3,
                            color: isMax ? Colors.green : isMin ? Colors.red : color,
                            strokeWidth: 1.4,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [color.withOpacity(0.18), Colors.transparent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
                // use new param names (duration & curve) -> fixes swapAnimationDuration/Curve error
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
