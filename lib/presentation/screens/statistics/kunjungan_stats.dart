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

    // Alternating colors untuk card kategori
    final List<Color> cardColors = [
      Colors.blue.shade50,
      Colors.green.shade50,
      Colors.orange.shade50
    ];

    // Daftar kategori
    final List<Map<String, dynamic>> kategori = [
      {"label": "K1", "value": lastMonth?.k1},
      {"label": "K1 Akses", "value": lastMonth?.k1Akses},
      {"label": "K1 Murni", "value": lastMonth?.k1Murni},
      {"label": "K1 USG", "value": lastMonth?.k1Usg},
      {"label": "K1 Kontrol Dokter", "value": lastMonth?.k1Dokter},
      {"label": "K2", "value": lastMonth?.k2},
      {"label": "K3", "value": lastMonth?.k3},
      {"label": "K4", "value": lastMonth?.k4},
      {"label": "K5", "value": lastMonth?.k5},
      {"label": "K6", "value": lastMonth?.k6}
    ];

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

              // --- TOTAL KUNJUNGAN ---
              _buildDataCard(
                "Total Kunjungan",
                lastMonth?.total,
                isTotal: true,
                icon: Icons.bar_chart,
              ),

              const SizedBox(height: 16),

              // --- GRID KATEGORI ---
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: kategori.length,
                itemBuilder: (context, index) {
                  final item = kategori[index];
                  return _buildDataCard(
                    item["label"],
                    item["value"],
                    backgroundColor: cardColors[index % cardColors.length],
                  );
                },
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

  Widget _buildDataCard(String label, int? value,
      {bool isTotal = false, Color? backgroundColor, IconData? icon}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: backgroundColor ?? (isTotal ? Colors.blue.shade100 : Colors.white),
      elevation: isTotal ? 3 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, size: 20, color: Colors.grey[700]),
            if (icon != null) const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isTotal ? Colors.blue : Colors.grey[700],
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              (value ?? 0).toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isTotal ? Colors.blue : Colors.black87,
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
