import 'package:ebidan/presentation/screens/statistics/widgets/list_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ebidan/state_management/general/cubit/statistic_cubit.dart';
import 'package:ebidan/presentation/router/app_router.dart';

class ListPersalinanStatsScreen extends StatelessWidget {
  const ListPersalinanStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsMap =
        context.read<StatisticCubit>().state.statistic?.byMonth ?? {};

    return ListStatsScreen(
      title: "Statistik Persalinan",
      dataMap: statsMap,
      routeName: AppRouter.persalinanStats,
      subtitleBuilder: (key, value) =>
          "Total Persalinan: ${value.persalinan.total}", // ganti sf30 dengan total sf berdasarkan jumlah pasien
      leadingIcon: Icons.bloodtype,
    );
  }
}
