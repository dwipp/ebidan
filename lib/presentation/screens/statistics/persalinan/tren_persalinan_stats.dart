import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/data/models/statistic_model.dart';
import 'package:ebidan/presentation/screens/statistics/widgets/tren_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ebidan/state_management/general/cubit/statistic_cubit.dart';

class TrenPersalinanStatsScreen extends StatelessWidget {
  final List<String> monthKeys;
  const TrenPersalinanStatsScreen({super.key, required this.monthKeys});
  // UBAH DATA! GUNAKAN DATA PERSALINAN
  List<TrenIndicator> _generateSfIndicators() {
    // Ambil semua key dari model
    final sfKeys = SfByMonth().toMap().keys.toList();

    // Urutkan berdasarkan angka (pastikan 30, 60, 90, dst berurutan)
    sfKeys.sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    return sfKeys.map((key) {
      final label = "Persalinan ${int.parse(key) ~/ 30}";
      final fieldName = key;

      return TrenIndicator(
        label: label,
        color: Utils.generateDistinctColor(label),
        valueGetter: (data) {
          final sfData = data.persalinan;
          final value = sfData.toMap()[fieldName];
          return (value is num) ? value.toInt() : 0;
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final statistic = context.read<StatisticCubit>().state.statistic;

    return TrenStatsScreen(
      title: "Tren Persalinan",
      monthKeys: monthKeys,
      dataGetter: (key) => statistic?.byMonth[key],
      indicators: _generateSfIndicators(),
    );
  }
}
