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
    if (total == 0) {
      return const SizedBox(height: 180); // prevent divide by zero
    }

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
                    _buildSection(
                      value: k1Murni.toDouble(),
                      color: Colors.greenAccent.shade700,
                      label: k1Murni,
                      total: total,
                    ),
                    _buildSection(
                      value: k1Akses.toDouble(),
                      color: Colors.orangeAccent.shade700,
                      label: k1Akses,
                      total: total,
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
                        color: Colors.black54,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Total K1",
                      style: TextStyle(color: Colors.black45, fontSize: 12),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildLegend(color: Colors.greenAccent.shade700, text: "K1 Murni"),
            _buildLegend(color: Colors.orangeAccent.shade700, text: "K1 Akses"),
          ],
        ),
      ],
    );
  }

  PieChartSectionData _buildSection({
    required double value,
    required Color color,
    required int label,
    required int total,
  }) {
    return PieChartSectionData(
      value: value,
      showTitle: false,
      color: color,
      radius: 50,
      badgeWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${((value / total) * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '$label',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.normal,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      titlePositionPercentageOffset: 0.6, // sesuaikan posisi text di tengah
    );
  }

  Widget _buildLegend({required Color color, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
