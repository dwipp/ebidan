import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class InteractiveBarChart extends StatefulWidget {
  final Map<String, num> data;

  const InteractiveBarChart({
    super.key,
    required this.data,
  });

  @override
  State<InteractiveBarChart> createState() => _InteractiveBarChartState();
}

class _InteractiveBarChartState extends State<InteractiveBarChart> {
  int? touchedIndex;
  late final List<Color> barColors;

  @override
  void initState() {
    super.initState();
    final random = Random();
    barColors = List.generate(
      widget.data.length,
      (_) => Color.fromARGB(
        255,
        random.nextInt(200) + 30,
        random.nextInt(200) + 30,
        random.nextInt(200) + 30,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxY = (widget.data.values.reduce((a, b) => a > b ? a : b) * 1.2).toDouble();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: max(widget.data.length * 60.0, 300),
        height: 300,
        child: BarChart(
          BarChartData(
            maxY: maxY,
            alignment: BarChartAlignment.spaceAround,
            barTouchData: BarTouchData(
              enabled: true,
              touchCallback: (event, response) {
                if (response != null &&
                    response.spot != null &&
                    event is! FlPanEndEvent) {
                  setState(() {
                    touchedIndex = response.spot!.touchedBarGroupIndex;
                  });
                } else {
                  setState(() {
                    touchedIndex = null;
                  });
                }
              },
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final label = widget.data.keys.elementAt(group.x.toInt());
                  return BarTooltipItem(
                    "$label\n${rod.toY.toInt()}",
                    const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < widget.data.length) {
                      final label = widget.data.keys.elementAt(value.toInt());
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          label,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(widget.data.length, (index) {
              final key = widget.data.keys.elementAt(index);
              final value = widget.data[key]!.toDouble();
              final isTouched = index == touchedIndex;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: value,
                    color: isTouched
                        ? barColors[index].withOpacity(0.7)
                        : barColors[index],
                    width: 24,
                    borderRadius: BorderRadius.circular(6),
                    rodStackItems: [
                      // Overlay value di dalam bar
                      BarChartRodStackItem(0, value, barColors[index]),
                    ],
                  ),
                ],
                showingTooltipIndicators: [0],
              );
            }),
          ),
        ),
      ),
    );
  }
}
