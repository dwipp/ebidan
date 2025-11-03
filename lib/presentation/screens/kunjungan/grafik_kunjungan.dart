import 'package:ebidan/common/utility/app_colors.dart';
import 'package:ebidan/data/models/kunjungan_model.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/premium_warning_banner.dart';
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
    'td': 'Tekanan Darah (mmHg)',
  };

  List<Kunjungan> _sortByKunjunganStage(List<Kunjungan> list) {
    list.sort(
      (a, b) => (a.createdAt ?? DateTime(1900)).compareTo(
        b.createdAt ?? DateTime(1900),
      ),
    );
    return list;
  }

  List<double> _extractSingleMetric(
    String metric,
    List<Kunjungan> currentList,
  ) {
    return currentList.map((k) {
      final value = switch (metric) {
        'lp' => k.lp?.toString(),
        'bb' => k.bb?.toString(),
        'lila' => k.lila?.toString(),
        _ => null,
      };
      return double.tryParse(value ?? '') ?? 0;
    }).toList();
  }

  /// Parse tekanan darah dari format "120/70"
  Map<String, List<double>> _extractTekananDarah(List<Kunjungan> currentList) {
    final sistol = <double>[];
    final diastol = <double>[];

    for (var k in currentList) {
      final td = k.td?.trim() ?? '';
      if (td.contains('/')) {
        final parts = td.split('/');
        final s = double.tryParse(parts[0].trim()) ?? 0;
        final d = double.tryParse(parts.length > 1 ? parts[1].trim() : '') ?? 0;
        sistol.add(s);
        diastol.add(d);
      } else {
        sistol.add(0);
        diastol.add(0);
      }
    }

    return {'sistol': sistol, 'diastol': diastol};
  }

  LineChartData _buildLineChartData({
    required List<LineChartBarData> lineBars,
    required List<String> labels,
  }) {
    return LineChartData(
      gridData: FlGridData(show: true, horizontalInterval: 10),
      borderData: FlBorderData(show: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 45),
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
      lineBarsData: lineBars,
    );
  }

  LineChartBarData _buildLineBar({
    required List<double> values,
    required Color color,
  }) {
    return LineChartBarData(
      spots: [
        for (int i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
      ],
      isCurved: true,
      color: color,
      dotData: FlDotData(show: true),
      belowBarData: BarAreaData(show: false),
      barWidth: 3,
    );
  }

  @override
  Widget build(BuildContext context) {
    final warningBanner = PremiumWarningBanner.fromContext(context);
    return Scaffold(
      appBar: const PageHeader(title: Text("Grafik Kunjungan")),
      body: Column(
        children: [
          if (warningBanner != null)
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: warningBanner,
            ),
          Expanded(
            child: BlocBuilder<GetKunjunganCubit, GetKunjunganState>(
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

                  final labels = kunjunganList
                      .map((k) => k.status ?? '')
                      .toList();

                  Widget chartWidget;

                  if (_selectedMetric == 'td') {
                    final tekanan = _extractTekananDarah(kunjunganList);

                    final sistol = tekanan['sistol']!;
                    final diastol = tekanan['diastol']!;

                    final allZero =
                        sistol.every((d) => d == 0) &&
                        diastol.every((d) => d == 0);

                    chartWidget = allZero
                        ? const Center(
                            child: Text("Data tekanan darah tidak tersedia"),
                          )
                        : LineChart(
                            _buildLineChartData(
                              labels: labels,
                              lineBars: [
                                _buildLineBar(
                                  values: sistol,
                                  color: Colors.redAccent,
                                ),
                                _buildLineBar(
                                  values: diastol,
                                  color: Colors.blueAccent,
                                ),
                              ],
                            ),
                          );
                  } else {
                    final data = _extractSingleMetric(
                      _selectedMetric,
                      kunjunganList,
                    );
                    chartWidget = data.every((d) => d == 0)
                        ? const Center(
                            child: Text("Data tidak tersedia untuk metrik ini"),
                          )
                        : LineChart(
                            _buildLineChartData(
                              labels: labels,
                              lineBars: [
                                _buildLineBar(
                                  values: data,
                                  color: context.themeColors.primary,
                                ),
                              ],
                            ),
                          );
                  }

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
                        child: Padding(
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
                                  Expanded(child: chartWidget),
                                  if (_selectedMetric == 'td')
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          _LegendItem(
                                            color: Colors.redAccent,
                                            label: 'Sistol',
                                          ),
                                          SizedBox(width: 16),
                                          _LegendItem(
                                            color: Colors.blueAccent,
                                            label: 'Diastol',
                                          ),
                                        ],
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
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 14, height: 14, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
