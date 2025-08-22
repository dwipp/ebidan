import 'package:ebidan/logic/utility/Utils.dart';
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
              Utils.generateRowLabelValue(
                "Tinggi Badan",
                kehamilan.tb?.toString(),
                suffix: "cm",
              ),
              Utils.generateRowLabelValue(
                "No. Kohort Ibu",
                kehamilan.noKohortIbu,
              ),
              Utils.generateRowLabelValue(
                "No. Rekam Medis",
                kehamilan.noRekaMedis,
              ),
              Utils.generateRowLabelValue("BPJS", kehamilan.bpjs),
              Utils.generateRowLabelValue("Status Ibu", kehamilan.statusIbu),
              Utils.generateRowLabelValue("Status TT", kehamilan.statusTt),
              Utils.generateRowLabelValue(
                "Kontrasepsi Sebelum Hamil",
                kehamilan.kontrasepsiSebelumHamil,
              ),
              Utils.generateRowLabelValue("GPA", kehamilan.gpa),
              Utils.generateRowLabelValue("HPHT", _formatDate(kehamilan.hpht)),
              Utils.generateRowLabelValue("HTP", _formatDate(kehamilan.htp)),
              Utils.generateRowLabelValue(
                "Tanggal Periksa USG",
                _formatDate(kehamilan.tglPeriksaUsg),
              ),
              Utils.generateRowLabelValue(
                "Riwayat Penyakit",
                kehamilan.riwayatPenyakit,
              ),
              Utils.generateRowLabelValue(
                "Riwayat Alergi",
                kehamilan.riwayatAlergi,
              ),
              Utils.generateRowLabelValue("Hasil Lab", kehamilan.hasilLab),
              Utils.generateRowLabelValue(
                'Hemoglobin',
                kehamilan.hemoglobin,
                suffix: 'g/dL',
              ),
              Utils.generateRowLabelValue(
                "Dibuat Pada",
                _formatDate(kehamilan.createdAt),
              ),

              const SizedBox(height: 16),
              const Text(
                "Resti",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (kehamilan.resti != null && kehamilan.resti!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: kehamilan.resti!
                      .map(
                        (r) => Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          color: Colors.red.shade100,
                          child: Text('- $r'),
                        ),
                      )
                      .toList(),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey.shade100, // bg label
                  child: const Text("-"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
