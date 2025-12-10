import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/screens/mode_bidan/statistics/widgets/info_button_bar.dart';
import 'package:ebidan/presentation/widgets/button.dart';
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

    final sfMap = selectedSf?.toMap() ?? {};

    final monthLabel = Utils.formattedDateFromYearMonth(
      monthKey ?? stats?.lastUpdatedMonth ?? '',
    );

    return Scaffold(
      appBar: PageHeader(
        title: const Text('Stats Konsumsi SF'),
        actions: [
          InfoButtonBar(
            title: 'Tentang Statistik SF',
            contentSpans: [
              const TextSpan(
                text:
                    'Statistik SF menampilkan distribusi pemberian Suplemen Fe (Tablet Tambah Darah) kepada ibu hamil.\n\n',
              ),
              const TextSpan(
                text: '• SF1: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: 'Setara dengan pemberian 30 tablet.\n'),
              const TextSpan(
                text: '• SF2: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text: 'Setara dengan 60 tablet, dan seterusnya.\n\n',
              ),
              const TextSpan(
                text:
                    'Data ini digunakan untuk memantau kepatuhan konsumsi Suplemen Fe oleh ibu hamil.',
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
              const SizedBox(height: 32),
              // --- HISTORY BUTTON ---
              if (monthKey == Utils.getAutoYearMonth()) ...[
                SizedBox(
                  width: double.infinity,
                  child: Button(
                    isSubmitting: false,
                    onPressed: () {
                      Navigator.pushNamed(context, AppRouter.listSfStats);
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
                        AppRouter.trenSfStats,
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
                        AppRouter.trenSfStats,
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
                        AppRouter.trenSfStats,
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
