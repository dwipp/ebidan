import 'package:ebidan/presentation/screens/statistics/widgets/list_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ebidan/state_management/general/cubit/statistic_cubit.dart';
import 'package:ebidan/presentation/router/app_router.dart';

class ListSfStatsScreen extends StatelessWidget {
  const ListSfStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsMap =
        context.read<StatisticCubit>().state.statistic?.byMonth ?? {};

    return ListStatsScreen(
      title: "Statistik Suplemen Fe",
      dataMap: statsMap,
      routeName: AppRouter.sfStats,
      subtitleBuilder: (key, value) =>
          "Total Konsumsi Fe: ${value.sf.sf30}", // ganti sf30 dengan total sf berdasarkan jumlah pasien
      leadingIcon: Icons.bloodtype,
    );
  }
}
