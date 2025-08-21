import 'package:ebidan/data/models/riwayat_model.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:flutter/material.dart';

class ListRiwayatBumilScreen extends StatelessWidget {
  final List<Riwayat> riwayatList;

  const ListRiwayatBumilScreen({super.key, required this.riwayatList});

  @override
  Widget build(BuildContext context) {
    // urutkan dari tahun terbaru
    riwayatList.sort((a, b) => b.tahun.compareTo(a.tahun));

    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Kehamilan")),
      body: ListView.builder(
        itemCount: riwayatList.length,
        itemBuilder: (context, i) {
          final Riwayat riwayat = riwayatList[i];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text("Tahun ${riwayat.tahun}"),
              subtitle: Text(
                "Berat: ${riwayat.beratBayi} g, Panjang: ${riwayat.panjangBayi} cm\n"
                "Status: ${riwayat.statusBayi}, Tempat: ${riwayat.tempat}",
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.detailRiwayat,
                  arguments: {'riwayat': riwayat},
                );
              },
            ),
          );
        },
      ),
    );
  }
}
