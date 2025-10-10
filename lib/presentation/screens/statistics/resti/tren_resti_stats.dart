import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/screens/statistics/widgets/tren_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ebidan/state_management/general/cubit/statistic_cubit.dart';

class TrenRestiStatsScreen extends StatelessWidget {
  final List<String> monthKeys;
  const TrenRestiStatsScreen({super.key, required this.monthKeys});

  @override
  Widget build(BuildContext context) {
    final statistic = context.read<StatisticCubit>().state.statistic!;

    return TrenStatsScreen(
      title: "Tren Resti",
      monthKeys: monthKeys,
      dataGetter: (key) => statistic.byMonth[key],
      indicators: [
        TrenIndicator(
          label: "Resti Nakes",
          color: Utils.generateDistinctColor('Resti Nakes'),
          valueGetter: (data) => data.resti.restiNakes,
        ),
        TrenIndicator(
          label: "Resti Masyarakat",
          color: Utils.generateDistinctColor('Resti Masyarakat'),
          valueGetter: (data) => data.resti.restiMasyarakat,
        ),
        TrenIndicator(
          label: "Usia Terlalu Muda (< 20 tahun)",
          color: Utils.generateDistinctColor('Usia Terlalu Muda (< 20 tahun)'),
          valueGetter: (data) => data.resti.tooYoung,
        ),
        TrenIndicator(
          label: "Usia Terlalu Tua (> 35 tahun)",
          color: Utils.generateDistinctColor('Usia Terlalu Tua (> 35 tahun)'),
          valueGetter: (data) => data.resti.tooOld,
        ),
        TrenIndicator(
          label: "Hipertensi",
          color: Utils.generateDistinctColor('Hipertensi'),
          valueGetter: (data) => data.resti.hipertensi,
        ),
        TrenIndicator(
          label: "Obesitas",
          color: Utils.generateDistinctColor('Obesitas'),
          valueGetter: (data) => data.resti.obesitas,
        ),
        TrenIndicator(
          label: "Anemia",
          color: Utils.generateDistinctColor('Anemia'),
          valueGetter: (data) => data.resti.anemia,
        ),
        TrenIndicator(
          label: "Paritas Tinggi (>= 4x)",
          color: Utils.generateDistinctColor('Paritas Tinggi (>= 4x)'),
          valueGetter: (data) => data.resti.paritasTinggi,
        ),
        TrenIndicator(
          label: "Resiko Panggul Sempit (tb < 145cm)",
          color: Utils.generateDistinctColor(
            'Resiko Panggul Sempit (tb < 145cm)',
          ),
          valueGetter: (data) => data.resti.tbUnder145,
        ),
        TrenIndicator(
          label: "Pernah Abortus",
          color: Utils.generateDistinctColor('Pernah Abortus'),
          valueGetter: (data) => data.resti.pernahAbortus,
        ),
        TrenIndicator(
          label: "Kekurangan Energi Kronis (KEK)",
          color: Utils.generateDistinctColor('Kekurangan Energi Kronis (KEK)'),
          valueGetter: (data) => data.resti.kek,
        ),
      ],
    );
  }
}
