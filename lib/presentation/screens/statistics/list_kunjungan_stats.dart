import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/state_management/general/cubit/statistic_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ListKunjunganStatsScreen extends StatelessWidget {
  const ListKunjunganStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kunjunganStatsMap = context.read<StatisticCubit>().state.statistic?.byMonth ?? {};

    // Ubah Map menjadi List agar bisa di-ListView
    final kunjunganStatsList = kunjunganStatsMap.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key)); // urutkan dari terbaru ke lama

    return Scaffold(
      appBar: PageHeader(title: "Statistik Kunjungan"),
      body: ListView.builder(
        itemCount: kunjunganStatsList.length,
        // separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = kunjunganStatsList[index];
          final bulanKey = entry.key; // format "yyyy-MM"
          final stats = entry.value;

          // Konversi yyyy-MM menjadi format "MMMM yyyy"
          final parsedDate = DateTime.tryParse("$bulanKey-01");
          final bulanFormatted = parsedDate != null
              ? DateFormat("MMMM yyyy").format(parsedDate)
              : bulanKey;
              
          return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: Text(
                      bulanFormatted,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text("Total kunjungan: ${stats.kunjungan.total}"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      if (index == 0) {
                        Navigator.pop(context);
                      }else {
                        Navigator.pushNamed(context, AppRouter.kunjunganStats, arguments: {'monthKey':bulanKey});
                      }
                    },
                  ),
                );
        },
      ),
    );
  }
}
