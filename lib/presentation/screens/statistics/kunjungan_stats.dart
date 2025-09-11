import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/premium_warning_banner.dart';
import 'package:ebidan/state_management/general/cubit/statistic_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class KunjunganStatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatisticCubit>().state.statistic;
    final lastMonth = stats?.lastMonthData?.kunjungan;
    final warningBanner = PremiumWarningBanner.fromContext(context);
    return Scaffold(
      appBar: PageHeader(title: 'Statistik Kunjungan'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (warningBanner != null) warningBanner,
              Text(
                Utils.formattedYearMonth(stats?.lastUpdatedMonth ?? ''),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue(
                "Total Kunjungan",
                lastMonth?.total.toString(),
              ),
              Utils.generateRowLabelValue("K1", lastMonth?.k1.toString()),
              Utils.generateRowLabelValue(
                "K1 Akses",
                lastMonth?.k1Akses.toString(),
              ),
              Utils.generateRowLabelValue(
                "K1 Murni",
                lastMonth?.k1Murni.toString(),
              ),
              Utils.generateRowLabelValue("K4", lastMonth?.k4.toString()),
              Utils.generateRowLabelValue("K5", lastMonth?.k5.toString()),
              Utils.generateRowLabelValue("K6", lastMonth?.k6.toString()),
            ],
          ),
        ),
      ),
    );
  }
}
