import 'package:ebidan/presentation/screens/mode_bidan/statistics/widgets/tren_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ebidan/state_management/general/cubit/statistic_cubit.dart';

class TrenKunjunganStatsScreen extends StatelessWidget {
  final List<String> monthKeys;
  const TrenKunjunganStatsScreen({super.key, required this.monthKeys});

  @override
  Widget build(BuildContext context) {
    final statistic = context.read<StatisticCubit>().state.statistic!;

    return TrenStatsScreen(
      title: "Tren Kunjungan",
      monthKeys: monthKeys,
      dataGetter: (key) => statistic.byMonth[key],
      indicators: [
        TrenIndicator(
          label: "K1",
          color: Colors.blue,
          valueGetter: (data) => data.kunjungan.k1,
        ),
        TrenIndicator(
          label: "K2",
          color: Colors.green,
          valueGetter: (data) => data.kunjungan.k2,
        ),
        TrenIndicator(
          label: "K3",
          color: Colors.yellow.shade600,
          valueGetter: (data) => data.kunjungan.k3,
        ),
        TrenIndicator(
          label: "K4",
          color: Colors.orange,
          valueGetter: (data) => data.kunjungan.k4,
        ),
        TrenIndicator(
          label: "K5",
          color: Colors.pink,
          valueGetter: (data) => data.kunjungan.k5,
        ),
        TrenIndicator(
          label: "K6",
          color: Colors.red,
          valueGetter: (data) => data.kunjungan.k6,
        ),
      ],
    );
  }
}
