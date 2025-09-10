import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class K1Chart extends StatelessWidget {
  final int k1Murni;
  final int k1Akses;
  final bool showCenterValue;

  const K1Chart({
    super.key,
    required this.k1Murni,
    required this.k1Akses,
    this.showCenterValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final total = k1Murni + k1Akses;
    if (total == 0)
      return const SizedBox(height: 150); // prevent divide by zero

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 50,
                  sections: [
                    PieChartSectionData(
                      value: k1Murni.toDouble(),
                      color: Colors.greenAccent.shade700,
                      radius: 50,
                      title: '${((k1Murni / total) * 100).toStringAsFixed(1)}%',
                    ),
                    PieChartSectionData(
                      value: k1Akses.toDouble(),
                      color: Colors.orangeAccent.shade700,
                      radius: 50,
                      title: '${((k1Akses / total) * 100).toStringAsFixed(1)}%',
                    ),
                  ],
                ),
              ),
              if (showCenterValue)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$total",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Total K1",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegend(
              color: Colors.greenAccent.shade700,
              text: "K1 Murni ($k1Murni)",
            ),
            const SizedBox(width: 16),
            _buildLegend(
              color: Colors.orangeAccent.shade700,
              text: "K1 Akses ($k1Akses)",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegend({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
