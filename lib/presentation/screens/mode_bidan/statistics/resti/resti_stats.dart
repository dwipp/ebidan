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

class RestiStatsScreen extends StatelessWidget {
  final String? monthKey;
  const RestiStatsScreen({super.key, this.monthKey});

  @override
  Widget build(BuildContext context) {
    final stats = context.read<StatisticCubit>().state.statistic;
    final selectedMonth = stats?.byMonth[monthKey];
    final selectedResti = selectedMonth?.resti ?? stats?.lastMonthData?.resti;
    final warningBanner = PremiumWarningBanner.fromContext(context);

    final List<Map<String, dynamic>> kategori = [
      {
        "label": "Resti Nakes",
        "value": selectedResti?.restiNakes,
        'cross': 1,
        'main': 1,
      },
      {
        "label": "Resti Masyarakat",
        "value": selectedResti?.restiMasyarakat,
        'cross': 2,
        'main': 1,
      },
      {
        "label": "Resiko Panggul Sempit \n(tb < 145 cm)",
        "value": selectedResti?.tbUnder145,
        'cross': 2,
        'main': 1.7,
      },
      {
        "label": "Hipertensi",
        "value": selectedResti?.hipertensi,
        'cross': 1,
        'main': 0.85,
      },
      {
        "label": "Obesitas",
        "value": selectedResti?.obesitas,
        'cross': 1,
        'main': 0.85,
      },
      {
        "label": "Anemia",
        "value": selectedResti?.anemia,
        'cross': 1,
        'main': 1,
      },
      {
        "label": "Paritas Tinggi (>=4x)",
        "value": selectedResti?.paritasTinggi,
        'cross': 2,
        'main': 1,
      },
      {
        "label": "Usia Terlalu Tua (> 35 thn)",
        "value": selectedResti?.tooOld,
        'cross': 2,
        'main': 0.85,
      },
      {
        "label": "Usia Terlalu Muda (< 20 thn)",
        "value": selectedResti?.tooYoung,
        'cross': 2,
        'main': 0.85,
      },
      {
        "label": "Pernah Abortus",
        "value": selectedResti?.pernahAbortus,
        'cross': 1,
        'main': 1.7,
      },
      {
        "label": "Kekurangan Energi Kronis (KEK)",
        "value": selectedResti?.kek,
        'cross': 3,
        'main': 1,
      },
    ];
    final List<Widget> gridItems = [];

    gridItems.add(
      StaggeredGridTile.count(
        crossAxisCellCount: 3,
        mainAxisCellCount: 1,
        child: AnimatedDataCard(
          label: "Total Resti (pasien)",
          value: selectedResti?.totalResti ?? 0,
          isTotal: true,
          icon: Icons.bar_chart,
        ),
      ),
    );

    kategori.forEach((element) {
      gridItems.add(
        _buildCardItem(
          element["label"],
          element["value"],
          cross: element['cross'],
          main: element['main'],
        ),
      );
    });

    return Scaffold(
      appBar: PageHeader(
        title: Text('Stats Resti'),
        actions: [
          InfoButtonBar(
            title: 'Tentang Statistik Resti',
            contentSpans: [
              const TextSpan(
                text:
                    'Statistik Resti digunakan untuk menampilkan jumlah ibu hamil yang memiliki faktor risiko tinggi (RESTI) berdasarkan berbagai kategori.\n\n',
              ),
              const TextSpan(
                text: '• Resti Nakes: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    'Ibu hamil yang dikategorikan risiko tinggi oleh tenaga kesehatan berdasarkan hasil pemeriksaan medis.\n\n',
              ),
              const TextSpan(
                text: '• Resti Masyarakat: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    'Ibu hamil yang diidentifikasi berisiko tinggi oleh masyarakat (kader, keluarga, atau tokoh setempat).\n\n',
              ),
              const TextSpan(
                text: '• Risiko Panggul Sempit (tb < 145 cm): ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    'Tinggi badan ibu kurang dari 145 cm, berisiko mengalami kesulitan saat persalinan.\n\n',
              ),
              const TextSpan(
                text: '• Hipertensi: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    'Tekanan darah tinggi selama kehamilan (≥ 140/90 mmHg), dapat menyebabkan komplikasi seperti preeklamsia.\n\n',
              ),
              const TextSpan(
                text: '• Obesitas: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    'Ibu dengan indeks massa tubuh ≥ 25, berisiko mengalami komplikasi kehamilan dan persalinan.\n\n',
              ),
              const TextSpan(
                text: '• Anemia: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    'Kadar hemoglobin rendah (<11 g/dl), dapat menyebabkan kelelahan dan komplikasi janin.\n\n',
              ),
              const TextSpan(
                text: '• Paritas Tinggi (≥ 4x): ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    'Ibu dengan riwayat melahirkan empat kali atau lebih, berisiko tinggi mengalami komplikasi obstetri.\n\n',
              ),
              const TextSpan(
                text: '• Usia Terlalu Tua (> 35 tahun): ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    'Kehamilan pada usia lanjut meningkatkan risiko komplikasi bagi ibu dan janin.\n\n',
              ),
              const TextSpan(
                text: '• Usia Terlalu Muda (< 20 tahun): ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    'Kehamilan pada usia remaja berisiko tinggi terhadap anemia, KEK, dan komplikasi saat melahirkan.\n\n',
              ),
              const TextSpan(
                text: '• Pernah Abortus: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    'Riwayat keguguran sebelumnya dapat meningkatkan risiko komplikasi pada kehamilan berikutnya.\n\n',
              ),
              const TextSpan(
                text: '• Kekurangan Energi Kronis (KEK): ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    'Ibu hamil dengan lingkar lengan atas < 23,5 cm, berisiko tinggi mengalami komplikasi kehamilan.\n\n',
              ),
              const TextSpan(
                text:
                    'Statistik ini membantu Bidan memantau dan memberikan perhatian khusus kepada ibu hamil dengan faktor risiko tinggi agar mendapat penanganan lebih cepat dan tepat.',
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
                      Navigator.pushNamed(context, AppRouter.listRestiStats);
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
                        AppRouter.trenRestiStats,
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
                        AppRouter.trenRestiStats,
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
                        AppRouter.trenRestiStats,
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
    int? value, {
    int cross = 1,
    num main = 1,
  }) {
    // Buat warna acak stabil berdasarkan hash dari label
    // Warna pastel cerah stabil berdasar label
    // final random = Random(label.hashCode);
    // final hue = random.nextInt(360).toDouble();
    // final hsl = HSLColor.fromAHSL(
    //   1.0,
    //   hue,
    //   0.45,
    //   0.8,
    // ); // saturasi & lightness disetel lembut
    // final color = hsl.toColor();
    final bgColor = Utils.generateDistinctColor(label);
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
}
