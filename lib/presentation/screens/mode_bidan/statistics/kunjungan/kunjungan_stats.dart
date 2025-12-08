import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/common/utility/app_colors.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/screens/mode_bidan/statistics/widgets/animated_data_card.dart';
import 'package:ebidan/presentation/screens/mode_bidan/statistics/widgets/donut_chart.dart';
import 'package:ebidan/presentation/screens/mode_bidan/statistics/widgets/info_button_bar.dart';
import 'package:ebidan/presentation/screens/mode_bidan/statistics/widgets/k1_chart.dart';
import 'package:ebidan/presentation/widgets/button.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/premium_warning_banner.dart';
import 'package:ebidan/state_management/general/cubit/statistic_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class KunjunganStatsScreen extends StatelessWidget {
  final String? monthKey;

  const KunjunganStatsScreen({super.key, this.monthKey});

  @override
  Widget build(BuildContext context) {
    final stats = context.read<StatisticCubit>().state.statistic;
    final selectedMonth = stats?.byMonth[monthKey];
    final selectedKunjungan =
        selectedMonth?.kunjungan ?? stats?.lastMonthData?.kunjungan;
    final warningBanner = PremiumWarningBanner.fromContext(context);

    final List<Map<String, dynamic>> kategori = [
      {"label": "K1", "value": selectedKunjungan?.k1},
      {"label": "K1 MURNI", "value": selectedKunjungan?.k1Murni},
      {
        "label": "K1 Murni Skrining Dokter",
        "value": selectedKunjungan?.k1MurniDokter,
      },
      {"label": "K1 Murni USG", "value": selectedKunjungan?.k1MurniUsg},
      {"label": "K1 AKSES", "value": selectedKunjungan?.k1Akses},
      {
        "label": "K1 Akses Skrining Dokter",
        "value": selectedKunjungan?.k1AksesDokter,
      },
      {"label": "K1 Akses USG", "value": selectedKunjungan?.k1AksesUsg},
      {"label": "K1 USG", "value": selectedKunjungan?.k1Usg},
      {"label": "K1 Skrining Dokter", "value": selectedKunjungan?.k1Dokter},
      {"label": "K1 dengan 4T", "value": selectedKunjungan?.k14t},
      {"label": "K2", "value": selectedKunjungan?.k2},
      {"label": "K3", "value": selectedKunjungan?.k3},
      {"label": "K4", "value": selectedKunjungan?.k4},
      {"label": "Abortus (0-20 mg)", "value": selectedKunjungan?.abortus},
      {"label": "K5", "value": selectedKunjungan?.k5},
      {"label": "K5 USG", "value": selectedKunjungan?.k5Usg},
      {"label": "K6", "value": selectedKunjungan?.k6},
      {"label": "K6 USG", "value": selectedKunjungan?.k6Usg},
    ];

    // Siapkan daftar item untuk grid view
    final List<Widget> gridItems = [];

    // Tambahkan kartu total kunjungan sebagai item pertama
    gridItems.add(
      AnimatedDataCard(
        label: "Total Kunjungan",
        value: selectedKunjungan?.total ?? 0,
        isTotal: true,
        icon: Icons.bar_chart,
      ),
    );

    // Kelompokkan data kategori
    final Map<String, List<Map<String, dynamic>>> grouped = _groupKategori(
      kategori,
    );

    // Tambahkan kartu kategori ke dalam daftar
    grouped.entries.forEach((entry) {
      final parentLabel = entry.key;
      final children = entry.value;

      if (children.length == 1) {
        final item = children.first;
        gridItems.add(_buildCardItem(item["label"], item["value"]));
      } else {
        final parentItem = children.first;
        final subItems = children.skip(1).toList();

        gridItems.add(
          Card(
            margin: EdgeInsets.zero,
            color: _getKategoriColor(parentLabel).shade200,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parentLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${parentItem["value"] ?? 0}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: _getKategoriColor(parentLabel).shade400,
                    ),
                  ),
                  const Divider(),
                  ...subItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item["label"],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          Text(
                            "${item["value"] ?? 0}",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: context
                                  .themeColors
                                  .darkGrey, //_getKategoriColor(item["label"]).shade400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: PageHeader(
        title: Text('Stats Kunjungan'),
        actions: [
          InfoButtonBar(
            title: 'Tentang Statistik Kunjungan',
            contentSpans: [
              const TextSpan(
                text:
                    'Statistik Kunjungan digunakan untuk memantau jumlah dan jenis kunjungan ibu hamil berdasarkan tahapan pemeriksaan.\n\n',
              ),
              const TextSpan(
                text: '• Total Kunjungan:\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    'Jumlah keseluruhan kunjungan ibu hamil dalam satu bulan.\n\n',
              ),
              const TextSpan(
                text: '• K1 (Kunjungan Pertama):\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text: 'Biasanya dilakukan sebelum usia kehamilan 12 minggu.\n',
              ),
              const TextSpan(
                text: '- K1 Murni: ',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const TextSpan(
                text:
                    'Pemeriksaan pertama dalam rentang usia kehamilan 12 minggu atau kurang.\n',
              ),
              const TextSpan(
                text: '- K1 Akses: ',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const TextSpan(
                text:
                    'Pemeriksaan pertama di usia kehamilan lebih dari 12 minggu.\n',
              ),
              const TextSpan(
                text: '- K1 dengan 4T: ',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const TextSpan(
                text:
                    'K1 yang memiliki salah satu faktor risiko dari kategori “4 Terlalu”, yaitu: terlalu muda, terlalu tua, terlalu sering melahirkan, atau terlalu dekat jarak melahirkannya.\n\n',
              ),
              const TextSpan(
                text: '• K2–K6: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    'Kunjungan lanjutan untuk pemantauan rutin kehamilan sesuai standar ANC (Antenatal Care).\n\n',
              ),
              const TextSpan(
                text: '• Abortus (0–20 mg): ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    'Kasus keguguran atau kehamilan tidak berlanjut sebelum 20 minggu.\n\n',
              ),
              const TextSpan(
                text:
                    'Kunjungan ini membantu bidan memantau kepatuhan ibu hamil terhadap pemeriksaan kehamilan sesuai jadwal ideal (minimal 6 kali pemeriksaan selama kehamilan).',
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (warningBanner != null) warningBanner,
              Text(
                "Laporan Bulan ${Utils.formattedDateFromYearMonth(monthKey ?? stats?.lastUpdatedMonth ?? '')}",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // --- GRID VIEW UNTUK TOTAL & KATEGORI ---
              MasonryGridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                itemCount: gridItems.length,
                itemBuilder: (context, index) {
                  return gridItems[index];
                },
              ),

              const SizedBox(height: 32),

              // --- CHART AREA ---
              if (selectedKunjungan != null &&
                  (selectedKunjungan.k1 > 0 ||
                      selectedKunjungan.k2 > 0 ||
                      selectedKunjungan.k3 > 0 ||
                      selectedKunjungan.k4 > 0 ||
                      selectedKunjungan.k5 > 0 ||
                      selectedKunjungan.k6 > 0)) ...[
                Text(
                  "Visualisasi",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // --- Donut Chart Card ---
                _buildChartCard(
                  context,
                  "Perbandingan Kunjungan",
                  DonutChart(
                    data: [
                      PieChartDataItem(
                        label: 'K1',
                        value: (selectedKunjungan.k1).toDouble(),
                      ),
                      PieChartDataItem(
                        label: 'K2',
                        value: (selectedKunjungan.k2).toDouble(),
                      ),
                      PieChartDataItem(
                        label: 'K3',
                        value: (selectedKunjungan.k3).toDouble(),
                      ),
                      PieChartDataItem(
                        label: 'K4',
                        value: (selectedKunjungan.k4).toDouble(),
                      ),
                      PieChartDataItem(
                        label: 'K5',
                        value: (selectedKunjungan.k5).toDouble(),
                      ),
                      PieChartDataItem(
                        label: 'K6',
                        value: (selectedKunjungan.k6).toDouble(),
                      ),
                    ],
                    showCenterValue: true,
                    centerLabelTop: '${selectedKunjungan.total}',
                    centerLabelBottom: 'Kunjungan',
                  ),
                  gradientColors: context.themeColors.tealGradient,
                  shadowColor: Colors.blue.shade100.withOpacity(0.4),
                ),
                const SizedBox(height: 24),
              ],

              // --- K1 Chart Card ---
              if (selectedKunjungan != null &&
                  (selectedKunjungan.k1Murni > 0 ||
                      selectedKunjungan.k1Akses > 0)) ...[
                _buildChartCard(
                  context,
                  "Distribusi K1",
                  K1Chart(
                    k1Murni: selectedKunjungan.k1Murni,
                    k1Akses: selectedKunjungan.k1Akses,
                    showCenterValue: true,
                  ),
                  gradientColors: context.themeColors.orangeGradient,
                  shadowColor: Colors.orange.shade100.withOpacity(0.4),
                ),

                const SizedBox(height: 32),
              ],
              // --- HISTORY BUTTON ---
              if (monthKey == Utils.getAutoYearMonth()) ...[
                SizedBox(
                  width: double.infinity,
                  child: Button(
                    isSubmitting: false,
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.listKunjunganStats,
                      );
                    },
                    label: "Lihat Riwayat Bulanan",
                    icon: Icons.history,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Button(
                    isSubmitting: false,
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.trenKunjunganStats,
                        arguments: {
                          'monthKeys': Utils.getLastMonths(
                            stats!.lastUpdatedMonth,
                            3,
                          ),
                        },
                      );
                    },
                    label: "Tren 3 Bulan Terakhir",
                    icon: Icons.trending_up,
                    secondaryButton: true,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Button(
                    isSubmitting: false,
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.trenKunjunganStats,
                        arguments: {
                          'monthKeys': Utils.getLastMonths(
                            stats!.lastUpdatedMonth,
                            6,
                          ),
                        },
                      );
                    },
                    label: "Tren 6 Bulan Terakhir",
                    icon: Icons.show_chart,
                    secondaryButton: true,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Button(
                    isSubmitting: false,
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.trenKunjunganStats,
                        arguments: {
                          'monthKeys': Utils.getLastMonths(
                            stats!.lastUpdatedMonth,
                            12,
                          ),
                        },
                      );
                    },
                    label: "Tren 1 Tahun Terakhir",
                    icon: Icons.insert_chart_outlined,
                    secondaryButton: true,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper method untuk membuat card item sederhana
  Widget _buildCardItem(String label, int? value) {
    return Card(
      margin: EdgeInsets.zero,
      color: _getKategoriColor(label).shade200,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text(
              "${value ?? 0}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: _getKategoriColor(label).shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method untuk membuat card visualisasi
  Widget _buildChartCard(
    BuildContext context,
    String title,
    Widget chart, {
    required LinearGradient gradientColors,
    required Color shadowColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: gradientColors,
      ),
      child: Column(
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 12),
          chart,
        ],
      ),
    );
  }

  // Helper method untuk mengelompokkan kategori
  Map<String, List<Map<String, dynamic>>> _groupKategori(
    List<Map<String, dynamic>> kategori,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var item in kategori) {
      final label = item["label"];
      String parent;

      if (label.toString().startsWith("K1")) {
        parent = "K1";
      } else if (label.toString().startsWith("K2")) {
        parent = "K2";
      } else if (label.toString().startsWith("K3")) {
        parent = "K3";
      } else if (label.toString().startsWith("K4")) {
        parent = "K4";
      } else if (label.toString().startsWith("K5")) {
        parent = "K5";
      } else if (label.toString().startsWith("K6")) {
        parent = "K6";
      } else {
        parent = label;
      }

      grouped.putIfAbsent(parent, () => []);
      grouped[parent]!.add(item);
    }
    return grouped;
  }

  // Helper method untuk mendapatkan warna
  MaterialColor _getKategoriColor(String label) {
    if (label.startsWith("K1")) return Colors.blue;
    if (label.startsWith("K2")) return Colors.teal;
    if (label.startsWith("K3")) return Colors.green;
    if (label.startsWith("K4")) return Colors.orange;
    if (label.startsWith("K5")) return Colors.pink;
    if (label.startsWith("K6")) return Colors.red;
    if (label.contains("Abortus")) return Colors.purple;
    return Colors.grey;
  }
}
