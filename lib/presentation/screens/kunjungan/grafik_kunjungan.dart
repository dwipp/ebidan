import 'package:ebidan/common/utility/app_colors.dart';
import 'package:ebidan/data/models/kunjungan_model.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/state_management/kunjungan/cubit/get_kunjungan_cubit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GrafikKunjunganScreen extends StatefulWidget {
  const GrafikKunjunganScreen({super.key});

  @override
  State<GrafikKunjunganScreen> createState() => _GrafikKunjunganScreenState();
}

class _GrafikKunjunganScreenState extends State<GrafikKunjunganScreen> {
  String _selectedMetric = 'lp';
  final Map<String, String> _metricLabels = {
    'lp': 'Lingkar Perut (cm)',
    'bb': 'Berat Badan (kg)',
    'lila': 'LILA (cm)',
  };

  List<Kunjungan> _sortByKunjunganStage(List<Kunjungan> list) {
    list.sort(
      (a, b) => (a.createdAt ?? DateTime(1900)).compareTo(
        b.createdAt ?? DateTime(1900),
      ),
    );
    return list;
  }

  List<double> _extractData(String metric, List<Kunjungan> currentList) {
    return currentList.map((k) {
      final value = switch (metric) {
        'lp' => k.lp?.toString(),
        'bb' => k.bb?.toString(),
        'lila' => k.lila?.toString(),
        'tfu' => k.tfu?.toString().replaceAll("cm", "").trim(),
        _ => null,
      };
      return double.tryParse(value ?? '') ?? 0;
    }).toList();
  }

  LineChartData _buildLineChartData({
    required List<double> values,
    required List<String> labels,
    required Color color,
  }) {
    return LineChartData(
      gridData: FlGridData(show: true, horizontalInterval: 2),
      borderData: FlBorderData(show: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= labels.length) return const SizedBox();
              return Text(labels[index], style: const TextStyle(fontSize: 12));
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: [
            for (int i = 0; i < values.length; i++)
              FlSpot(i.toDouble(), values[i]),
          ],
          isCurved: true,
          color: color,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
          barWidth: 3,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageHeader(title: Text("Grafik Kunjungan")),
      body: BlocBuilder<GetKunjunganCubit, GetKunjunganState>(
        builder: (context, state) {
          if (state is GetKunjunganLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: context.themeColors.tertiary,
              ),
            );
          } else if (state is GetKunjunganFailure ||
              state is GetKunjunganEmpty) {
            return const Center(child: Text("Tidak ada data kunjungan"));
          } else if (state is GetKunjunganSuccess) {
            var kunjunganList = _sortByKunjunganStage(state.kunjungans);

            final labels = kunjunganList.map((k) => k.status ?? '').toList();
            final data = _extractData(_selectedMetric, kunjunganList);

            return Column(
              children: [
                // Dropdown Pilih Metrik
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      const Text(
                        "Pilih Metrik: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedMetric,
                          items: _metricLabels.entries
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e.key,
                                  child: Text(e.value),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val == null) return;
                            setState(() {
                              _selectedMetric = val;
                            });
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Grafik
                Expanded(
                  child: data.every((d) => d == 0)
                      ? const Center(
                          child: Text("Data tidak tersedia untuk metrik ini"),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    _metricLabels[_selectedMetric]!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: LineChart(
                                      _buildLineChartData(
                                        values: data,
                                        labels: labels,
                                        color: context.themeColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
