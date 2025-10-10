import 'package:ebidan/presentation/screens/statistics/widgets/list_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ebidan/state_management/general/cubit/statistic_cubit.dart';
import 'package:ebidan/presentation/router/app_router.dart';

class ListRestiStatsScreen extends StatelessWidget {
  const ListRestiStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsMap =
        context.read<StatisticCubit>().state.statistic?.byMonth ?? {};

    return ListStatsScreen(
      title: "Statistik Resti",
      dataMap: statsMap,
      routeName: AppRouter.restiStats,
      subtitleBuilder: (key, value) => "Total resti: ${value.resti.totalResti}",
      leadingIcon: Icons.health_and_safety,
    );
  }
}
