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
      {"label": "Abortus", "value": selectedResti?.abortus},
      {"label": "Anemia", "value": selectedResti?.anemia},
      {"label": "Hipertensi", "value": selectedResti?.hipertensi},
      {"label": "Kekurangan Energi Kronis", "value": selectedResti?.kek},
      {"label": "Obesitas", "value": selectedResti?.obesitas},
      {"label": "Paritas Tinggi", "value": selectedResti?.paritasTinggi},
      {"label": "Pernah Abortus", "value": selectedResti?.pernahAbortus},
      {"label": "Resti Masyarakat", "value": selectedResti?.restiMasyarakat},
      {"label": "Resti Nakes", "value": selectedResti?.restiNakes},
      {"label": "Resiko Panggul Sempit", "value": selectedResti?.tbUnder145},
      {"label": "Usia Terlalu Muda (<20)", "value": selectedResti?.tooYoung},
      {"label": "Usia Terlalu Tua (>35)", "value": selectedResti?.tooOld},
    ];
    final List<Widget> gridItems = [];

    gridItems.add(
      AnimatedDataCard(
        label: "Total Resti",
        value: selectedResti?.totalResti ?? 0,
        isTotal: true,
        icon: Icons.bar_chart,
      ),
    );

    kategori.forEach((element) {
      gridItems.add(_buildCardItem(element["label"], element["value"]));
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
              MasonryGridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                itemCount: gridItems.length,
                itemBuilder: (context, index) {
                  return gridItems[index];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardItem(String label, int? value) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.blue.shade200,
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
                color: Colors.blue.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
