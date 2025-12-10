import 'package:ebidan/presentation/screens/mode_bidan/statistics/widgets/list_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ebidan/state_management/general/cubit/statistic_cubit.dart';
import 'package:ebidan/presentation/router/app_router.dart';

class ListKunjunganStatsScreen extends StatelessWidget {
  const ListKunjunganStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsMap =
        context.read<StatisticCubit>().state.statistic?.byMonth ?? {};

    return ListStatsScreen(
      title: "Statistik Kunjungan",
      dataMap: statsMap,
      routeName: AppRouter.kunjunganStats,
      subtitleBuilder: (key, value) =>
          "Total kunjungan: ${value.kunjungan.total}",
    );
  }
}
