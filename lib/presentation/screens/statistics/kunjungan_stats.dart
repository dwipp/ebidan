import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/screens/statistics/widgets/donut_chart.dart';
import 'package:ebidan/presentation/screens/statistics/widgets/k1_chart.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/premium_warning_banner.dart';
import 'package:ebidan/state_management/general/cubit/statistic_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class KunjunganStatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatisticCubit>().state.statistic;
    final lastMonth = stats?.lastMonthData?.kunjungan;
    final warningBanner = PremiumWarningBanner.fromContext(context);

    return Scaffold(
      appBar: PageHeader(title: 'Statistik Kunjungan'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (warningBanner != null) warningBanner,
              Text(
                "Laporan Bulan ${Utils.formattedYearMonth(stats?.lastUpdatedMonth ?? '')}",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // --- DATA UTAMA ---
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _buildDataCard("Total Kunjungan", lastMonth?.total),
                  _buildDataCard("K1", lastMonth?.k1),
                  _buildDataCard("K1 Akses", lastMonth?.k1Akses),
                  _buildDataCard("K1 Murni", lastMonth?.k1Murni),
                  _buildDataCard("K4", lastMonth?.k4),
                  _buildDataCard("K5", lastMonth?.k5),
                  _buildDataCard("K6", lastMonth?.k6),
                ],
              ),

              const SizedBox(height: 32),

              // --- CHART AREA ---
              Text(
                "Visualisasi",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text("Distribusi K1",
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 12),
                      K1Chart(
                        k1Murni: lastMonth?.k1Murni ?? 0,
                        k1Akses: lastMonth?.k1Akses ?? 0,
                        showCenterValue: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text("Perbandingan Kunjungan",
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 12),
                      DonutChart(
                        data: {
                          "K1": (lastMonth?.k1 ?? 0).toDouble(),
                          "K4": (lastMonth?.k4 ?? 0).toDouble(),
                          "K5": (lastMonth?.k5 ?? 0).toDouble(),
                          "K6": (lastMonth?.k6 ?? 0).toDouble(),
                        },
                        centerName: "Kunjungan",
                        centerValue: (lastMonth?.total ?? 0).toDouble(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // --- HISTORY BUTTON ---
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const KunjunganHistoryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text("Lihat Riwayat Bulanan"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCard(String label, int? value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                )),
            const SizedBox(height: 4),
            Text(
              (value ?? 0).toString(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// --- PAGE RIWAYAT ---
class KunjunganHistoryScreen extends StatelessWidget {
  const KunjunganHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data sementara, bisa diganti dengan data dari StatisticCubit
    final List<Map<String, dynamic>> history = [
      {"bulan": "Agustus 2025", "total": 120},
      {"bulan": "Juli 2025", "total": 98},
      {"bulan": "Juni 2025", "total": 110},
    ];

    return Scaffold(
      appBar: PageHeader(title: "Riwayat Kunjungan"),
      body: ListView.separated(
        itemCount: history.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = history[index];
          return ListTile(
            leading: const Icon(Icons.calendar_month),
            title: Text(item["bulan"]),
            subtitle: Text("Total kunjungan: ${item["total"]}"),
          );
        },
      ),
    );
  }
}
