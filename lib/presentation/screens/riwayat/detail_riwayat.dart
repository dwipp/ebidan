import 'package:ebidan/data/models/riwayat_model.dart';
import 'package:ebidan/common/Utils.dart';
import 'package:flutter/material.dart';

class DetailRiwayatScreen extends StatelessWidget {
  final Riwayat riwayat;

  const DetailRiwayatScreen({super.key, required this.riwayat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Riwayat"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              print('edit');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Informasi Bayi",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue(
                "Berat Bayi",
                riwayat.beratBayi.toString(),
                suffix: 'gram',
              ),
              Utils.generateRowLabelValue(
                "Panjang Bayi",
                riwayat.panjangBayi,
                suffix: 'cm',
              ),
              Utils.generateRowLabelValue("Status Bayi", riwayat.statusBayi),

              const SizedBox(height: 16),
              const Text(
                "Kelahiran",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue("Status Lahir", riwayat.statusLahir),
              Utils.generateRowLabelValue("Status Term", riwayat.statusTerm),
              Utils.generateRowLabelValue("Tempat", riwayat.tempat),
              Utils.generateRowLabelValue("Penolong", riwayat.penolong),
              Utils.generateRowLabelValue("Komplikasi", riwayat.komplikasi),
            ],
          ),
        ),
      ),
    );
  }
}
