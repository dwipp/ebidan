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
      ("K2", Colors.redAccent, dataByMonth.map((m) => m!.kunjungan.k2).toList()),
      ("K3", Colors.green, dataByMonth.map((m) => m!.kunjungan.k3).toList()),
      ("K4", Colors.orange, dataByMonth.map((m) => m!.kunjungan.k4).toList()),
      ("K5", Colors.purple, dataByMonth.map((m) => m!.kunjungan.k5).toList()),
      ("K6", Colors.teal, dataByMonth.map((m) => m!.kunjungan.k6).toList()),
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
      return DateFormat("MMM yyyy").format(date); // contoh: "Sep 2025"
    } catch (_) {
      return key; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.18),
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
                        reservedSize: 40,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          // only show label when value is (almost) integer
                          final index = value.round();
                          if ((value - index).abs() > 1e-6) return const SizedBox.shrink();
                          if (index >= 0 && index < monthKeys.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 8,
                              child: Text(
                                _formatMonth(monthKeys[index]),
                                style: const TextStyle(fontSize: 11),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  // keep small horizontal margin so first/last label stay inside card
                  minX: -0.5,
                  maxX: (monthKeys.length - 1).toDouble() + 0.5,
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      spots: [
                        for (int i = 0; i < values.length; i++)
                          FlSpot(i.toDouble(), values[i].toDouble())
                      ],
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

