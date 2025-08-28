import 'package:ebidan/common/Utils.dart';
import 'package:ebidan/presentation/router/app_router.dart';
import 'package:ebidan/presentation/widgets/page_header.dart';
import 'package:ebidan/state_management/bumil/cubit/selected_bumil_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailBumilScreen extends StatelessWidget {
  const DetailBumilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bumil = context.watch<SelectedBumilCubit>().state;
    return Scaffold(
      appBar: PageHeader(
        title: "Detail Bumil",
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
              Utils.generateRowLabelValue("Nama", bumil?.namaIbu),
              Utils.generateRowLabelValue("NIK", bumil?.nikIbu),
              Utils.generateRowLabelValue("KK", bumil?.kkIbu),
              Utils.generateRowLabelValue("Agama", bumil?.agamaIbu),
              Utils.generateRowLabelValue("Pendidikan", bumil?.pendidikanIbu),
              Utils.generateRowLabelValue("Pekerjaan", bumil?.jobIbu),
              Utils.generateRowLabelValue("Golongan Darah", bumil?.bloodIbu),
              Utils.generateRowLabelValue(
                "Tanggal Lahir",
                Utils.formattedDate(bumil?.birthdateIbu),
              ),

              const SizedBox(height: 16),
              const Text(
                "Data Suami",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue("Nama", bumil?.namaSuami),
              Utils.generateRowLabelValue("NIK", bumil?.nikSuami),
              Utils.generateRowLabelValue("KK", bumil?.kkSuami),
              Utils.generateRowLabelValue("Agama", bumil?.agamaSuami),
              Utils.generateRowLabelValue("Pendidikan", bumil?.pendidikanSuami),
              Utils.generateRowLabelValue("Pekerjaan", bumil?.jobSuami),
              Utils.generateRowLabelValue("Golongan Darah", bumil?.bloodSuami),
              Utils.generateRowLabelValue(
                "Tanggal Lahir",
                Utils.formattedDate(bumil?.birthdateSuami),
              ),

              const SizedBox(height: 16),
              const Text(
                "Kontak & Alamat",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue("No. HP", bumil?.noHp),
              Utils.generateRowLabelValue("Alamat", bumil?.alamat),

              const SizedBox(height: 16),
              const Text(
                "Lainnya",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Utils.generateRowLabelValue(
                "Menerima buku KIA",
                Utils.formattedDate(bumil?.createdAt),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
