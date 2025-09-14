import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/state_management/general/cubit/statistic_cubit.dart';
import 'package:ebidan/data/models/statistic_model.dart';

class TrenKunjunganStatsScreen extends StatelessWidget {
  final List<String> monthKeys;
  const TrenKunjunganStatsScreen({super.key, required this.monthKeys});

  @override
  Widget build(BuildContext context) {
    final stats = context.read<StatisticCubit>().state.statistic;

    if (stats == null || stats.byMonth.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tren 3 Bulan Kunjungan')),
        body: const Center(child: Text('Data tidak tersedia')),
      );
    }

    // --- Ambil semua bulan yang tersedia dan pilih 3 terakhir ---
    final monthKeys = stats.byMonth.keys.toList()..sort();
    final last3Months = monthKeys.length >= 3
        ? monthKeys.sublist(monthKeys.length - 3)
        : monthKeys;

    // --- Siapkan data tren per kategori ---
    Map<String, List<int>> kunjunganTren = {
      'K1': [],
      'K1 Akses': [],
      'K1 Murni': [],
      'K1 USG': [],
      'K1 Dokter': [],
      'K2': [],
      'K3': [],
      'K4': [],
      'K5': [],
      'K6': [],
    };

    for (var month in last3Months) {
      final data = stats.byMonth[month]?.kunjungan;
      kunjunganTren['K1']?.add(data?.k1 ?? 0);
      kunjunganTren['K1 Akses']?.add(data?.k1Akses ?? 0);
      kunjunganTren['K1 Murni']?.add(data?.k1Murni ?? 0);
      kunjunganTren['K1 USG']?.add(data?.k1Usg ?? 0);
      kunjunganTren['K1 Dokter']?.add(data?.k1Dokter ?? 0);
      kunjunganTren['K2']?.add(data?.k2 ?? 0);
      kunjunganTren['K3']?.add(data?.k3 ?? 0);
      kunjunganTren['K4']?.add(data?.k4 ?? 0);
      kunjunganTren['K5']?.add(data?.k5 ?? 0);
      kunjunganTren['K6']?.add(data?.k6 ?? 0);
    }

    // --- Warna tiap kategori ---
    Map<String, Color> kategoriColor = {
      'K1': Colors.lightBlue.shade50,
      'K1 Akses': Colors.blue.shade50,
      'K1 Murni': Colors.blue.shade100,
      'K1 USG': Colors.blue.shade200,
      'K1 Dokter': Colors.blue.shade300,
      'K2': Colors.green.shade50,
      'K3': Colors.yellow.shade50,
      'K4': Colors.orange.shade50,
      'K5': Colors.pink.shade50,
      'K6': Colors.red.shade100,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Tren 3 Bulan Kunjungan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Periode: ${Utils.formattedYearMonth(last3Months.first)} - ${Utils.formattedYearMonth(last3Months.last)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // --- Grid 3 kategori per baris ---
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: kunjunganTren.keys.length,
                itemBuilder: (context, index) {
                  final key = kunjunganTren.keys.elementAt(index);
                  final history = kunjunganTren[key] ?? [];
                  return BarChartCard(
                    label: key,
                    history: history,
                    color: kategoriColor[key] ?? Colors.blue,
                    monthLabels: last3Months,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// --- SIMPLE BAR CHART ---
class BarChartCard extends StatelessWidget {
  final String label;
  final List<int> history;
  final Color color;
  final List<String> monthLabels;

  const BarChartCard({
    super.key,
    required this.label,
    required this.history,
    required this.color,
    required this.monthLabels,
  });

  @override
  Widget build(BuildContext context) {
    final maxY = history.isNotEmpty ? history.reduce((a, b) => a > b ? a : b).toDouble() : 1;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxY.toDouble(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 25),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index < 0 || index >= monthLabels.length) return const SizedBox();
                        return Text(
                          Utils.formattedYearMonth(monthLabels[index]),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(history.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: history[index].toDouble(),
                        color: color,
                        width: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
