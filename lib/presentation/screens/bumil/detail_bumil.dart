import 'package:ebidan/data/models/bumil_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailBumilScreen extends StatelessWidget {
  final Bumil bumil;

  const DetailBumilScreen({super.key, required this.bumil});

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    // Format ke bahasa Indonesia: 1 Januari 1990
    return DateFormat("d MMMM yyyy", "id_ID").format(date);
  }

  Widget _buildRow(String label, String? value, {String suffix = ''}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              (value != null && value.isNotEmpty) ? '$value $suffix' : "-",
              softWrap: true,
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Bumil"),
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
                "Data Ibu",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildRow("Nama", bumil.namaIbu),
              _buildRow("NIK", bumil.nikIbu),
              _buildRow("KK", bumil.kkIbu),
              _buildRow("Agama", bumil.agamaIbu),
              _buildRow("Pendidikan", bumil.pendidikanIbu),
              _buildRow("Pekerjaan", bumil.jobIbu),
              _buildRow("Golongan Darah", bumil.bloodIbu),
              _buildRow("Tanggal Lahir", _formatDate(bumil.birthdateIbu)),

              const SizedBox(height: 16),
              const Text(
                "Data Suami",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildRow("Nama", bumil.namaSuami),
              _buildRow("NIK", bumil.nikSuami),
              _buildRow("KK", bumil.kkSuami),
              _buildRow("Agama", bumil.agamaSuami),
              _buildRow("Pendidikan", bumil.pendidikanSuami),
              _buildRow("Pekerjaan", bumil.jobSuami),
              _buildRow("Golongan Darah", bumil.bloodSuami),
              _buildRow("Tanggal Lahir", _formatDate(bumil.birthdateSuami)),

              const SizedBox(height: 16),
              const Text(
                "Kontak & Alamat",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildRow("No. HP", bumil.noHp),
              _buildRow("Alamat", bumil.alamat),

              const SizedBox(height: 16),
              const Text(
                "Lainnya",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildRow("Menerima buku KIA", _formatDate(bumil.createdAt)),
            ],
          ),
        ),
      ),
    );
  }
}
