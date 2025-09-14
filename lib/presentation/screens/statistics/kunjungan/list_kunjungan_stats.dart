import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/presentation/widgets/premium_warning_banner.dart';
import 'package:ebidan/state_management/general/cubit/statistic_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ListKunjunganStatsScreen extends StatelessWidget {
  const ListKunjunganStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kunjunganStatsMap =
        context.read<StatisticCubit>().state.statistic?.byMonth ?? {};
    final warningBanner = PremiumWarningBanner.fromContext(context);

    // Ubah Map menjadi List agar bisa di-ListView, urut dari terbaru ke lama
    final kunjunganStatsList = kunjunganStatsMap.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    final hasBanner = warningBanner != null;

    return Scaffold(
      appBar: PageHeader(title: "Statistik Kunjungan"),
      body: ListView.builder(
        itemCount: kunjunganStatsList.length + (hasBanner ? 1 : 0),
        itemBuilder: (context, index) {
          if (hasBanner && index == 0) {
            return Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: warningBanner,
            );
          }

          final entry = kunjunganStatsList[index - (hasBanner ? 1 : 0)];
          final bulanKey = entry.key; // format "yyyy-MM"
          final stats = entry.value;

          // Konversi yyyy-MM menjadi format "MMMM yyyy"
          final parsedDate = DateTime.tryParse("$bulanKey-01");
          final bulanFormatted = parsedDate != null
              ? DateFormat("MMMM yyyy").format(parsedDate)
              : bulanKey;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.calendar_month),
              title: Text(
                bulanFormatted,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text("Total kunjungan: ${stats.kunjungan.total}"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                if ((hasBanner ? index - 1 : index) == 0) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushNamed(
                    context,
                    AppRouter.kunjunganStats,
                    arguments: {'monthKey': bulanKey},
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
