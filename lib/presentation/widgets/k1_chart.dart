import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class K1Chart extends StatelessWidget {
  final int k1Murni;
  final int k1Akses;

  const K1Chart({super.key, required this.k1Murni, required this.k1Akses});

  @override
  Widget build(BuildContext context) {
    final total = k1Murni + k1Akses;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 60, // bikin donut
              sections: [
                PieChartSectionData(
                  value: k1Murni.toDouble(),
                  color: Colors.green,
                  radius: 50,
                  title: "${((k1Murni / total) * 100).toStringAsFixed(1)}%",
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                PieChartSectionData(
                  value: k1Akses.toDouble(),
                  color: Colors.orange,
                  radius: 50,
                  title: "${((k1Akses / total) * 100).toStringAsFixed(1)}%",
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegend(color: Colors.green, text: "K1 Murni ($k1Murni)"),
            const SizedBox(width: 16),
            _buildLegend(color: Colors.orange, text: "K1 Akses ($k1Akses)"),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Total K1: $total",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildLegend({required Color color, required String text}) {
    return Row(
      children: [
        Container(width: 14, height: 14, color: color),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}
