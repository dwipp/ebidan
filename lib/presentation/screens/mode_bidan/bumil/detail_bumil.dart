import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/state_management/mode_bidan/bumil/cubit/selected_bumil_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailBumilScreen extends StatelessWidget {
  const DetailBumilScreen({super.key});

  int usia(DateTime tanggalLahir) {
    DateTime sekarang = DateTime.now();
    int usia = sekarang.year - tanggalLahir.year;

    // cek apakah ulang tahun tahun ini sudah lewat atau belum
    if (sekarang.month < tanggalLahir.month ||
        (sekarang.month == tanggalLahir.month &&
            sekarang.day < tanggalLahir.day)) {
      usia--;
    }

    return usia;
  }

  @override
  Widget build(BuildContext context) {
    final bumil = context.watch<SelectedBumilCubit>().state;
    return Scaffold(
      appBar: PageHeader(
        title: Text("Detail Bumil"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              print('edit');
              Navigator.pushNamed(
                context,
                AppRouter.editBumil,
                arguments: {'bumil': bumil},
              );
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
              Utils.generateRowLabelValue(
                context,
                label: "Nama",
                value: bumil?.namaIbu,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "NIK",
                value: bumil?.nikIbu,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "KK",
                value: bumil?.kkIbu,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Agama",
                value: bumil?.agamaIbu,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Pendidikan",
                value: bumil?.pendidikanIbu,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Pekerjaan",
                value: bumil?.jobIbu,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Golongan Darah",
                value: bumil?.bloodIbu,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Tanggal Lahir",
                value: Utils.formattedDate(bumil?.birthdateIbu),
              ),
              if (bumil?.birthdateIbu != null)
                Utils.generateRowLabelValue(
                  context,
                  label: "Usia",
                  value: '${usia(bumil!.birthdateIbu!)} tahun',
                ),
              const SizedBox(height: 16),
              const Text(
                "Data Suami",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue(
                context,
                label: "Nama",
                value: bumil?.namaSuami,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "NIK",
                value: bumil?.nikSuami,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "KK",
                value: bumil?.kkSuami,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Agama",
                value: bumil?.agamaSuami,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Pendidikan",
                value: bumil?.pendidikanSuami,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Pekerjaan",
                value: bumil?.jobSuami,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Golongan Darah",
                value: bumil?.bloodSuami,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Tanggal Lahir",
                value: Utils.formattedDate(bumil?.birthdateSuami),
              ),
              const SizedBox(height: 16),
              const Text(
                "Kontak & Alamat",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue(
                context,
                label: "No. HP",
                value: bumil?.noHp,
              ),
              Utils.generateRowLabelValue(
                context,
                label: "Alamat",
                value: bumil?.alamat,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
