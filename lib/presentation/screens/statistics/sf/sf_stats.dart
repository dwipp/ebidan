import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/premium_warning_banner.dart';
import 'package:ebidan/state_management/general/cubit/statistic_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SfStatsScreen extends StatelessWidget {
  final String? monthKey;
  const SfStatsScreen({super.key, this.monthKey});

  @override
  Widget build(BuildContext context) {
    final stats = context.read<StatisticCubit>().state.statistic;
    final selectedMonth = stats?.byMonth[monthKey];
    final selectedSf = selectedMonth?.sf ?? stats?.lastMonthData?.sf;
    final warningBanner = PremiumWarningBanner.fromContext(context);

    final sfMap = {
      '30': selectedSf?.sf30 ?? 0,
      '60': selectedSf?.sf60 ?? 0,
      '90': selectedSf?.sf90 ?? 0,
      '120': selectedSf?.sf120 ?? 0,
      '150': selectedSf?.sf150 ?? 0,
      '180': selectedSf?.sf180 ?? 0,
      '210': selectedSf?.sf210 ?? 0,
      '240': selectedSf?.sf240 ?? 0,
      '270': selectedSf?.sf270 ?? 0,
    };

    final monthLabel = Utils.formattedDateFromYearMonth(
      monthKey ?? stats?.lastUpdatedMonth ?? '',
    );

    return Scaffold(
      appBar: PageHeader(title: const Text('Statistik SF')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (warningBanner != null) warningBanner,
              Text(
                "Laporan Bulan $monthLabel",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              MasonryGridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sfMap.length,
                itemBuilder: (context, index) {
                  final entry = sfMap.entries.elementAt(index);
                  final sfValue = entry.value;
                  final sfKey = entry.key;
                  final label = SupplementForm(sfKey).label;
                  final bgColor = Utils.generateDistinctColor(label);
                  final fgColor = Utils.generateForegroundColor(bgColor);
                  final valueColor = Utils.generateHighContrastColor(bgColor);
                  return Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: fgColor,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "$sfValue",
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: valueColor,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class SupplementForm {
  final String tablets; // contoh: 30, 60, 90, dst
  late final String label; // otomatis: SF1, SF2, dst

  SupplementForm(this.tablets) {
    label = _generateLabel(tablets);
  }

  String _generateLabel(String tablets) {
    final tabletsInt = int.tryParse(tablets) ?? 0;
    final index = (tabletsInt / 30).round();
    return 'SF$index';
  }

  @override
  String toString() => 'SupplementForm(label: $label, tablets: $tablets)';
}
