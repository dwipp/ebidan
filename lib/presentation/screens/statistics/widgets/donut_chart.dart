import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DonutChart extends StatelessWidget {
  final Map<String, num> data;
  final String? centerName;
  final num? centerValue;
  final bool showLegend;

  const DonutChart({
    super.key,
    required this.data,
    this.centerName,
    this.centerValue,
    this.showLegend = true,
  });

  Color _getRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(200) + 30,
      random.nextInt(200) + 30,
      random.nextInt(200) + 30,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<PieChartSectionData> sections = [];
    final List<Widget> legends = [];

    data.forEach((name, value) {
      final color = _getRandomColor();

      // Judul section
      String sectionTitle;
      if (showLegend) {
        sectionTitle = value.toStringAsFixed(0);
      } else {
        sectionTitle = "$name\n${value.toStringAsFixed(0)}";
      }

      sections.add(
        PieChartSectionData(
          value: value.toDouble(),
          color: color,
          title: sectionTitle,
          radius: 70,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );

      if (showLegend) {
        legends.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              Text(name),
            ],
          ),
        );
      }
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 60,
                  sectionsSpace: 2,
                ),
              ),
              if (centerName != null || centerValue != null)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (centerValue != null)
                      Text(
                        centerValue!.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (centerName != null)
                      Text(
                        centerName!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        if (showLegend) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: legends,
          ),
        ],
      ],
    );
  }
}
