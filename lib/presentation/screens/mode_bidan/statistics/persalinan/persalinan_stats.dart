import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/screens/mode_bidan/statistics/widgets/animated_data_card.dart';
import 'package:ebidan/presentation/screens/mode_bidan/statistics/widgets/info_button_bar.dart';
import 'package:ebidan/presentation/widgets/button.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/premium_warning_banner.dart';
import 'package:ebidan/state_management/general/cubit/statistic_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PersalinanStatsScreen extends StatelessWidget {
  final String? monthKey;
  const PersalinanStatsScreen({super.key, this.monthKey});

  @override
  Widget build(BuildContext context) {
    final stats = context.read<StatisticCubit>().state.statistic;
    final selectedMonth = stats?.byMonth[monthKey];
    final selectedPersalinan =
        selectedMonth?.persalinan ?? stats?.lastMonthData?.persalinan;
    final warningBanner = PremiumWarningBanner.fromContext(context);

    final List<Widget> gridItems = [];

    gridItems.add(
      StaggeredGridTile.count(
        crossAxisCellCount: 3,
        mainAxisCellCount: 1,
        child: AnimatedDataCard(
          label: "Total Persalinan",
          value: selectedPersalinan?.total ?? 0,
          isTotal: true,
          icon: Icons.bar_chart,
        ),
      ),
    );
    gridItems.add(_buildSectionHeader(context, "Tempat Bersalin"));
    final List<Map<String, dynamic>> tempats = [
      {
        "label": "Rumah Sakit",
        "value": selectedPersalinan?.tempatRs,
        'cross': 1,
        'main': 1,
      },
      {
        "label": "Rumah Sakit Bersalin",
        "value": selectedPersalinan?.tempatRsb,
        'cross': 2,
        'main': 1,
      },
      {
        "label": "Bidan Praktik Mandiri",
        "value": selectedPersalinan?.tempatBpm,
        'cross': 2,
        'main': 1.7,
      },
      {
        "label": "Klinik",
        "value": selectedPersalinan?.tempatKlinik,
        'cross': 1,
        'main': 0.85,
      },
      {
        "label": "Polindes",
        "value": selectedPersalinan?.tempatPolindes,
        'cross': 1,
        'main': 1.85,
      },
      {
        "label": "Puskesmas",
        "value": selectedPersalinan?.tempatPkm,
        'cross': 1,
        'main': 1,
      },
      {
        "label": "Poskesdes",
        "value": selectedPersalinan?.tempatPoskesdes,
        'cross': 1,
        'main': 1,
      },
    ];

    tempats.forEach((element) {
      gridItems.add(
        _buildCardItem(
          element["label"],
          element["value"],
          Colors.green.shade100,
          cross: element['cross'],
          main: element['main'],
        ),
      );
    });
    gridItems.add(
      StaggeredGridTile.count(
        crossAxisCellCount: 3,
        mainAxisCellCount: 1,
        child: AnimatedDataCard(
          label: "Persalinan Faskes",
          value: selectedPersalinan?.persalinanFaskes ?? 0,
          isTotal: true,
          icon: Icons.local_hospital,
        ),
      ),
    );

    final List<Map<String, dynamic>> nakes = [
      {
        "label": "Rumah dgn Nakes",
        "value": selectedPersalinan?.tempatRumahNakes,
        'cross': 2,
        'main': 0.85,
      },
      {
        "label": "Jalan dgn Nakes",
        "value": selectedPersalinan?.tempatJalanNakes,
        'cross': 2,
        'main': 0.85,
      },
      {
        "label": "Rumah dgn DK atau Keluarga",
        "value": selectedPersalinan?.tempatJalanNakes,
        'cross': 3,
        'main': 0.85,
      },
    ];

    gridItems.add(
      StaggeredGridTile.count(
        crossAxisCellCount: 1,
        mainAxisCellCount: 1.7,
        child: AnimatedDataCard(
          label: "Persalinan\nNakes",
          value: selectedPersalinan?.persalinanNakes ?? 0,
          isTotal: true,
          icon: Icons.medical_services,
        ),
      ),
    );

    nakes.forEach((element) {
      gridItems.add(
        _buildCardItem(
          element["label"],
          element["value"],
          Colors.green.shade100,
          cross: element['cross'],
          main: element['main'],
        ),
      );
    });

    gridItems.add(_buildSectionHeader(context, "Cara Bersalin"));

    final List<Map<String, dynamic>> caras = [
      {
        "label": "Spontan Belakang Kepala (Normal)",
        "value": selectedPersalinan?.caraNormal,
        'cross': 3,
        'main': 0.85,
      },
      {
        "label": "Vacuum Extraction",
        "value": selectedPersalinan?.caraVacuum,
        'cross': 1,
        'main': 1.7,
      },
      {
        "label": "Forceps Delivery",
        "value": selectedPersalinan?.caraForceps,
        'cross': 2,
        'main': 0.85,
      },
      {
        "label": "Section Caesarea (SC)",
        "value": selectedPersalinan?.caraSc,
        'cross': 2,
        'main': 0.85,
      },
    ];

    caras.forEach((element) {
      gridItems.add(
        _buildCardItem(
          element["label"],
          element["value"],
          Colors.yellow.shade100,
          cross: element['cross'],
          main: element['main'],
        ),
      );
    });
    gridItems.add(_buildSectionHeader(context, "Status Janin"));

    final List<Map<String, dynamic>> statusBayis = [
      {
        "label": "Lahir Hidup",
        "value": selectedPersalinan?.bayiLahirHidup,
        'cross': 1,
        'main': 1,
      },
      {
        "label": "Lahir Mati",
        "value": selectedPersalinan?.bayiLahirMati,
        'cross': 1,
        'main': 1,
      },
      {
        "label": "IUFD",
        "value": selectedPersalinan?.bayiIufd,
        'cross': 1,
        'main': 1,
      },
    ];

    statusBayis.forEach((element) {
      gridItems.add(
        _buildCardItem(
          element["label"],
          element["value"],
          Colors.red.shade100,
          cross: element['cross'],
          main: element['main'],
        ),
      );
    });

    return Scaffold(
      appBar: PageHeader(
        title: Text('Stats Persalinan'),
        actions: [
          InfoButtonBar(
            title: 'Tentang Statistik Persalinan',
            contentSpans: [
              const TextSpan(
                text:
                    'Statistik Persalinan menampilkan jumlah persalinan berdasarkan tempat, cara persalinan, dan keadaan janin.\n\n',
              ),
              const TextSpan(
                text: '• Tempat Persalinan: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    'Lokasi terjadinya persalinan, seperti RS, RSB, Klinik, BPM, Klinik, Puskesmas, Polindes, Poskesdes, atau di rumah dengan tenaga kesehatan maupun keluarga.\n\n',
              ),
              const TextSpan(
                text: '• Cara Partus: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    'Metode persalinan yang dilakukan — Normal, Vacuum, Forceps, atau SC (Caesar).\n\n',
              ),
              const TextSpan(
                text: '• Keadaan Janin: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    'Menunjukkan hasil akhir kondisi bayi: Lahir Hidup (LH), Lahir Mati (LM), atau IUFD.\n\n',
              ),
              const TextSpan(
                text:
                    'Data ini membantu memantau pola persalinan dan hasil kelahiran di wilayah kerja tenaga kesehatan.',
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
              StaggeredGrid.count(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: List.generate(gridItems.length, (i) {
                  return gridItems[i];
                }),
              ),
              const SizedBox(height: 32),
              // --- HISTORY BUTTON ---
              if (monthKey == Utils.getAutoYearMonth()) ...[
                SizedBox(
                  width: double.infinity,
                  child: Button(
                    isSubmitting: false,
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.listPersalinanStats,
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
                        AppRouter.trenPersalinanStats,
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
                        AppRouter.trenPersalinanStats,
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
                        AppRouter.trenPersalinanStats,
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

  Widget _buildCardItem(
    String label,
    int? value,
    Color bgColor, {
    int cross = 1,
    num main = 1,
  }) {
    final fgColor = Utils.generateForegroundColor(bgColor);
    final valueColor = Utils.generateHighContrastColor(bgColor);

    final card = Card(
      margin: EdgeInsets.zero,
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DefaultTextStyle(
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: fgColor),
              child: Text(label, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 4),
            Text(
              "${value ?? 0}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );

    return StaggeredGridTile.count(
      crossAxisCellCount: cross,
      mainAxisCellCount: main,
      child: card,
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return StaggeredGridTile.count(
      crossAxisCellCount: 3,
      mainAxisCellCount: 0.4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
