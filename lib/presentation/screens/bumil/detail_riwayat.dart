import 'package:ebidan/data/models/riwayat_model.dart';
import 'package:flutter/material.dart';

class DetailRiwayatScreen extends StatelessWidget {
  final Riwayat riwayat;

  const DetailRiwayatScreen({super.key, required this.riwayat});

  Widget _buildInfoTile(
    IconData icon,
    String label,
    String value, {
    String suffixText = '',
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        subtitle: Text(
          value.isNotEmpty ? '$value $suffixText' : "-",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Riwayat ${riwayat.tahun}"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Informasi Bayi",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoTile(
              Icons.monitor_weight,
              "Berat Bayi",
              riwayat.beratBayi,
              suffixText: 'gram',
            ),
            _buildInfoTile(
              Icons.straighten,
              "Panjang Bayi",
              riwayat.panjangBayi,
              suffixText: 'cm',
            ),
            _buildInfoTile(Icons.child_care, "Status Bayi", riwayat.statusBayi),

            const SizedBox(height: 16),
            const Text(
              "Kelahiran",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoTile(
              Icons.local_hospital,
              "Status Lahir",
              riwayat.statusLahir,
            ),
            _buildInfoTile(Icons.date_range, "Status Term", riwayat.statusTerm),
            _buildInfoTile(Icons.place, "Tempat", riwayat.tempat),
            _buildInfoTile(Icons.person, "Penolong", riwayat.penolong),
            _buildInfoTile(
              Icons.warning_amber_rounded,
              "Komplikasi",
              riwayat.komplikasi,
            ),
          ],
        ),
      ),
    );
  }
}
