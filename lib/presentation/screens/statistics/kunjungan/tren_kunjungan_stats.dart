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
    final dataByMonth =
        filteredKeys.map((k) => statistic?.byMonth[k]!).toList();

    final indikatorList = [
      ("K1", Colors.blue,
          dataByMonth.map((m) => m!.kunjungan.k1).toList()),
      ("K2", Colors.green,
          dataByMonth.map((m) => m!.kunjungan.k2).toList()),
      ("K3", Colors.yellow.shade600,
          dataByMonth.map((m) => m!.kunjungan.k3).toList()),
      ("K4", Colors.orange,
          dataByMonth.map((m) => m!.kunjungan.k4).toList()),
      ("K5", Colors.pink,
          dataByMonth.map((m) => m!.kunjungan.k5).toList()),
      ("K6", Colors.red,
          dataByMonth.map((m) => m!.kunjungan.k6).toList()),
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
            delay: Duration(milliseconds: 300 * i), // jeda antar chart
          );
        },
      ),
    );
  }
}

class _IndikatorChart extends StatefulWidget {
  final String label;
  final Color color;
  final List<int> values;
  final List<String> monthKeys;
  final Duration delay;

  const _IndikatorChart({
    required this.label,
    required this.color,
    required this.values,
    required this.monthKeys,
    this.delay = Duration.zero,
  });

  @override
  State<_IndikatorChart> createState() => _IndikatorChartState();
}

class _IndikatorChartState extends State<_IndikatorChart>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _played = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutExpo,
    );

    Future.delayed(widget.delay, () {
      if (mounted && !_played) {
        _controller.forward();
        _played = true;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatMonth(String key) {
    try {
      final date = DateFormat("yyyy-MM").parse(key);
      return DateFormat("MMM yyyy").format(date);
    } catch (_) {
      return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // valid karena pakai AutomaticKeepAliveClientMixin

    final maxVal = widget.values.isNotEmpty ? widget.values.reduce(max) : 0;
    final minVal = widget.values.isNotEmpty ? widget.values.reduce(min) : 0;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final len = widget.values.length;
        final animatedValues = [
          for (int i = 0; i < len; i++)
            (widget.values[i] * _animation.value).round()
        ];

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.white, widget.color.withOpacity(0.04)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                      ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          tooltipRoundedRadius: 10,
                          tooltipPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          tooltipMargin: 12,
                          getTooltipColor: (_) => Colors.black87,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final idx = spot.x.toInt();
                              final month = (idx >= 0 &&
                                      idx < widget.monthKeys.length)
                                  ? _formatMonth(widget.monthKeys[idx])
                                  : '';
                              final val = spot.y.toInt();
                              return LineTooltipItem(
                                "$month\n$val kunjungan",
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              );
                            }).toList();
                          },
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
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 40,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              final index = value.round();
                              if ((value - index).abs() > 1e-6) {
                                return const SizedBox.shrink();
                              }
                              if (index >= 0 &&
                                  index < widget.monthKeys.length) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 8,
                                  child: Text(
                                    _formatMonth(widget.monthKeys[index]),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      minX: -0.5,
                      maxX: (len - 1).toDouble() + 0.5,
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [
                              widget.color.withOpacity(0.95),
                              widget.color.withOpacity(0.55),
                              widget.color.withOpacity(0.2),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          barWidth: 4,
                          isStrokeCapRound: true,
                          spots: [
                            for (int i = 0; i < len; i++)
                              FlSpot(i.toDouble(),
                                  animatedValues[i].toDouble()),
                          ],
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) {
                              final isMax =
                                  spot.y.round() == maxVal;
                              final isMin =
                                  spot.y.round() == minVal;
                              return FlDotCirclePainter(
                                radius: isMax || isMin ? 6 : 3.5,
                                color: isMax
                                    ? Colors.greenAccent
                                    : isMin
                                        ? Colors.redAccent
                                        : widget.color,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                widget.color.withOpacity(0.25),
                                widget.color.withOpacity(0.05),
                                Colors.transparent,
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
          ),
        );
      },
    );
  }
}
