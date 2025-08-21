import 'package:ebidan/data/models/riwayat_model.dart';
import 'package:flutter/material.dart';

class DetailRiwayatScreen extends StatelessWidget {
  final Riwayat riwayat;

  const DetailRiwayatScreen({super.key, required this.riwayat});

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: Text(label)),
          Expanded(flex: 4, child: Text(value.isNotEmpty ? value : "-")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail Riwayat ${riwayat.tahun}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRow("Berat Bayi", riwayat.beratBayi),
              _buildRow("Panjang Bayi", riwayat.panjangBayi),
              _buildRow("Status Bayi", riwayat.statusBayi),
              _buildRow("Status Lahir", riwayat.statusLahir),
              _buildRow("Status Term", riwayat.statusTerm),
              _buildRow("Tempat", riwayat.tempat),
              _buildRow("Penolong", riwayat.penolong),
              _buildRow("Komplikasi", riwayat.komplikasi),
            ],
          ),
        ),
      ),
    );
  }
}
