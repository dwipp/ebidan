import 'package:ebidan/data/models/persalinan_model.dart';
import 'package:ebidan/common/Utils.dart';
import 'package:flutter/material.dart';

class DetailPersalinanScreen extends StatelessWidget {
  final Persalinan persalinan;

  const DetailPersalinanScreen({super.key, required this.persalinan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Persalinan"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              print('edit persalinan');
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

              // Selalu tampil
              Utils.generateRowLabelValue(
                "Status Bayi",
                persalinan.statusBayi ?? "-",
              ),

              // Tampil hanya jika status bayi bukan Abortus
              if (persalinan.statusBayi != "Abortus") ...[
                Utils.generateRowLabelValue(
                  "Berat Lahir",
                  persalinan.beratLahir?.toString() ?? "-",
                  suffix: 'gram',
                ),
                Utils.generateRowLabelValue(
                  "Panjang Badan",
                  persalinan.panjangBadan?.toString() ?? "-",
                  suffix: 'cm',
                ),
                Utils.generateRowLabelValue(
                  "Lingkar Kepala",
                  persalinan.lingkarKepala?.toString() ?? "-",
                  suffix: 'cm',
                ),
                Utils.generateRowLabelValue(
                  "Jenis Kelamin",
                  persalinan.sex ?? "-",
                ),
              ],

              const SizedBox(height: 16),
              const Text(
                "Detail Persalinan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue(
                "Tanggal Persalinan",
                persalinan.tglPersalinan != null
                    ? Utils.formattedDate(persalinan.tglPersalinan!)
                    : "-",
              ),
              Utils.generateRowLabelValue(
                "Umur Kehamilan",
                persalinan.umurKehamilan?.toString() ?? "-",
                suffix: " minggu",
              ),
              Utils.generateRowLabelValue(
                "Cara Persalinan",
                persalinan.cara ?? "-",
              ),
              Utils.generateRowLabelValue("Tempat", persalinan.tempat ?? "-"),
              Utils.generateRowLabelValue(
                "Penolong",
                persalinan.penolong ?? "-",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
