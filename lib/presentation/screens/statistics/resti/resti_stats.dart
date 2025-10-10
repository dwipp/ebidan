import 'dart:math';

import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/screens/statistics/widgets/animated_data_card.dart';
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
        "label": "Usia Terlalu Muda \n(< 20 tahun)",
        "value": selectedResti?.tooYoung,
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
        "label": "Usia Terlalu Tua (> 35 thn)",
        "value": selectedResti?.tooOld,
        'cross': 2,
        'main': 1,
      },
      {
        "label": "Paritas Tinggi (>=4x)",
        "value": selectedResti?.paritasTinggi,
        'cross': 2,
        'main': 0.85,
      },
      {
        "label": "Resiko Panggul Sempit",
        "value": selectedResti?.tbUnder145,
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
      appBar: PageHeader(title: Text('Resti')),
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
    final random = Random(label.hashCode);
    final hue = random.nextInt(360).toDouble();
    final hsl = HSLColor.fromAHSL(
      1.0,
      hue,
      0.45,
      0.8,
    ); // saturasi & lightness disetel lembut
    final color = hsl.toColor();

    final card = Card(
      margin: EdgeInsets.zero,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DefaultTextStyle(
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              child: Text(label, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 4),
            Text(
              "${value ?? 0}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.black87,
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
