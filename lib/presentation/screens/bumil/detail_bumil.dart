import 'package:ebidan/data/models/bumil_model.dart';
import 'package:ebidan/logic/utility/Utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailBumilScreen extends StatelessWidget {
  final Bumil bumil;

  const DetailBumilScreen({super.key, required this.bumil});

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
              Utils.generateRowLabelValue("Nama", bumil.namaIbu),
              Utils.generateRowLabelValue("NIK", bumil.nikIbu),
              Utils.generateRowLabelValue("KK", bumil.kkIbu),
              Utils.generateRowLabelValue("Agama", bumil.agamaIbu),
              Utils.generateRowLabelValue("Pendidikan", bumil.pendidikanIbu),
              Utils.generateRowLabelValue("Pekerjaan", bumil.jobIbu),
              Utils.generateRowLabelValue("Golongan Darah", bumil.bloodIbu),
              Utils.generateRowLabelValue(
                "Tanggal Lahir",
                Utils.formattedDate(bumil.birthdateIbu),
              ),

              const SizedBox(height: 16),
              const Text(
                "Data Suami",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue("Nama", bumil.namaSuami),
              Utils.generateRowLabelValue("NIK", bumil.nikSuami),
              Utils.generateRowLabelValue("KK", bumil.kkSuami),
              Utils.generateRowLabelValue("Agama", bumil.agamaSuami),
              Utils.generateRowLabelValue("Pendidikan", bumil.pendidikanSuami),
              Utils.generateRowLabelValue("Pekerjaan", bumil.jobSuami),
              Utils.generateRowLabelValue("Golongan Darah", bumil.bloodSuami),
              Utils.generateRowLabelValue(
                "Tanggal Lahir",
                Utils.formattedDate(bumil.birthdateSuami),
              ),

              const SizedBox(height: 16),
              const Text(
                "Kontak & Alamat",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue("No. HP", bumil.noHp),
              Utils.generateRowLabelValue("Alamat", bumil.alamat),

              const SizedBox(height: 16),
              const Text(
                "Lainnya",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue(
                "Menerima buku KIA",
                Utils.formattedDate(bumil.createdAt),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
