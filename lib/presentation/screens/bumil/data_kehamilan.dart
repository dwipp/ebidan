import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ebidan/data/models/kehamilan_model.dart';

class DataKehamilanScreen extends StatelessWidget {
  final Kehamilan kehamilan;

  const DataKehamilanScreen({super.key, required this.kehamilan});

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat("d MMMM yyyy", "id_ID").format(date);
  }

  Widget _buildRow(String label, String? value, {String suffix = ''}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey.shade100, // bg label
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.transparent, // bg value
              alignment: Alignment.centerLeft,
              child: Text(
                (value != null && value.isNotEmpty) ? '$value $suffix' : "-",
                softWrap: true,
                maxLines: null,
              ),
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
        title: const Text("Data Kehamilan"),
        actions: [
          IconButton(
            icon: const Icon(Icons.child_care),
            onPressed: () {
              // telah partus
              // munculkan popup untuk konfirmasi, apakah sudah partus.
              // jika sudah partus, update status_persalinan
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
                "Data Kehamilan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildRow("Tinggi Badan", kehamilan.tb?.toString(), suffix: "cm"),
              _buildRow("No. Kohort Ibu", kehamilan.noKohortIbu),
              _buildRow("No. Rekam Medis", kehamilan.noRekaMedis),
              _buildRow("BPJS", kehamilan.bpjs),
              _buildRow("Status Ibu", kehamilan.statusIbu),
              _buildRow("Status TT", kehamilan.statusTt),
              _buildRow(
                "Kontrasepsi Sebelum Hamil",
                kehamilan.kontrasepsiSebelumHamil,
              ),
              _buildRow("GPA", kehamilan.gpa),
              _buildRow("HPHT", _formatDate(kehamilan.hpht)),
              _buildRow("HTP", _formatDate(kehamilan.htp)),
              _buildRow(
                "Tanggal Periksa USG",
                _formatDate(kehamilan.tglPeriksaUsg),
              ),
              _buildRow("Riwayat Penyakit", kehamilan.riwayatPenyakit),
              _buildRow("Riwayat Alergi", kehamilan.riwayatAlergi),
              _buildRow("Hasil Lab", kehamilan.hasilLab),
              _buildRow('Hemoglobin', kehamilan.hemoglobin, suffix: 'g/dL'),
              _buildRow("Dibuat Pada", _formatDate(kehamilan.createdAt)),

              const SizedBox(height: 16),
              const Text(
                "Resti",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (kehamilan.resti != null && kehamilan.resti!.isNotEmpty)
                Column(
                  children: kehamilan.resti!
                      .map(
                        (r) => Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 4),
                          child: Text('- $r'),
                        ),
                      )
                      .toList(),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  child: const Text("-"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
